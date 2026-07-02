#!/usr/bin/env bash
# smoke-aci.sh — throwaway deployed-mode checks for the ACI layer.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/ai-infra-aci-smoke.XXXXXX)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

fail() {
  echo "✗ $*" >&2
  exit 1
}

check_contains() {
  local text="$1"
  local needle="$2"
  local label="$3"
  grep -F -- "$needle" <<<"$text" >/dev/null || fail "$label: expected [$needle]"
}

check_not_contains() {
  local text="$1"
  local needle="$2"
  local label="$3"
  if grep -F -- "$needle" <<<"$text" >/dev/null; then
    fail "$label: unexpected [$needle]"
  fi
}

prepare_project() {
  local project="$1"
  local infra_name="$2"
  mkdir -p "$project/src/main/java/demo"
  (
    cd "$project"
    git init -q
    printf '<project></project>\n' > pom.xml
    printf 'class Demo { CommonResult ok(){ return null; } }\n' > src/main/java/demo/Demo.java
    cp -R "$INFRA_DIR" "$infra_name"
    rm -rf "$infra_name/.git" "$infra_name"/_backup-*
    printf 'CommonResult in infra doc\n' > "$infra_name/INFRA-MARKER.txt"
  )
}

mark_aligned() {
  local project="$1"
  local infra_name="$2"
  perl -0pi -e 's/<!-- ALIGN_STATE: not-aligned -->/<!-- ALIGN_STATE: aligned -->/' "$project/$infra_name/project/ALIGN-STATUS.md"
  printf '# Aligned Rules — smoke\n\n- Smoke rule [confirmed]\n' > "$project/$infra_name/project/aligned-rules.md"
}

check_aci_scope() {
  local project="$1"
  local infra_name="$2"

  local state
  state="$(bash "$project/$infra_name/tools/aci.sh" state)"
  check_contains "$state" "project: $project" "$infra_name state project root"
  check_contains "$state" "exclude $infra_name/ by default" "$infra_name state search exclusion"

  local project_grep
  project_grep="$(bash "$project/$infra_name/tools/aci.sh" grep CommonResult)"
  check_contains "$project_grep" "src/main/java/demo/Demo.java" "$infra_name project grep"
  check_not_contains "$project_grep" "INFRA-MARKER" "$infra_name project grep excludes infra"

  local infra_grep
  infra_grep="$(bash "$project/$infra_name/tools/aci.sh" grep CommonResult "$infra_name")"
  check_contains "$infra_grep" "$infra_name/INFRA-MARKER.txt" "$infra_name explicit infra grep"

  local project_find
  project_find="$(bash "$project/$infra_name/tools/aci.sh" find INFRA-MARKER)"
  check_not_contains "$project_find" "INFRA-MARKER.txt" "$infra_name project find excludes infra"

  local infra_find
  infra_find="$(bash "$project/$infra_name/tools/aci.sh" find INFRA-MARKER "$infra_name")"
  check_contains "$infra_find" "$infra_name/INFRA-MARKER.txt" "$infra_name explicit infra find"
}

check_no_rg_fallback() {
  local project="$1"
  local infra_name="$2"

  local project_grep
  project_grep="$(PATH=/usr/bin:/bin bash "$project/$infra_name/tools/aci.sh" grep CommonResult)"
  check_contains "$project_grep" "src/main/java/demo/Demo.java" "$infra_name fallback grep"
  check_not_contains "$project_grep" "INFRA-MARKER" "$infra_name fallback excludes infra"

  local infra_find
  infra_find="$(PATH=/usr/bin:/bin bash "$project/$infra_name/tools/aci.sh" find INFRA-MARKER "$infra_name")"
  check_contains "$infra_find" "$infra_name/INFRA-MARKER.txt" "$infra_name fallback explicit infra find"
}

check_promote_paths() {
  local project="$1"
  local infra_name="$2"
  mark_aligned "$project" "$infra_name"
  (
    cd "$project"
    bash "$infra_name/activate/promote.sh" > "$project/promote-smoke.out"
    grep -F -- "$infra_name/tools/aci.sh" CLAUDE.md AGENTS.md .github/copilot-instructions.md >/dev/null
    grep -F -- "$infra_name/tools/aci.sh" .github/prompts/aci-task-loop.prompt.md >/dev/null
    if [ "$infra_name" != "ai-infra" ]; then
      ! grep -R 'ai-infra/tools/aci.sh' CLAUDE.md AGENTS.md .github/copilot-instructions.md .github/prompts/aci-task-loop.prompt.md >/dev/null
    fi
  )
}

run_case() {
  local infra_name="$1"
  local project="$TMP_DIR/project-$infra_name"
  mkdir -p "$project"
  prepare_project "$project" "$infra_name"
  check_aci_scope "$project" "$infra_name"
  check_no_rg_fallback "$project" "$infra_name"
  check_promote_paths "$project" "$infra_name"
  echo "✓ deployed ACI smoke passed for $infra_name"
}

run_case "ai-infra"
run_case "infra2"
echo "== ACI smoke: passed =="
