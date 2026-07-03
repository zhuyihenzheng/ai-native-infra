#!/usr/bin/env bash
# pre-edit-gate.sh — 对齐闸门（机器强制，PreToolUse: Edit|Write）。
# PROJECT-FACTS 未标 `ALIGN_STATE: aligned` 时，拦截对业务代码（src/、构建文件）的编辑。
# prose 规则会随上下文变长而衰减；这个 hook 不会。
set -uo pipefail

INPUT="$(cat)"
# 提取 file_path（不依赖 jq；解析失败则放行——闸门自身故障不能卡死工作台）
FILE="$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
[ -z "$FILE" ] && exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
FACTS="$ROOT/ai/kb/PROJECT-FACTS.md"
[ -f "$FACTS" ] || exit 0                                # 无工作台 → 不管
grep -q 'ALIGN_STATE: aligned' "$FACTS" && exit 0        # 已对齐 → 放行

case "$FILE" in
  "$ROOT"/demo/*|demo/*) exit 0 ;;                       # 模板仓库自带的靶场不受闸门约束
  */src/main/*|*/src/test/*|src/main/*|src/test/*|*pom.xml|*build.gradle|*build.gradle.kts|*settings.gradle*)
    cat >&2 <<EOF
対齐闸门拦截：本项目尚未对齐（ai/kb/PROJECT-FACTS.md 缺 'ALIGN_STATE: aligned'）。
未对齐状态下禁止修改业务代码：$FILE
请先运行 /onboard 完成对齐（勘探事实 → 摘样例 → 定契约 → 人工裁决 → 生效）。
EOF
    exit 2
    ;;
esac
exit 0
