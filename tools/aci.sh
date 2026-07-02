#!/usr/bin/env bash
# aci.sh — domain-specific Agent-Computer Interface for deployed ai-infra.
#
# Primary value: deterministic domain gates the agent harness cannot provide
# natively — alignment state, one-command project verification, doc governance,
# traceability search, evidence checks. find/grep/view are bounded fallbacks
# for shell-only contexts; agents with native search/read tools should prefer
# those for observation. Editing always uses the agent's native editor.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INFRA_REL="$(basename "$INFRA_DIR")"

if [ -n "${ACI_PROJECT_ROOT:-}" ]; then
  PROJECT_ROOT="$(cd "$ACI_PROJECT_ROOT" && pwd)"
elif [ "$INFRA_REL" = "ai-native-infra" ]; then
  # Template-development mode: keep commands scoped to this repository.
  PROJECT_ROOT="$INFRA_DIR"
else
  # Deployed mode: any renamed infra directory lives under the target project.
  PROJECT_ROOT="$(cd "$INFRA_DIR/.." && pwd)"
fi

if [ "$PROJECT_ROOT" != "$INFRA_DIR" ] && [[ "$INFRA_DIR" == "$PROJECT_ROOT"/* ]]; then
  INFRA_PROJECT_REL="${INFRA_DIR#"$PROJECT_ROOT"/}"
else
  INFRA_PROJECT_REL=""
fi

MAX_VIEW_LINES="${ACI_VIEW_LINES:-100}"
MAX_SEARCH_HITS="${ACI_SEARCH_HITS:-50}"

die() {
  echo "✗ $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found on PATH: $1"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ok_empty() {
  echo "✓ command ran successfully and produced no output"
}

usage() {
  cat <<'USAGE'
Usage: tools/aci.sh <command> [args]

Domain gates (things your agent harness cannot know natively — use these):
  help                         Show this help.
  state                        Summarize project root, alignment state, live files, git status.
  verify                       Run this project's aligned build/test entry (project/verify.sh), bounded output.
  validate                     Run ai-infra/tools/validate-ai-docs.sh.
  promote-check                Report activation gates without writing live files.
  trace <ID>                   Search traceability ID occurrences (change blast radius).
  evidence <path:line>         Check that an evidence citation resolves to a file line.
  diff                         Summarize git status and changed files.

Fallback observation (prefer your agent's native search/read tools when it has them):
  find <name-fragment> [path]  Bounded filename search under project root or path.
  grep <pattern> [path]        Bounded text search under project root or path.
  view <path> [start] [count]  Line-numbered bounded file view; default count=100.

Environment:
  ACI_PROJECT_ROOT             Override target project root.
  ACI_VIEW_LINES               Max lines for view (default 100).
  ACI_SEARCH_HITS              Max results for find/grep/trace (default 50).
  ACI_VERIFY_TAIL              Max trailing lines shown from verify output (default 60).
USAGE
}

align_state() {
  local status="$INFRA_DIR/project/ALIGN-STATUS.md"
  if [ ! -f "$status" ]; then
    echo "missing"
    return
  fi
  grep -oE 'ALIGN_STATE:[[:space:]]*[A-Za-z-]+' "$status" | head -1 | sed -E 's/.*ALIGN_STATE:[[:space:]]*//' || true
}

relpath() {
  local path="$1"
  case "$path" in
    "$PROJECT_ROOT"/*) printf '%s\n' "${path#"$PROJECT_ROOT"/}" ;;
    "$INFRA_DIR"/*) printf '%s/%s\n' "$INFRA_REL" "${path#"$INFRA_DIR"/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

resolve_existing_file() {
  local input="$1"
  local candidate=""
  if [ -f "$input" ]; then
    candidate="$input"
  elif [ -f "$PROJECT_ROOT/$input" ]; then
    candidate="$PROJECT_ROOT/$input"
  elif [ -f "$INFRA_DIR/$input" ]; then
    candidate="$INFRA_DIR/$input"
  else
    die "file not found: $input"
  fi

  local dir base abs
  dir="$(cd "$(dirname "$candidate")" && pwd)"
  base="$(basename "$candidate")"
  abs="$dir/$base"
  case "$abs" in
    "$PROJECT_ROOT"/*|"$INFRA_DIR"/*) printf '%s\n' "$abs" ;;
    *) die "refusing to read outside project/infra root: $input" ;;
  esac
}

resolve_existing_scope() {
  local input="$1"
  local candidate=""
  if [ -e "$input" ]; then
    candidate="$input"
  elif [ -e "$PROJECT_ROOT/$input" ]; then
    candidate="$PROJECT_ROOT/$input"
  elif [ -e "$INFRA_DIR/$input" ]; then
    candidate="$INFRA_DIR/$input"
  else
    die "scope not found: $input"
  fi

  local dir base abs
  dir="$(cd "$(dirname "$candidate")" && pwd)"
  base="$(basename "$candidate")"
  abs="$dir/$base"
  case "$abs" in
    "$PROJECT_ROOT"|"$PROJECT_ROOT"/*|"$INFRA_DIR"|"$INFRA_DIR"/*) printf '%s\n' "$abs" ;;
    *) die "refusing to search outside project/infra root: $input" ;;
  esac
}

bounded_lines() {
  local limit="$1"
  shift
  local tmp status
  tmp="$(mktemp)"
  set +e
  "$@" > "$tmp" 2>&1
  status=$?
  set -e
  local count
  count="$(wc -l < "$tmp" | tr -d ' ')"
  if [ "$status" -ne 0 ]; then
    if [ "$status" -eq 1 ] && [ "$count" -eq 0 ]; then
      rm -f "$tmp"
      ok_empty
      return 0
    fi
    cat "$tmp"
    rm -f "$tmp"
    return "$status"
  fi
  if [ "$count" -eq 0 ]; then
    rm -f "$tmp"
    ok_empty
    return
  fi
  if [ "$count" -gt "$limit" ]; then
    sed -n "1,${limit}p" "$tmp"
    echo "⚠ output truncated at ${limit}/${count} lines; refine the query."
  else
    cat "$tmp"
  fi
  rm -f "$tmp"
}

cmd_state() {
  echo "== ACI state =="
  echo "infra:   $INFRA_DIR"
  echo "project: $PROJECT_ROOT"
  echo "align:   $(align_state)"
  if [ -n "$INFRA_PROJECT_REL" ]; then
    echo "search:  project-wide find/grep/trace exclude $INFRA_PROJECT_REL/ by default"
  fi
  echo
  echo "== live entry files =="
  for f in CLAUDE.md AGENTS.md .github/copilot-instructions.md .vscode/settings.json; do
    if [ -e "$PROJECT_ROOT/$f" ]; then
      echo "✓ $f"
    else
      echo "- $f"
    fi
  done
  echo
  echo "== git status =="
  if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    bounded_lines 40 git -C "$PROJECT_ROOT" status --short
  else
    echo "not a git worktree"
  fi
}

cmd_promote_check() {
  echo "== promote gates =="
  local state
  state="$(align_state)"
  [ "$state" = "aligned" ] && echo "✓ ALIGN_STATE aligned" || echo "✗ ALIGN_STATE is ${state:-missing}"

  local rules="$INFRA_DIR/project/aligned-rules.md"
  [ -f "$rules" ] && echo "✓ project/aligned-rules.md exists" || echo "✗ missing project/aligned-rules.md"
  if [ -f "$rules" ]; then
    if grep -q '{{' "$rules"; then
      echo "✗ aligned-rules.md still contains {{ placeholders }}"
    else
      echo "✓ aligned-rules.md has no {{ placeholders }}"
    fi
    if grep -qi 'PLACEHOLDER' "$rules"; then
      echo "✗ aligned-rules.md still contains PLACEHOLDER"
    else
      echo "✓ aligned-rules.md is not placeholder text"
    fi
  fi

  if [ -e "$PROJECT_ROOT/pom.xml" ] || [ -e "$PROJECT_ROOT/build.gradle" ] || [ -e "$PROJECT_ROOT/build.gradle.kts" ] || [ "$PROJECT_ROOT" = "$INFRA_DIR" ]; then
    echo "✓ target root shape accepted"
  else
    echo "✗ target root lacks pom.xml / build.gradle(.kts)"
  fi
}

cmd_find() {
  [ "${1:-}" != "" ] || die "find requires a filename fragment"
  local query="$1"
  local scope="${2:-$PROJECT_ROOT}"
  scope="$(resolve_existing_scope "$scope")"
  if has_cmd rg; then
    if [ "$scope" = "$PROJECT_ROOT" ]; then
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && if [ -n \"\$2\" ]; then rg --files --glob \"!\$2/**\"; else rg --files; fi | grep -i -- \"\$1\"" "$PROJECT_ROOT" "$query" "$INFRA_PROJECT_REL"
    elif [[ "$scope" == "$PROJECT_ROOT"/* ]]; then
      local rel_scope="${scope#"$PROJECT_ROOT"/}"
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && rg --files \"\$2\" | grep -i -- \"\$1\"" "$PROJECT_ROOT" "$query" "$rel_scope"
    else
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "rg --files \"\$0\" | grep -i -- \"\$1\"" "$scope" "$query"
    fi
  else
    need_cmd find
    need_cmd grep
    if [ "$scope" = "$PROJECT_ROOT" ]; then
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && find . -type f ! -path './.git/*' ! -path './target/*' ! -path './node_modules/*' ! -path \"./\$2/*\" | sed 's#^\\./##' | grep -i -- \"\$1\"" "$PROJECT_ROOT" "$query" "$INFRA_PROJECT_REL"
    elif [[ "$scope" == "$PROJECT_ROOT"/* ]]; then
      local rel_scope="${scope#"$PROJECT_ROOT"/}"
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && find \"\$2\" -type f ! -path './.git/*' ! -path './target/*' ! -path './node_modules/*' | sed 's#^\\./##' | grep -i -- \"\$1\"" "$PROJECT_ROOT" "$query" "$rel_scope"
    else
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "find \"\$0\" -type f | grep -i -- \"\$1\"" "$scope" "$query"
    fi
  fi
}

cmd_grep() {
  [ "${1:-}" != "" ] || die "grep requires a pattern"
  local pattern="$1"
  local scope="${2:-$PROJECT_ROOT}"
  scope="$(resolve_existing_scope "$scope")"
  if [ "$scope" = "$PROJECT_ROOT" ]; then
    if has_cmd rg; then
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && if [ -n \"\$2\" ]; then rg -n --no-heading --color never --glob \"!\$2/**\" -- \"\$1\" .; else rg -n --no-heading --color never -- \"\$1\" .; fi" "$PROJECT_ROOT" "$pattern" "$INFRA_PROJECT_REL"
    else
      need_cmd find
      need_cmd grep
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && find . -type f ! -path './.git/*' ! -path './target/*' ! -path './node_modules/*' ! -path \"./\$2/*\" -exec grep -nH -I -- \"\$1\" {} +" "$PROJECT_ROOT" "$pattern" "$INFRA_PROJECT_REL"
    fi
  elif [[ "$scope" == "$PROJECT_ROOT"/* ]]; then
    local rel_scope="${scope#"$PROJECT_ROOT"/}"
    if has_cmd rg; then
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && rg -n --no-heading --color never -- \"\$1\" \"\$2\"" "$PROJECT_ROOT" "$pattern" "$rel_scope"
    else
      need_cmd find
      need_cmd grep
      bounded_lines "$MAX_SEARCH_HITS" bash -c \
        "cd \"\$0\" && find \"\$2\" -type f ! -path './.git/*' ! -path './target/*' ! -path './node_modules/*' -exec grep -nH -I -- \"\$1\" {} +" "$PROJECT_ROOT" "$pattern" "$rel_scope"
    fi
  else
    if has_cmd rg; then
      bounded_lines "$MAX_SEARCH_HITS" rg -n --no-heading --color never -- "$pattern" "$scope"
    else
      need_cmd find
      need_cmd grep
      bounded_lines "$MAX_SEARCH_HITS" find "$scope" -type f -exec grep -nH -I -- "$pattern" {} +
    fi
  fi
}

cmd_view() {
  [ "${1:-}" != "" ] || die "view requires a path"
  local file start count end
  file="$(resolve_existing_file "$1")"
  start="${2:-1}"
  count="${3:-$MAX_VIEW_LINES}"
  [[ "$start" =~ ^[0-9]+$ ]] || die "start must be a positive integer"
  [[ "$count" =~ ^[0-9]+$ ]] || die "count must be a positive integer"
  [ "$start" -ge 1 ] || die "start must be >= 1"
  if [ "$count" -gt "$MAX_VIEW_LINES" ]; then
    count="$MAX_VIEW_LINES"
  fi
  end=$((start + count - 1))
  echo "== $(relpath "$file"):${start}-${end} =="
  sed -n "${start},${end}p" "$file" | nl -ba -v "$start"
}

cmd_trace() {
  [ "${1:-}" != "" ] || die "trace requires an ID"
  cmd_grep "$1" "$PROJECT_ROOT"
}

cmd_evidence() {
  [ "${1:-}" != "" ] || die "evidence requires path:line"
  local ref="$1"
  local path="${ref%:*}"
  local line="${ref##*:}"
  [ "$path" != "$ref" ] || die "evidence must look like path:line"
  [[ "$line" =~ ^[0-9]+$ ]] || die "line must be numeric: $ref"
  local file
  file="$(resolve_existing_file "$path")"
  local total
  total="$(wc -l < "$file" | tr -d ' ')"
  if [ "$line" -le "$total" ]; then
    echo "✓ $(relpath "$file"):$line exists"
    sed -n "${line}p" "$file" | nl -ba -v "$line"
  else
    die "$(relpath "$file") has only $total lines, citation asked for $line"
  fi
}

cmd_verify() {
  local script="$INFRA_DIR/project/verify.sh"
  local tail_lines="${ACI_VERIFY_TAIL:-60}"
  if [ ! -f "$script" ]; then
    die "missing $INFRA_REL/project/verify.sh — 对齐时应把本项目的 build/test 命令固化成这个脚本（见 /align-activate），否则请按 aligned-rules 命令段手动验证"
  fi
  echo "== verify: $INFRA_REL/project/verify.sh (cwd: $PROJECT_ROOT) =="
  local tmp status count
  tmp="$(mktemp)"
  set +e
  ( cd "$PROJECT_ROOT" && bash "$script" ) > "$tmp" 2>&1
  status=$?
  set -e
  count="$(wc -l < "$tmp" | tr -d ' ')"
  if [ "$count" -gt "$tail_lines" ]; then
    echo "…(showing last ${tail_lines}/${count} output lines)"
    tail -n "$tail_lines" "$tmp"
  else
    cat "$tmp"
  fi
  rm -f "$tmp"
  if [ "$status" -eq 0 ]; then
    echo "✓ verify passed (exit 0)"
  else
    echo "✗ verify failed (exit $status)"
  fi
  return "$status"
}

cmd_diff() {
  if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    die "project root is not a git worktree: $PROJECT_ROOT"
  fi
  echo "== git status --short =="
  bounded_lines 80 git -C "$PROJECT_ROOT" status --short
  echo
  echo "== changed files =="
  bounded_lines 80 git -C "$PROJECT_ROOT" diff --name-status
  echo
  echo "== diff stat =="
  bounded_lines 80 git -C "$PROJECT_ROOT" diff --stat
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  help|-h|--help) usage ;;
  state) cmd_state ;;
  verify) cmd_verify ;;
  validate) bash "$INFRA_DIR/tools/validate-ai-docs.sh" ;;
  promote-check) cmd_promote_check ;;
  find) cmd_find "$@" ;;
  grep) cmd_grep "$@" ;;
  view) cmd_view "$@" ;;
  trace) cmd_trace "$@" ;;
  evidence) cmd_evidence "$@" ;;
  diff) cmd_diff ;;
  *) die "unknown command: $cmd (try: tools/aci.sh help)" ;;
esac
