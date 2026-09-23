#!/usr/bin/env bash
# Tests for task-brief: it accepts a <slice>.<task> id (REQ-9.1) and ends the
# brief at the next heading whose level is the same as or higher than the
# task heading -- a following task heading or the slice's own heading
# (REQ-9.2). It must also keep extracting the old, un-sliced `Task <n>` form
# so plans written before this change still work.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SDD_SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

FAILURES=0
TEST_ROOT=""

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

main() {
    echo "=== Test: task-brief ==="

    TEST_ROOT="$(mktemp -d)"
    trap cleanup EXIT

    local plan="$TEST_ROOT/plan.md"
    cat > "$plan" <<'PLAN'
# Fixture Plan

### Slice 1: First slice

#### Task 1.1: Alpha

Alpha body text.

#### Task 1.2: Bravo

Bravo body text before the fence.

```text
#### Task 9.9: Fake task inside a fence

Fake body inside a fence: this heading must not start or end a brief.
```

Bravo body text after the fence.

### Slice 2: Second slice

#### Task 2.1: Charlie

Charlie body text.

#### Task 2.2: Delta

Delta body text.
PLAN

    local old_plan="$TEST_ROOT/old-plan.md"
    cat > "$old_plan" <<'PLAN'
# Old-Form Plan

## Task 1: First thing

Do the first thing.

## Task 2: Second thing

Do the second thing.
PLAN

    # --- 1.2's brief holds its own body and stops at the slice edge ---
    local out_1_2="$TEST_ROOT/task-1.2-brief.md"
    "$SDD_SCRIPTS/task-brief" "$plan" 1.2 "$out_1_2" >/dev/null
    local body_1_2
    body_1_2="$(cat "$out_1_2")"

    if [[ "$body_1_2" == *"Bravo body text before the fence."* \
        && "$body_1_2" == *"Bravo body text after the fence."* ]]; then
        pass "brief for 1.2 contains Task 1.2's body"
    else
        fail "brief for 1.2 contains Task 1.2's body"
        echo "    got: $body_1_2"
    fi

    if [[ "$body_1_2" != *"### Slice 2"* ]]; then
        pass "brief for 1.2 does not contain the next slice heading"
    else
        fail "brief for 1.2 does not contain the next slice heading"
        echo "    got: $body_1_2"
    fi

    # --- 2.1's brief does not run into 2.2's body ---
    local out_2_1="$TEST_ROOT/task-2.1-brief.md"
    "$SDD_SCRIPTS/task-brief" "$plan" 2.1 "$out_2_1" >/dev/null
    local body_2_1
    body_2_1="$(cat "$out_2_1")"

    if [[ "$body_2_1" == *"Charlie body text."* && "$body_2_1" != *"Delta body text."* ]]; then
        pass "brief for 2.1 does not contain Task 2.2's body"
    else
        fail "brief for 2.1 does not contain Task 2.2's body"
        echo "    got: $body_2_1"
    fi

    # --- the heading inside the fence does not start a brief of its own ---
    local rc=0
    "$SDD_SCRIPTS/task-brief" "$plan" 9.9 "$TEST_ROOT/task-9.9-brief.md" >/dev/null 2>&1 || rc=$?
    if [[ "$rc" -eq 3 ]]; then
        pass "the fenced heading does not start a brief"
    else
        fail "the fenced heading does not start a brief"
        echo "    exit: $rc"
    fi

    # --- a missing id exits 3 ---
    rc=0
    "$SDD_SCRIPTS/task-brief" "$plan" 3.1 "$TEST_ROOT/task-3.1-brief.md" >/dev/null 2>&1 || rc=$?
    if [[ "$rc" -eq 3 ]]; then
        pass "a missing id 3.1 exits 3"
    else
        fail "a missing id 3.1 exits 3"
        echo "    exit: $rc"
    fi

    # --- the old, un-sliced Task <n> form still extracts ---
    local out_old="$TEST_ROOT/task-2-brief.md"
    "$SDD_SCRIPTS/task-brief" "$old_plan" 2 "$out_old" >/dev/null
    local body_old
    body_old="$(cat "$out_old")"

    if [[ "$body_old" == *"Do the second thing."* && "$body_old" != *"Do the first thing."* ]]; then
        pass "the old form 'Task 2' still extracts"
    else
        fail "the old form 'Task 2' still extracts"
        echo "    got: $body_old"
    fi

    echo ""
    if [[ "$FAILURES" -ne 0 ]]; then
        echo "FAILED: $FAILURES assertion(s)."
        exit 1
    fi
    echo "PASS"
}

main "$@"
