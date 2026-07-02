#!/usr/bin/env bash
# validate-ai-docs.sh — 治理校验：文件齐全 + 证据路径存在 + 占位符未残留 + 状态自洽。
# 退出码非 0 表示有问题（可挂 CI）。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$INFRA_DIR/.." && pwd)"
ERR=0
warn(){ echo "✗ $1"; ERR=1; }
ok(){ echo "✓ $1"; }
rel(){ printf '%s\n' "${1#"$INFRA_DIR"/}"; }

echo "== 1. 必需文件存在 =="
for f in \
  "$INFRA_DIR/README.md" \
  "$INFRA_DIR/project/ALIGN-STATUS.md" \
  "$INFRA_DIR/project/aligned-rules.md" \
  "$INFRA_DIR/activate/promote.sh" \
  "$INFRA_DIR/tools/aci.sh" \
  "$INFRA_DIR/tools/smoke-aci.sh" \
  "$INFRA_DIR/universal/aci/README.md" \
  "$INFRA_DIR/universal/maps/traceability.md"; do
  [ -f "$f" ] && ok "$(rel "$f")" || warn "缺文件 $f"
done

[ -x "$INFRA_DIR/tools/aci.sh" ] && ok "aci.sh 可执行" || warn "aci.sh 不可执行：请 chmod +x tools/aci.sh"
[ -x "$INFRA_DIR/tools/smoke-aci.sh" ] && ok "smoke-aci.sh 可执行" || warn "smoke-aci.sh 不可执行：请 chmod +x tools/smoke-aci.sh"
if bash -n "$INFRA_DIR/tools/aci.sh"; then
  ok "aci.sh 语法通过"
else
  warn "aci.sh 语法错误"
fi
if bash -n "$INFRA_DIR/tools/smoke-aci.sh"; then
  ok "smoke-aci.sh 语法通过"
else
  warn "smoke-aci.sh 语法错误"
fi

# 对齐状态（与 promote.sh 同一机器标记；只读第一处，避免 prose 干扰）
STATUS_FILE="$INFRA_DIR/project/ALIGN-STATUS.md"
ALIGNED=0
if [ -f "$STATUS_FILE" ]; then
  STATE="$(grep -oE 'ALIGN_STATE:[[:space:]]*[A-Za-z-]+' "$STATUS_FILE" | head -1 | sed -E 's/.*ALIGN_STATE:[[:space:]]*//')"
  [ "$STATE" = "aligned" ] && ALIGNED=1
fi

echo "== 2. 占位符未残留（仅在已对齐时强校验 project/）=="
if [ "$ALIGNED" = "1" ]; then
  if grep -rq '{{' "$INFRA_DIR/project/aligned-rules.md" 2>/dev/null; then
    warn "已对齐但 aligned-rules.md 仍含 {{占位符}}"
  else ok "aligned-rules.md 无占位符"; fi
  if grep -rqi 'PLACEHOLDER' "$INFRA_DIR/project/aligned-rules.md" 2>/dev/null; then
    warn "aligned-rules.md 仍是 PLACEHOLDER"
  fi
else
  echo "  (项目未对齐，跳过 project 占位符强校验)"
fi

echo "== 3. PROJECT-FACTS 证据路径存在性抽检 =="
FACTS="$INFRA_DIR/project/PROJECT-FACTS.md"
if [ -f "$FACTS" ] && ! grep -qi 'PLACEHOLDER' "$FACTS"; then
  # 提取形如 src/.../Xxx.java 的路径，校验存在
  grep -oE '[A-Za-z0-9_./-]+\.(java|xml|yml|yaml|sql|properties)' "$FACTS" 2>/dev/null | sort -u | while read -r p; do
    [ -e "$PROJECT_ROOT/$p" ] || echo "  ⚠ 证据路径不存在: $p"
  done
  ok "证据路径抽检完成（⚠ 为可疑项）"
else
  echo "  (PROJECT-FACTS 仍为占位，跳过)"
fi

echo "== 4. 真实 PII / 凭证泄漏粗检（fixture 与 docs）=="
LEAK=$(grep -rIlE '(password\s*=\s*[^ ]{6,}|BEGIN [A-Z ]*PRIVATE KEY|[0-9]{12,16})' \
  "$INFRA_DIR" --include='*.json' --include='*.md' --include='*.yml' 2>/dev/null \
  | grep -v 'settings.snippet.json' | grep -v 'h2:mem' || true)
if [ -n "$LEAK" ]; then echo "  ⚠ 疑似敏感内容（请人工确认）:"; echo "$LEAK" | sed 's/^/    /'; fi
ok "泄漏粗检完成"

echo
[ "$ERR" = "0" ] && echo "== 结果：通过 ==" || echo "== 结果：有问题（见上）=="
exit $ERR
