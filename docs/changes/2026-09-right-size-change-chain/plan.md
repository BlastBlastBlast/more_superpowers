# Right-size the change chain Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan slice-by-slice. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The spec, the plan and the SDD loop scale to the change they carry.

**Architecture:** Prose edits to five skills, one bash script fix with its test, and one check
script that turns each spec proof line into a pass or fail. This plan already uses the shape the
spec defines: slices are checkpoints, tasks are dispatches, and the plan does not repeat text the
implementer reads in the repo.

**Tech Stack:** Markdown skills, bash, the quorum eval harness (bun).

**Spec:** `docs/changes/2026-09-right-size-change-chain/spec.md`

## Global Constraints

- Keep every Red Flags table and rationalization row as it is, except the one row F1 rewrites.
- Keep `test-driven-development/writing-good-tests.md` unchanged (REQ-8.3).
- No skill may reference a file outside the plugin directory.
- Write new skill prose in the voice of the file you edit. Do not restyle text you do not change.
- Eval command, run from `~/dev/superpowers2-opus55/evals`:
  `SUPERPOWERS_ROOT=$HOME/dev/superpowers2 bun run quorum run scenarios/<name> --coding-agent claude`
- Eval scenarios in scope: `spec-writing-blind-spot`, `triggering-writing-plans`,
  `sdd-svelte-todo`, `sdd-final-review-single-wave`, `sdd-re-review-scoped`,
  `sdd-same-plan-resume`, `sdd-round4-escalates-model`, `sdd-breaker-adjudicates-at-cap`,
  `sdd-breaker-rules-and-continues`, `sdd-breaker-structural-blocks`,
  `sdd-fix-loop-resumes-implementer`.

## File map

| File | Change | Tasks |
|---|---|---|
| `docs/changes/2026-09-right-size-change-chain/check.sh` | new: one check per REQ, pass or fail | 1.2, then each task adds its checks |
| `docs/changes/2026-09-right-size-change-chain/eval-baseline.md` | new | 1.1 |
| `docs/changes/2026-09-right-size-change-chain/eval-after.md` | new | 3.2 |
| `skills/subagent-driven-development/scripts/task-brief` | `<slice>.<task>` ids, stop at slice headings | 1.2 |
| `tests/claude-code/test-task-brief.sh` | new | 1.2 |
| `skills/writing-plans/SKILL.md` | slices, tasks, limits, no repeated code | 1.3 |
| `skills/subagent-driven-development/SKILL.md` | per-task loop, slice review, fix cap, ledger | 2.1, 2.2 |
| `skills/executing-plans/SKILL.md` | tasks of a slice in order | 2.1 |
| `skills/subagent-driven-development/task-reviewer-prompt.md` | slice scope, no mutation | 2.3 |
| `skills/subagent-driven-development/re-review-prompt.md` | no mutation | 2.3 |
| `skills/requesting-code-review/code-reviewer.md` | mutations in a temporary worktree | 2.3 |
| `skills/writing-specs/SKILL.md` | sizing rules | 3.1 |

---

### Slice 1: A plan in the new shape, and a brief cut from it

**Satisfies:** REQ-2, REQ-3, REQ-4, REQ-9.1, REQ-9.2, REQ-10 (baseline half)

**Demonstrate with:**
`skills/subagent-driven-development/scripts/task-brief docs/changes/2026-09-right-size-change-chain/plan.md 1.3 "${TMPDIR:-/tmp}/brief.md" && cat "${TMPDIR:-/tmp}/brief.md" && docs/changes/2026-09-right-size-change-chain/check.sh slice1`
Expected: the brief holds Task 1.3 and nothing from Slice 2, and every slice-1 check prints PASS.

**Risk:** A baseline taken after a skill edit measures nothing. Task 1.1 must finish before any
skill file changes. `task-brief` is the other risk: a brief that pulls in the next slice's text
hands an implementer work it does not own.

#### Task 1.1: Record the eval baseline

**Model:** the session runs this task itself.
**Satisfies:** REQ-10.1
**Files:** create `eval-baseline.md`.
**Test command:** `test -s docs/changes/2026-09-right-size-change-chain/eval-baseline.md`

- [ ] Run `bun run quorum check` and every in-scope scenario (Global Constraints). Run them in the
  background. No skill file changes until they finish.
- [ ] Write `eval-baseline.md` in the format of `docs/changes/2026-09-intent-first-change-chain/eval-baseline.md`:
  the check output, then one row per scenario with its verdict and run directory.
- [ ] Commit: `docs: eval baseline for 2026-09-right-size-change-chain`.

#### Task 1.2: `task-brief` reads `<slice>.<task>` and stops at the slice edge

**Model:** standard tier.
**Satisfies:** REQ-9.1, REQ-9.2
**Files:** modify `skills/subagent-driven-development/scripts/task-brief`. Create
`tests/claude-code/test-task-brief.sh` and `check.sh`.
**Tests** (`test-task-brief.sh`, on a fixture plan written by the test with two slices of two
tasks each, and a fenced code block that contains `#### Task 9.9`):
- the brief for `1.2` contains Task 1.2's body and not `### Slice 2`
- the brief for `2.1` does not contain Task 2.2's body
- the heading inside the fence does not start or end a brief
- a missing id `3.1` exits 3
- the old form `Task 2` still extracts, for plans written before this change
**Test command:** `bash tests/claude-code/test-task-brief.sh`

- [ ] Write the test. Run it and see it fail.
- [ ] Change the awk program: match `Task <id>` with the dot escaped, and end the brief at any
  heading whose level is the same as or higher than the task heading. Keep the fence handling.
- [ ] Run the test and see it pass.
- [ ] Create `check.sh`. It takes a group name (`slice1`, `slice2`, `slice3`, `all`), runs grep checks, prints
  `PASS <REQ> <what>` or `FAIL <REQ> <what>` per check, and exits 1 on any FAIL. Add the REQ-9.2
  check: it runs `test-task-brief.sh`.
- [ ] Commit: `fix: task-brief reads slice.task ids and stops at the slice edge`.

#### Task 1.3: `writing-plans` cuts slices into tasks

**Model:** standard tier.
**Satisfies:** REQ-2, REQ-3, REQ-4
**Files:** modify `skills/writing-plans/SKILL.md`, and add checks to `check.sh`.
**Tests** (`check.sh slice1`):
- REQ-2: the text says slice one is the MVP. It says a new slice starts only where there is something
  new to show. The handoff no longer says "a fresh subagent per slice".
- REQ-3: the text states the three task limits (3 production files, 5 steps, one test command), and
  the self-review checks them. `Model` is a task field, not a slice field.
- REQ-4: neither "zero context" nor "repeat the code" appears. Each task lists its files, behaviour
  with its REQ, tests with what each asserts, and its test command.
**Test command:** `docs/changes/2026-09-right-size-change-chain/check.sh slice1`

- [ ] Add the checks. Run them and see them fail.
- [ ] Edit the Overview, Slice Right-Sizing, Which Model, Slice Structure, No Placeholders,
  Self-Review and Execution Handoff sections. The Slice Structure template becomes a slice header
  (Satisfies, Demonstrate, Risk) with `#### Task N.M` blocks (Model, Satisfies, Files, Tests, Test
  command, steps). This plan is a worked example of that shape.
- [ ] Run the checks and see them pass.
- [ ] Commit: `feat: writing-plans splits each slice into subagent-sized tasks`.

---

### Slice 2: SDD runs tasks, reviews slices, and stops at two rounds

**Satisfies:** REQ-5, REQ-6, REQ-7, REQ-8, REQ-9.3, F1

**Demonstrate with:** `docs/changes/2026-09-right-size-change-chain/check.sh slice2 && (cd ~/dev/superpowers2-opus55/evals && bun run quorum check)`
Expected: every slice-2 check prints PASS, and the static gate is clean.

**Risk:** SDD is the most-used skill and its wording is tested. The worst failure is a rewrite that
drops a guard the old text held, like the no-subagents contract or the ledger resume rule. Edit
the sections the spec names and leave the rest word for word.

#### Task 2.1: The per-task loop and the slice checkpoint

**Model:** standard tier.
**Satisfies:** REQ-5, REQ-6
**Files:** modify `skills/subagent-driven-development/SKILL.md` and
`skills/executing-plans/SKILL.md`, and add checks to `check.sh`.
**Tests** (`check.sh slice2`):
- REQ-5: the flowchart's per-task cluster has no reviewer node. The text says the session runs the
  task's test command after each task and sends a failure back to the same implementer.
  `executing-plans` runs a slice's tasks in order, with the tests after each.
- REQ-6: a slice-checkpoint step runs the demonstration command, then one slice reviewer over the
  range from the commit before the slice's first task. Slice one's review is dispatched while
  the human sees the demo. The Final Review section is unchanged (the check runs `git diff` on it
  against `main`).
**Test command:** `docs/changes/2026-09-right-size-change-chain/check.sh slice2`

- [ ] Add the checks. Run them and see them fail.
- [ ] Edit the Overview, the core principle, the process flowchart, The Task Loop and "3. Review the
  task" in SDD. The heading "3. Review the task" becomes "3. Review the slice". Add one paragraph to
  executing-plans Step 2.
- [ ] Run the checks and see them pass.
- [ ] Commit: `feat: SDD reviews once per slice, and runs the tests after each task`.

#### Task 2.2: The two-round fix loop, trivial fixes, and the ledger

**Model:** standard tier.
**Satisfies:** REQ-7, REQ-9.3, F1
**Files:** modify `skills/subagent-driven-development/SKILL.md`, and add checks to `check.sh`.
**Tests** (`check.sh slice2`):
- REQ-7: the text caps the loop at 2 rounds, with round 1 resuming the task's implementer and
  round 2 a fresh implementer one tier up. No text names rounds 3, 4 or 5, or "of 5". A trivial fix
  (docs, comments, docstrings only) gets a diff read and a test run with no re-review. A code or
  test-body fix gets a scoped re-review.
- F1: the rationalization row reads "The fix touched code, but it was small" → "Any change to
  code or test bodies gets a scoped re-review."
- REQ-9.3: ledger lines are `Task <slice>.<task>: complete` and `Slice <N>: complete`. The Setup
  resume rule starts at the slice review of a slice with all tasks complete and no slice line.
**Test command:** `docs/changes/2026-09-right-size-change-chain/check.sh slice2`

- [ ] Add the checks. Run them and see them fail.
- [ ] Edit "4. The fix loop", "5. Complete the task", the breaker text, Model Selection's escalation
  line, the Setup ledger rules, the rationalization row and the Example Workflow.
- [ ] Run the checks and see them pass.
- [ ] Commit: `feat: SDD caps the fix loop at two rounds and skips re-review for trivial fixes`.

#### Task 2.3: Only the final reviewer mutates code

**Model:** standard tier.
**Satisfies:** REQ-8
**Files:** modify `skills/subagent-driven-development/task-reviewer-prompt.md`,
`skills/subagent-driven-development/re-review-prompt.md` and
`skills/requesting-code-review/code-reviewer.md`, and add checks to `check.sh`.
**Tests** (`check.sh slice2`):
- REQ-8.1: `code-reviewer.md` allows mutations only in a temporary worktree, and says to remove the
  worktree afterwards.
- REQ-8.2: the task reviewer prompt and the re-review prompt forbid code mutations and tell the
  reviewer to report a suspected uncaught mutation as a finding. The task reviewer prompt
  says it reviews a slice.
- REQ-8.3: `git diff main -- skills/test-driven-development/writing-good-tests.md` is empty.
**Test command:** `docs/changes/2026-09-right-size-change-chain/check.sh slice2`

- [ ] Add the checks. Run them and see them fail.
- [ ] Edit the read-only paragraph of each prompt, and the scope wording of the task reviewer prompt.
- [ ] Run the checks and see them pass.
- [ ] Commit: `feat: reviewers mutate code only in the final review, in a temporary worktree`.

---

### Slice 3: The spec sizes itself, and the evals say what changed

**Satisfies:** REQ-1, REQ-10

**Demonstrate with:** `docs/changes/2026-09-right-size-change-chain/check.sh all && cat docs/changes/2026-09-right-size-change-chain/eval-after.md`
Expected: every check prints PASS, and the eval table explains every change from pass to fail.

**Risk:** The trace rule (REQ-1.1) can make specs longer if the author writes a source essay per
requirement. The template gives one `*Source:*` line, the same shape as the `*Proof:*` line.

#### Task 3.1: `writing-specs` sizes a spec by the intent

**Model:** standard tier.
**Satisfies:** REQ-1
**Files:** modify `skills/writing-specs/SKILL.md`, and add checks to `check.sh`.
**Tests** (`check.sh slice3`): the text requires a source per requirement. It limits requirements to
observable behaviour, limits sub-requirements to named edges, omits empty optional sections, and
asks for the "N requirements from M intent items" report. The template shows a `*Source:*` line.
**Test command:** `docs/changes/2026-09-right-size-change-chain/check.sh slice3`

- [ ] Add the checks. Run them and see them fail.
- [ ] Edit Requirement Form, The Document template and Check It Before You Hand It Over.
- [ ] Run the checks and see them pass.
- [ ] Commit: `feat: writing-specs sizes a spec by the intent it answers`.

#### Task 3.2: Record the eval evidence

**Model:** the session runs this task itself.
**Satisfies:** REQ-10
**Files:** create `eval-after.md`.
**Test command:** `grep -c 'removed on purpose\|broke' docs/changes/2026-09-right-size-change-chain/eval-after.md`

- [ ] Run `bun run quorum check` and every in-scope scenario again.
- [ ] Write `eval-after.md`: one row per scenario with its verdict before and after. For each pass
  that became a fail, say "removed on purpose" with the REQ, or "broke" with the cause. A broken
  scenario goes back to the task that caused it before the PR opens.
- [ ] Commit: `docs: eval evidence for 2026-09-right-size-change-chain`.

---

## Risks, worst first

1. **An SDD rewrite drops a tested guard** (Slice 2). The `sdd-*` scenarios are the net, and
   Task 2.1 checks that the Final Review section did not change.
2. **The baseline is taken too late** (Task 1.1). The only fix is order: no skill edit before the
   baseline is committed.
3. **A live eval is flaky**, and one fail is noise, not a regression. If a scenario flips, run it
   once more before calling it "broke".
4. **Old plans stop working.** Plans that use `### Task N` or `### Slice N` still exist. The
   `task-brief` test keeps the old form working.

## What this rules out

- **Micro-tests of the wording** (writing-skills). The eleven live scenarios already cover each
  changed behaviour. Micro-tests are worth adding only if a scenario flips for an unclear reason.
- **Fork copies of the 5-round scenarios.** F2 ruled option A.
- **One commit per REQ.** Tasks group requirements by the file they edit, so each task stays inside
  the limits of REQ-3.
