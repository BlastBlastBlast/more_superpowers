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

slice1() {
  check_req_9_2
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
