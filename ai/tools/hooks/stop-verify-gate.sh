#!/usr/bin/env bash
# stop-verify-gate.sh — verify 收口闸门（机器强制，Stop hook）。
# 业务代码有改动、但 verify 未在改动之后通过时，阻止 agent 直接收工一次，
# 提示先跑 verify。verify 成功会 touch ai/tools/.last-verify-pass（见 verify.sh/ps1）。
set -uo pipefail

INPUT="$(cat)"
# 防死循环：本 Stop hook 已拦截过一轮则放行（Claude Code 会置 stop_hook_active）
printf '%s' "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$ROOT" 2>/dev/null || exit 0
[ -e .git ] || exit 0

# 未对齐阶段由对齐闸门负责，这里不管
grep -q 'ALIGN_STATE: aligned' ai/kb/PROJECT-FACTS.md 2>/dev/null || exit 0

# 业务代码没有未提交改动 → 放行
CHANGED="$(git status --porcelain -- src pom.xml build.gradle build.gradle.kts 2>/dev/null)"
[ -z "$CHANGED" ] && exit 0

# verify 通过标记比所有业务改动都新 → 已验证，放行
MARK="ai/tools/.last-verify-pass"
if [ -f "$MARK" ] && [ -z "$(find src -type f -newer "$MARK" 2>/dev/null | head -n1)" ]; then
  exit 0
fi

cat >&2 <<'EOF'
verify 收口闸门：业务代码有改动，但改动后 verify 尚未通过。
请运行 verify（macOS/Linux: bash ai/tools/verify.sh；Windows: ai\tools\verify.cmd）：
绿了再收工；红的把失败输出如实报告给用户后再结束。
EOF
exit 2
