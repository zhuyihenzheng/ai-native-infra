#!/usr/bin/env bash
# verify.sh — 一键验证入口（macOS/Linux/Git Bash）。命令正本在 verify.conf；Windows 用 verify.cmd。
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$DIR/verify.conf"
[ -f "$CONF" ] || { echo "✗ 缺少 $CONF" >&2; exit 2; }

VERIFY_CMD="$(sed -n 's/^UNIX=//p' "$CONF" | head -n1)"
if [ -z "$VERIFY_CMD" ]; then
  echo "✗ 未对齐：verify.conf 的 UNIX= 尚未填充。先运行 /onboard（其第 5 步会固化本项目的构建/测试命令）。" >&2
  exit 2
fi

TAIL_LINES="${VERIFY_TAIL:-60}"
echo "==> $VERIFY_CMD"
LOG="$(mktemp)"
if bash -c "$VERIFY_CMD" >"$LOG" 2>&1; then
  tail -n "$TAIL_LINES" "$LOG"
  echo "✓ verify PASSED"
  touch "$DIR/.last-verify-pass"   # Stop hook（stop-verify-gate.sh）据此判断"改动后已验证"
  rm -f "$LOG"; exit 0
else
  RC=$?
  tail -n "$TAIL_LINES" "$LOG"
  echo "✗ verify FAILED (exit $RC) —— 完整日志: $LOG"
  exit "$RC"
fi
