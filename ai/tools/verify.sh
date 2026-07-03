#!/usr/bin/env bash
# verify.sh — 本项目一键验证入口（build + test），输出有界、结论明确。
# /onboard 第 5 步会把下方 VERIFY_CMD 替换成本项目实测的构建/测试命令。
set -uo pipefail

# ======== 对齐时替换本段（保持只读构建/测试：不改代码、不发布、不碰外部环境）========
VERIFY_CMD=""
# 例: VERIFY_CMD="mvn -q -DskipITs test"
# 例: VERIFY_CMD="./gradlew test --console=plain"
# ================================================================================

TAIL_LINES="${VERIFY_TAIL:-60}"

if [ -z "$VERIFY_CMD" ]; then
  echo "✗ 未对齐：verify 命令尚未固化。先运行 /onboard（其第 5 步会填入本项目的构建/测试命令）。" >&2
  exit 2
fi

echo "==> $VERIFY_CMD"
LOG="$(mktemp)"
if bash -c "$VERIFY_CMD" >"$LOG" 2>&1; then
  tail -n "$TAIL_LINES" "$LOG"
  echo "✓ verify PASSED"
  rm -f "$LOG"; exit 0
else
  RC=$?
  tail -n "$TAIL_LINES" "$LOG"
  echo "✗ verify FAILED (exit $RC)　—— 完整日志: $LOG"
  exit "$RC"
fi
