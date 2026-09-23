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

check_req_4_2() {
  local file="$REPO_ROOT/skills/writing-plans/SKILL.md"
  local what="the task template keeps an Interfaces block (Consumes/Produces) for REQ-4.2's exact signatures"
  if grep -q '\*\*Interfaces:\*\*' "$file" \
    && grep -q 'Consumes:' "$file" \
    && grep -q 'Produces:' "$file"; then
    pass REQ-4.2 "$what"
  else
    fail REQ-4.2 "$what"
  fi
}

slice1() {
  check_req_9_2
  check_req_2
  check_req_3
  check_req_4
  check_req_4_2
}

check_req_5() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local ep="$REPO_ROOT/skills/executing-plans/SKILL.md"
  local what="per-task cluster has no reviewer node; the session runs the task's test command after each task and sends a failure back to the same implementer; executing-plans runs a slice's tasks in order with tests after each"
  local per_task_cluster
  per_task_cluster="$(sed -n '/subgraph cluster_per_task {/,/^    }/p' "$sdd")"
  if ! grep -qi 'reviewer' <<<"$per_task_cluster" \
    && grep -q "Run the task's test command" "$sdd" \
    && grep -q 'send failure back to same implementer' "$sdd" \
    && grep -q 'no reviewer runs per task' "$sdd" \
    && grep -q "Run a slice's tasks in order" "$ep" \
    && grep -q 'tests when it ends' "$ep"; then
    pass REQ-5 "$what"
  else
    fail REQ-5 "$what"
  fi
}

check_req_6() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="slice checkpoint runs the demo then dispatches one slice reviewer over the range from the commit before the slice's first task; slice one's review is dispatched alongside the human demo; Final Review still uses the most capable model, ONE fix dispatch and one scoped re-review (REQ-6.4), and carries no mutation marker"
  local per_slice_cluster final_review_section
  per_slice_cluster="$(sed -n '/subgraph cluster_per_slice {/,/^    }/p' "$sdd")"
  final_review_section="$(awk '/^## Final Review$/,/^## Finish$/' "$sdd" | tr '\n' ' ' | tr -s ' ')"
  if grep -q 'Run the slice demonstration command' <<<"$per_slice_cluster" \
    && grep -q 'dispatch task reviewer' <<<"$per_slice_cluster" \
    && grep -q 'also record a slice' "$sdd" \
    && grep -q "slice's first task" "$sdd" \
    && grep -q 'at the same time as you show your human partner the demo output' "$sdd" \
    && grep -q 'wait for both' "$sdd" \
    && grep -q 'most capable available model' <<<"$final_review_section" \
    && grep -q 'dispatch ONE fix subagent' <<<"$final_review_section" \
    && grep -q 'exactly one scoped re-review' <<<"$final_review_section" \
    && ! grep -q 'FINAL_REVIEW' <<<"$final_review_section"; then
    pass REQ-6 "$what"
  else
    fail REQ-6 "$what"
  fi
}

check_req_7() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="fix loop caps at 2 rounds (round 1 resumes the task's implementer, round 2 a fresh implementer one tier up); no text names rounds 3, 4 or 5, 'of 5', 'R≤3' or 'R≥4'; a trivial fix skips the re-review, a code/test-body fix gets a scoped re-review"
  if grep -q 'Fix round R of 2' "$sdd" \
    && grep -q 'R = 2?' "$sdd" \
    && grep -q "Round 1 — resume the implementer of the task that owns the finding" "$sdd" \
    && grep -q 'Round 2 — dispatch a fresh implementer one tier above' "$sdd" \
    && grep -q 'skip the re-review' "$sdd" \
    && grep -q 'gets a scoped re-review' "$sdd" \
    && ! grep -qiE 'rounds? (3|4|5)\b' "$sdd" \
    && ! grep -q 'of 5' "$sdd" \
    && ! grep -q 'R≤3' "$sdd" \
    && ! grep -q 'R≥4' "$sdd"; then
    pass REQ-7 "$what"
  else
    fail REQ-7 "$what"
  fi
}

check_req_9_3() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="ledger records 'Task <slice>.<task>: complete' and 'Slice <N>: complete'; resume rule starts at the slice review of a slice whose tasks are all complete and that has no slice-complete line"
  local setup_rule
  setup_rule="$(tr '\n' ' ' <"$sdd")"
  if grep -q 'Task <slice>.<task>: complete' "$sdd" \
    && grep -q 'Slice <N>: complete' "$sdd" \
    && grep -q 'resumes at its slice review' "$sdd" \
    && grep -qE 'no.{0,10}`Slice <N>: complete`.{0,10}line resumes at its slice review' <<<"$setup_rule"; then
    pass REQ-9.3 "$what"
  else
    fail REQ-9.3 "$what"
  fi
}

check_f1() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what='rationalization row reads "The fix touched code, but it was small" -> "Any change to code or test bodies gets a scoped re-review."'
  if grep -q 'The fix touched code, but it was small' "$sdd" \
    && grep -q 'Any change to code or test bodies gets a scoped re-review' "$sdd" \
    && ! grep -q 'The fix was small, skip the re-review' "$sdd"; then
    pass F1 "$what"
  else
    fail F1 "$what"
  fi
}

check_req_8_1() {
  local file="$REPO_ROOT/skills/requesting-code-review/code-reviewer.md"
  local what="code-reviewer.md allows at most 3 reverted mutations in the working tree for a named risk, never while another agent writes to the tree, and ends with git status"
  local X
  X="$(tr '\n' ' ' <"$file" | tr -s ' ')"
  if grep -q 'at most 3 mutations' <<<"$X" \
    && grep -q 'a risk you name' <<<"$X" \
    && grep -q 'revert it before the next' <<<"$X" \
    && grep -q 'never commit, stage, stash, or move HEAD' <<<"$X" \
    && grep -q 'while another agent is writing to this tree' <<<"$X" \
    && grep -q 'End your report with the output of `git status --porcelain`' <<<"$X" \
    && grep -q 'A mutation that no test catches is a finding' <<<"$X" \
    && ! grep -q 'Do not mutate code to test a hypothesis' <<<"$X"; then
    pass REQ-8.1 "$what"
  else
    fail REQ-8.1 "$what"
  fi
}

check_req_8_2() {
  local trp="$REPO_ROOT/skills/subagent-driven-development/task-reviewer-prompt.md"
  local rrp="$REPO_ROOT/skills/subagent-driven-development/re-review-prompt.md"
  local what="the slice reviewer prompt allows the same bounded, reverted mutations and says it reviews a slice; the re-review prompt still forbids mutation"
  local X rrp_flat
  X="$(tr '\n' ' ' <"$trp" | tr -s ' ')"
  rrp_flat="$(tr '\n' ' ' <"$rrp" | tr -s ' ')"
  if grep -q 'at most 3 mutations' <<<"$X" \
    && grep -q 'a risk you name' <<<"$X" \
    && grep -q 'revert it before the next' <<<"$X" \
    && grep -q 'never commit, stage, stash, or move HEAD' <<<"$X" \
    && grep -q 'while another agent is writing to this tree' <<<"$X" \
    && grep -q 'End your report with the output of `git status --porcelain`' <<<"$X" \
    && grep -q 'A mutation that no test catches is a finding' <<<"$X" \
    && grep -q 'reviews a slice' <<<"$X" \
    && grep -q 'not even to test whether a suspected defect is actually uncaught' <<<"$rrp_flat" \
    && grep -q 'report it as a finding instead of making it' <<<"$rrp_flat"; then
    pass REQ-8.2 "$what"
  else
    fail REQ-8.2 "$what"
  fi
}

check_req_8_5() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="SDD records git status before every review and restores only the paths a review changed before the next dispatch"
  local X
  X="$(tr '\n' ' ' <"$sdd" | tr -s ' ')"
  if grep -q 'Keep the tree clean around every review' <<<"$X" \
    && grep -q 'record `git status --porcelain`' <<<"$X" \
    && grep -q 'restore only that path' <<<"$X" \
    && grep -q 'tree restored after review' <<<"$X"; then
    pass REQ-8.5 "$what"
  else
    fail REQ-8.5 "$what"
  fi
}

check_req_8_3() {
  local what="writing-good-tests.md is unchanged from main"
  if (cd "$REPO_ROOT" && git diff --quiet main -- skills/test-driven-development/writing-good-tests.md); then
    pass REQ-8.3 "$what"
  else
    fail REQ-8.3 "$what"
  fi
}

check_i3() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="DONE_WITH_CONCERNS runs the task's test command and appends the completion line (handled as DONE), instead of routing to a per-task review that no longer exists"
  local done_concerns
  done_concerns="$(grep '^\*\*DONE_WITH_CONCERNS:\*\*' "$sdd" || true)"
  if grep -q 'handle it as DONE' <<<"$done_concerns" \
    && ! grep -q 'proceed to review' <<<"$done_concerns" \
    && ! grep -q 'before review' <<<"$done_concerns"; then
    pass I3 "$what"
  else
    fail I3 "$what"
  fi
}

check_i4() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="the slice BASE is ledgered ('Slice <N>: base <sha7>') when recorded, the Setup resume rule and the review-package step read it from that ledger line, and the completion formats name <base7>..<head7> again"
  local flat
  flat="$(tr '\n' ' ' <"$sdd" | tr -s ' ')"
  if grep -q "append \`Slice <N>: base <sha7>\` to the" <<<"$flat" \
    && grep -q "reading SLICE_BASE from that slice's \`Slice <N>: base <sha7>\` ledger line" <<<"$flat" \
    && grep -q "on resume, read it from the \`Slice <N>: base <sha7>\` ledger line" <<<"$flat" \
    && grep -q 'Task <slice>.<task>: complete (commits <base7>..<head7>, tests pass)' <<<"$flat" \
    && grep -q 'Slice <N>: fix round <R>/2 (<X> addressed, <Y> open — <finding one-liners>; commits <base7>..<head7>)' <<<"$flat" \
    && grep -q 'Slice <N>: complete (commits <base7>..<head7>, review clean)' <<<"$flat" \
    && ! grep -q 'commits <a7>..<b7>' <<<"$flat"; then
    pass I4 "$what"
  else
    fail I4 "$what"
  fi
}

check_i1() {
  local file="$REPO_ROOT/skills/subagent-driven-development/task-reviewer-prompt.md"
  local what="the slice reviewer template takes a list of briefs and a list of reports (one per task), says 'Review Slice N', and checks each task's brief against the diff"
  local flat
  flat="$(tr '\n' ' ' <"$file" | tr -s ' ')"
  if grep -q 'description: "Review Slice N' <<<"$flat" \
    && grep -q '\[BRIEF_FILES\]' <<<"$flat" \
    && grep -q '\[REPORT_FILES\]' <<<"$flat" \
    && grep -q 'bind this slice' <<<"$flat" \
    && grep -q 'Check the diff against every task brief in the slice' <<<"$flat" \
    && grep -q 'The implementers already ran the tests' <<<"$flat" \
    && ! grep -q '\[BRIEF_FILE\]' <<<"$flat" \
    && ! grep -q '\[REPORT_FILE\]' <<<"$flat"; then
    pass I1 "$what"
  else
    fail I1 "$what"
  fi
}

check_i2() {
  local what="no skill carries a FINAL_REVIEW marker or a mutation licence (REQ-8.4 withdrawn)"
  if ! grep -rq 'FINAL_REVIEW' "$REPO_ROOT/skills" \
    && ! grep -rq 'real code mutation, in a temporary worktree' "$REPO_ROOT/skills"; then
    pass I2 "$what"
  else
    fail I2 "$what"
  fi
}

slice2() {
  check_req_5
  check_req_6
  check_req_7
  check_req_9_3
  check_f1
  check_req_8_1
  check_req_8_2
  check_req_8_5
  check_req_8_3
  check_i3
  check_i4
  check_i1
  check_i2
}

# --- Final whole-branch review fixes (final-review.md Important findings) ---

check_final_flatplan() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="a plan with no ### Slice headings runs each task as its own slice: its own test run, its own slice review, its own Slice <N> ledger lines"
  if grep -q 'no `### Slice` headings runs each task as its own slice' "$sdd" \
    && grep -q 'its own test run, its own slice review, and its own `Slice <N>` ledger' "$sdd"; then
    pass I1-final "$what"
  else
    fail I1-final "$what"
  fi
}

check_final_model_task() {
  local sdd="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
  local what="Model Selection reads the model from the task (REQ-3.5, matches writing-plans), not the slice"
  if grep -q 'Read the model from the task' "$sdd" \
    && grep -q 'names a model for every task a subagent' "$sdd" \
    && ! grep -q 'Read the model from the slice' "$sdd"; then
    pass I4-final "$what"
  else
    fail I4-final "$what"
  fi
}

check_final_review_mandate() {
  local file="$REPO_ROOT/skills/requesting-code-review/SKILL.md"
  local what="review is mandatory after each SDD slice and at its final review (not after each task)"
  if grep -q 'After each slice in subagent-driven development' "$file" \
    && ! grep -q 'After each task in subagent-driven development' "$file"; then
    pass I5-final "$what"
  else
    fail I5-final "$what"
  fi
}

check_final_evalafter() {
  local file="$REPO_ROOT/docs/changes/2026-09-right-size-change-chain/eval-after.md"
  local what="sdd-svelte-todo's per-task-review criterion is classified as removed on purpose (REQ-5); the four other per-task-review scenarios carry the same classification"
  if grep -q 'removed on purpose: REQ-5' "$file" \
    && grep -q 'sdd-quality-reviewer-catches-planted-defect' "$file" \
    && grep -q 'sdd-survives-compaction' "$file" \
    && grep -q 'sdd-escalates-broken-plan' "$file" \
    && grep -q 'sdd-rejects-extra-features' "$file"; then
    pass I2-final "$what"
  else
    fail I2-final "$what"
  fi
}

finalreview() {
  check_final_flatplan
  check_final_model_task
  check_final_review_mandate
  check_final_evalafter
}

check_req_1_1() {
  local file="$REPO_ROOT/skills/writing-specs/SKILL.md"
  local what="a rule requires every requirement to name its source, as a *Source:* line beside *Proof:*"
  if grep -q 'Every requirement MUST name its source' "$file" \
    && grep -q '\*Source:\*' "$file"; then
    pass REQ-1.1 "$what"
  else
    fail REQ-1.1 "$what"
  fi
}

check_req_1_2() {
  local file="$REPO_ROOT/skills/writing-specs/SKILL.md"
  local what="a rule limits requirements to observable behaviour; the prose actor in a repository is the file or skill, and observable behaviour is what it makes an agent do"
  local flat
  flat="$(tr '\n' ' ' <"$file" | tr -s ' ')"
  if grep -q 'MUST state behaviour that a user, a caller or a respondent can observe' <<<"$flat" \
    && grep -q 'the actor is the file or' <<<"$flat" \
    && grep -q 'The observable behaviour is what that file or skill' <<<"$flat"; then
    pass REQ-1.2 "$what"
  else
    fail REQ-1.2 "$what"
  fi
}

check_req_1_3() {
  local file="$REPO_ROOT/skills/writing-specs/SKILL.md"
  local what="a sub-requirement is limited to a named edge case; an edge case the author finds goes to open questions, not a sub-requirement"
  if grep -q 'A sub-requirement MUST cover an edge case that' "$file" \
    && grep -q 'the intent or the interview named' "$file" \
    && grep -q 'Open questions carried from intent' "$file"; then
    pass REQ-1.3 "$what"
  else
    fail REQ-1.3 "$what"
  fi
}

check_req_1_4() {
  local file="$REPO_ROOT/skills/writing-specs/SKILL.md"
  local what="the spec omits an empty optional section; the template marks Flagged concerns and Design notes optional and omitted when empty"
  if grep -q 'Omit an optional section that has no content' "$file" \
    && grep -q 'Flagged concerns and Design notes are optional' "$file" \
    && grep -q 'Optional. Omit this section when it has no content' "$file"; then
    pass REQ-1.4 "$what"
  else
    fail REQ-1.4 "$what"
  fi
}

check_req_1_5() {
  local file="$REPO_ROOT/skills/writing-specs/SKILL.md"
  local what="the spec author reports the size as 'N requirements from M intent items', and the template's Summary shows the Size line"
  if grep -q 'N requirements from M intent items' "$file" \
    && grep -q 'Size: <N> requirements from <M> intent items' "$file"; then
    pass REQ-1.5 "$what"
  else
    fail REQ-1.5 "$what"
  fi
}

check_req_1_template() {
  local file="$REPO_ROOT/skills/writing-specs/SKILL.md"
  local what="the requirement template shows a *Source:* line beside the *Proof:* line"
  local template
  template="$(sed -n '/^```markdown$/,/^```$/p' "$file")"
  if grep -q '\*Proof:' <<<"$template" && grep -q '\*Source:' <<<"$template"; then
    pass REQ-1-template "$what"
  else
    fail REQ-1-template "$what"
  fi
}

check_req_1_report() {
  local file="$REPO_ROOT/skills/writing-specs/SKILL.md"
  local what="Check It Before You Hand It Over asks whether every requirement names a source"
  if grep -q 'Does every requirement name a source?' "$file"; then
    pass REQ-1-report "$what"
  else
    fail REQ-1-report "$what"
  fi
}

slice3() {
  check_req_1_1
  check_req_1_2
  check_req_1_3
  check_req_1_4
  check_req_1_5
  check_req_1_template
  check_req_1_report
}

all() {
  slice1
  slice2
  slice3
  finalreview
}

group="${1:-}"
case "$group" in
  slice1|slice2|slice3|finalreview|all)
    "$group"
    ;;
  *)
    echo "usage: check.sh {slice1|slice2|slice3|finalreview|all}" >&2
    exit 2
    ;;
esac

if [ "$FAILURES" -ne 0 ]; then
  exit 1
fi
