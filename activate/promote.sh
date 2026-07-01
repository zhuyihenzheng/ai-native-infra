#!/usr/bin/env bash
# promote.sh — 把对齐产物(source: universal/ + project/)装配成生效入口文件(build artifact)。
# 这是 source → 生效 的唯一搬运工。对齐未完成则拒绝运行。
set -euo pipefail

# ---- 路径解析 ----
# 用法: promote.sh [目标项目根]
#   不带参数时，目标默认 = ai-infra 的父目录（即「模板已部署进项目」的常规场景）。
#   带参数时，用显式目标（脱离常规布局时使用）。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../ai-infra/activate
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"                    # .../ai-infra
INFRA_REL="$(basename "$INFRA_DIR")"

if [ "${1:-}" != "" ]; then
  PROJECT_ROOT="$(cd "$1" && pwd)"
  EXPLICIT_TARGET=1
else
  PROJECT_ROOT="$(cd "$INFRA_DIR/.." && pwd)"               # ai-infra 的父目录
  EXPLICIT_TARGET=0
fi

PROJECT_DIR="$INFRA_DIR/project"
STATUS="$PROJECT_DIR/ALIGN-STATUS.md"
RULES="$PROJECT_DIR/aligned-rules.md"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$INFRA_DIR/_backup-$TS"

echo "==> 目标项目: $PROJECT_ROOT"

# ---- 闸门 0: 防误伤（这套是 Java 项目基建；目标必须像一个项目）----
# 没显式指定目标、且目标没有构建文件时拒绝——避免在模板自身的家目录/workspace 误跑。
if [ "$EXPLICIT_TARGET" = "0" ]; then
  if [ "$INFRA_REL" = "ai-native-infra" ]; then
    echo "✗ 这是基础设施 模板家目录 [${INFRA_DIR}] ，还没部署进任何项目。"
    echo "  请先: cp -r \"${INFRA_DIR}\" /path/to/your-project/ai-infra ，再到该项目里运行；"
    echo "  或显式指定目标: bash \"$0\" /path/to/your-project"
    exit 1
  fi
  if [ ! -e "$PROJECT_ROOT/pom.xml" ] && [ ! -e "$PROJECT_ROOT/build.gradle" ] && [ ! -e "$PROJECT_ROOT/build.gradle.kts" ]; then
    echo "✗ 目标 [${PROJECT_ROOT}] 不含 pom.xml / build.gradle(.kts)，不像一个 Java 项目根。"
    echo "  若确实要写这里，请显式指定: bash \"$0\" \"${PROJECT_ROOT}\""
    exit 1
  fi
fi

# ---- 闸门 1: 对齐状态 ----
# 只读文件中**第一处** ALIGN_STATE 标记并精确比对，避免被说明性 prose 里提到的 token 干扰。
STATE=""
if [ -f "$STATUS" ]; then
  STATE="$(grep -oE 'ALIGN_STATE:[[:space:]]*[A-Za-z-]+' "$STATUS" | head -1 | sed -E 's/.*ALIGN_STATE:[[:space:]]*//')"
fi
if [ "$STATE" != "aligned" ]; then
  echo "✗ 对齐未完成：机器标记 ALIGN_STATE = '${STATE:-缺失}'（需为 aligned）。"
  echo "  请先跑完 /align-survey … /align-review，清空待确认项后再 activate。promote 中止。"
  exit 1
fi

# ---- 闸门 2: 规则文件存在且无占位符 ----
if [ ! -f "$RULES" ]; then echo "✗ 缺少 $RULES"; exit 1; fi
if grep -q '{{' "$RULES"; then echo "✗ $RULES 仍含未替换占位符 {{...}}，中止。"; exit 1; fi

# ---- 备份已有 AI 配置（绝不静默覆盖）----
mkdir -p "$BACKUP"
for f in CLAUDE.md AGENTS.md .github/copilot-instructions.md; do
  if [ -e "$PROJECT_ROOT/$f" ]; then
    mkdir -p "$BACKUP/$(dirname "$f")"; cp -R "$PROJECT_ROOT/$f" "$BACKUP/$f"
    echo "  备份 $f"
  fi
done
if [ -d "$PROJECT_ROOT/.github/instructions" ]; then
  cp -R "$PROJECT_ROOT/.github/instructions" "$BACKUP/.github-instructions"; echo "  备份 .github/instructions/"
fi
echo "==> 已有配置备份到: $BACKUP"

mkdir -p "$PROJECT_ROOT/.github/instructions" "$PROJECT_ROOT/.github/prompts" "$PROJECT_ROOT/.vscode"

# ---- 装配工具: 用 .tpl 头 + aligned-rules.md 体 ----
assemble () {  # $1=模板 $2=输出
  { sed "s#{{INFRA_DIR}}#$INFRA_REL#g" "$1"; echo; echo "<!-- ↓↓↓ 由 project/aligned-rules.md 装配，请勿手改本文件；改源后重跑 promote.sh ↓↓↓ -->"; echo; cat "$RULES"; } > "$2"
  echo "  生成 $2"
}

# CLAUDE.md（根）
assemble "$SCRIPT_DIR/CLAUDE.md.tpl" "$PROJECT_ROOT/CLAUDE.md"
# AGENTS.md（根）
assemble "$SCRIPT_DIR/AGENTS.md.tpl" "$PROJECT_ROOT/AGENTS.md"

# .github/copilot-instructions.md（薄版优先用 project 的，没有则用 tpl+rules）
if [ -f "$PROJECT_DIR/copilot-instructions.md" ]; then
  cp "$PROJECT_DIR/copilot-instructions.md" "$PROJECT_ROOT/.github/copilot-instructions.md"
  echo "  生成 .github/copilot-instructions.md (project 薄版)"
else
  assemble "$SCRIPT_DIR/copilot-instructions.md.tpl" "$PROJECT_ROOT/.github/copilot-instructions.md"
fi

# 层 instructions
if compgen -G "$PROJECT_DIR/instructions/*.instructions.md" > /dev/null; then
  cp "$PROJECT_DIR"/instructions/*.instructions.md "$PROJECT_ROOT/.github/instructions/"; echo "  拷 instructions/*"
fi
# 工作流 prompts（Copilot slash）
if compgen -G "$INFRA_DIR/universal/prompts/workflow/*.prompt.md" > /dev/null; then
  cp "$INFRA_DIR"/universal/prompts/workflow/*.prompt.md "$PROJECT_ROOT/.github/prompts/"; echo "  拷 workflow prompts"
fi

# ---- .vscode/settings.json 合并（开 Copilot 开关）----
SNIP="$SCRIPT_DIR/settings.snippet.json"
DEST="$PROJECT_ROOT/.vscode/settings.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$DEST" "$SNIP" <<'PY'
import json,sys,os
dest,snip=sys.argv[1],sys.argv[2]
base=json.load(open(dest)) if os.path.exists(dest) else {}
base.update(json.load(open(snip)))
json.dump(base,open(dest,'w'),indent=2,ensure_ascii=False)
print("  合并 .vscode/settings.json")
PY
else
  echo "  ⚠ 未找到 python3，请手动把 $SNIP 内容并入 $DEST"
fi

echo "==> ✅ 生效完成。三个工具现按本项目对齐规则工作。"
echo "    回滚：从 $BACKUP 恢复。改规则：改 project/ 源后重跑本脚本。"
