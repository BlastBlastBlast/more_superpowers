#!/usr/bin/env bash
# Spec-check runner for the right-size-change-chain change: one function per
# slice appends its REQ checks, `all` runs every group. Always runs from the
# repo root regardless of the caller's working directory.
#
# Usage: check.sh {slice1|slice2|slice3|all}
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

FAILURES=0

pass() { echo "PASS $1 $2"; }
fail() {
  echo "FAIL $1 $2"
  FAILURES=$((FAILURES + 1))
}

check_req_9_2() {
  local what="task-brief accepts <slice>.<task> and stops at the slice edge"
  if (cd "$REPO_ROOT" && bash tests/claude-code/test-task-brief.sh >/dev/null 2>&1); then
    pass REQ-9.2 "$what"
  else
    fail REQ-9.2 "$what"
  fi
}

check_req_2() {
  local file="$REPO_ROOT/skills/writing-plans/SKILL.md"
  local what="slice one is the MVP; a new slice needs something new to show; no fresh-subagent-per-slice handoff"
  if grep -q 'Slice one is the MVP' "$file" \
    && grep -q 'something new to show' "$file" \
    && ! grep -q 'fresh subagent per slice' "$file"; then
    pass REQ-2 "$what"
  else
    fail REQ-2 "$what"
  fi
}

check_req_3() {
  local file="$REPO_ROOT/skills/writing-plans/SKILL.md"
  local what="task limits (3 production files, 5 steps, one test command) stated; self-review checks them; Model is a task field"
  if grep -q '3 production files' "$file" \
    && grep -q '5 steps or fewer' "$file" \
    && grep -q 'one test command' "$file" \
    && grep -q 'count its production files' "$file" \
    && grep -q '`Model` is a task field, not a slice field' "$file"; then
    pass REQ-3 "$what"
  else
    fail REQ-3 "$what"
  fi
}

check_req_4() {
  local file="$REPO_ROOT/skills/writing-plans/SKILL.md"
  local what="no 'zero context' or 'repeat the code'; each task states files, behaviour+REQ, tests+assertions, test command"
  if ! grep -qi 'zero context' "$file" \
    && ! grep -q 'repeat the code' "$file" \
    && grep -q 'the behaviour it builds and the requirement' "$file" \
    && grep -q 'what each one asserts' "$file" \
    && grep -q 'its test command' "$file"; then
    pass REQ-4 "$what"
  else
    fail REQ-4 "$what"
  fi
}

slice1() {
  check_req_9_2
  check_req_2
  check_req_3
  check_req_4
}

slice2() {
  :
}

slice3() {
  :
}

all() {
  slice1
  slice2
  slice3
}

group="${1:-}"
case "$group" in
  slice1|slice2|slice3|all)
    "$group"
    ;;
  *)
    echo "usage: check.sh {slice1|slice2|slice3|all}" >&2
    exit 2
    ;;
esac

if [ "$FAILURES" -ne 0 ]; then
  exit 1
fi
