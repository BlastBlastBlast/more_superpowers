# Parallel plans without slices Implementation Plan

> **For agentic workers:** this plan uses the wave format that its own spec introduces, not the
> slice format of the current `writing-plans` skill. Execute it wave by wave: dispatch every task of
> a wave in one message, then run the checks, then commit each task. Steps use checkbox (`- [ ]`)
> syntax for tracking.

**Goal:** Remove slices from the change chain, so a plan groups tasks in waves, execution runs each
wave as parallel subagents, and the branch gets one review, one fix wave and one scoped re-review.

**Approach:** Each skill file is owned by exactly one task, so all skill edits run in one wave. The
eval baseline runs at the same time, against a worktree of the unchanged skills. A second wave runs
the after-evals and the full set.

**Tech Stack:** Markdown skills, bash, the quorum eval harness (bun).

**Spec:** `docs/changes/2026-09-parallel-plans-without-slices/spec.md` (approved, 225ad6a).
Intent: `intent.md` beside it. Implementers read the spec before they edit.

## Global Constraints

- Edit only the files your task owns. Run no git command that changes the index, HEAD, a branch or
  the stash: no `add`, `commit`, `stash`, `checkout`, `switch`. The controller commits (REQ-5).
- Red Flags tables and Common Rationalizations rows stay word for word. The one exception is the
  row "I'll fix it myself, dispatching is overhead" (REQ-7.6). The rows that name "the cap" stay
  as they are (spec ruling F2).
- Keep "your human partner" wording where it stands. Match the voice of the surrounding skill text.
- A skill references nothing outside the plugin directory.
- Requirement numbers in the spec are cited as they stand. Never renumber.
- These are skill-text tasks, so they carry no test-writing steps (REQ-1.4). Task 8 is the one code
  task.
- Eval command, from `~/dev/superpowers2-opus55/evals`:
  `SUPERPOWERS_ROOT=<plugin root> bun run quorum run scenarios/<name> --coding-agent claude`
- Affected scenarios: `triggering-writing-plans`, `triggering-executing-plans`,
  `spec-writing-blind-spot`, `cost-spec-plan-duplication`, `cost-trivial-task-review-fanout`,
  `sdd-final-review-single-wave`, `sdd-re-review-scoped`, `sdd-fix-loop-resumes-implementer`,
  `sdd-same-plan-resume`, `sdd-survives-compaction`, `sdd-spec-context-consumed`,
  `sdd-spec-constraint-preserved`, `sdd-breaker-adjudicates-at-cap`, `sdd-svelte-todo`.

## File map

| File | Change | Task |
|---|---|---|
| `docs/changes/2026-09-parallel-plans-without-slices/eval-baseline.md` | Create: the baseline runs | 1 |
| `skills/writing-plans/SKILL.md` | Tasks and waves replace slices | 2 |
| `skills/subagent-driven-development/SKILL.md` | The wave loop, one review, one fix wave | 3 |
| `skills/subagent-driven-development/implementer-prompt.md` | Owned files, no git state commands | 4 |
| `skills/subagent-driven-development/task-reviewer-prompt.md` | Becomes the final review prompt | 4 |
| `skills/subagent-driven-development/re-review-prompt.md` | Scoped to the fix diff | 4 |
| `skills/writing-specs/SKILL.md` | Proof and sub-requirement rules | 5 |
| `skills/executing-plans/SKILL.md` | Waves in order, inline | 6 |
| `skills/brainstorming/SKILL.md` | One line: `plan.md` holds tasks in waves | 7 |
| `skills/requesting-code-review/SKILL.md` | One line: no per-slice review | 7 |
| `skills/reconciling-specs/SKILL.md` | Runs after the final review and re-review | 7 |
| `tests/claude-code/test-task-brief.sh` | Fixture uses plain task IDs and a Waves table | 8 |
| `skills/subagent-driven-development/scripts/task-brief` | Header comment only | 8 |
| `docs/changes/2026-09-parallel-plans-without-slices/eval-after.md` | Create: the after runs | 9 |

## Tasks

### Task 1: Record the eval baseline

**Satisfies:** REQ-10
**Files:** Create `docs/changes/2026-09-parallel-plans-without-slices/eval-baseline.md`.
**Depends on:** none
**Model:** session task. The controller runs it in the background while Wave 1 edits proceed.
**Brief:** The baseline measures the skills before any edit. Commit `225ad6a` holds them unchanged.
Run the evals against a worktree of that commit, so the Wave 1 edits in the main tree cannot leak
into the baseline. Record each result in the format of
`docs/changes/2026-09-right-size-change-chain/eval-baseline.md`.
**Steps:**
- [ ] `git worktree add ~/dev/sp2-baseline 225ad6a`
- [ ] Run `bun run quorum check` and record its output.
- [ ] Run each affected scenario (Global Constraints) with `SUPERPOWERS_ROOT=$HOME/dev/sp2-baseline`,
  in the background, and record pass or fail with the verifier's one-line reason.
- [ ] Write `eval-baseline.md`.
- [ ] `git worktree remove ~/dev/sp2-baseline`

### Task 2: `writing-plans` writes tasks in waves

**Satisfies:** REQ-1, REQ-2, REQ-3
**Files:** Modify `skills/writing-plans/SKILL.md`.
**Depends on:** none
**Model:** standard tier. The skill text is tuned, and every section changes.
**Brief:** Rewrite the skill so a plan is a list of tasks grouped in waves, with no slices. The
upstream version at `git show 87d2780~1:skills/writing-plans/SKILL.md` is the base for the task
format. Keep the fork's parts that still apply: the spec as input, Global Constraints, the file
map, model tiers, No Placeholders, and the risk list.
- Remove: "Slice Vertically", "Slice Right-Sizing", the slice structure and its template, the
  demonstration command, the per-slice risk block, the three-file and five-step limits, and the
  vertical and slice-one self-review checks.
- Each task carries the fields **Satisfies** (top-level requirement IDs only), **Files**,
  **Depends on**, **Model**, **Brief** and **Steps**. Keep the **Interfaces** block for a task
  that shares an interface with another task.
- A code task has TDD steps. A documentation or configuration task has no test-writing steps and
  MAY name an existing check command. The plan contains no task whose only purpose is to build
  test tooling that the spec does not require.
- Task size: one independent unit. Small edits of the same kind across many files are one task.
  Each top-level requirement maps to one task or more. A sub-requirement never owns a task; its
  parent's task carries it.
- A **Waves** section: a table of waves and their tasks. Two tasks in one wave share no file. A
  task goes in the first wave after all the tasks it depends on. Use the fewest waves the
  dependencies allow.
- One risk list for the whole plan, worst first, answering: what could this break, which task
  carries the most risk, and what was ruled out.
- Self-review checks: every top-level requirement maps to a task, no two tasks in one wave share a
  file, every "Depends on" points at an earlier wave, placeholders, name consistency.
- The plan header and the Execution Handoff describe wave execution: subagent-driven runs each wave
  in parallel with one final review; inline runs the waves in order.
- Remove the Overview sentence that says "vertical slices".
**Steps:**
- [ ] Read the spec, the current skill and the upstream base.
- [ ] Rewrite the skill.
- [ ] Run `git grep -in slice -- skills/writing-plans` and see no plan-slice mention.
- [ ] Report the files you changed.

### Task 3: `subagent-driven-development` runs waves

**Satisfies:** REQ-4, REQ-5, REQ-6, REQ-7
**Files:** Modify `skills/subagent-driven-development/SKILL.md`.
**Depends on:** none
**Model:** most capable tier. The file holds about 750 lines of tuned text, and the loop, the
review and the fix sections all change together.
**Brief:** Replace the slice loop with the wave loop. Keep the ledger, the four report statuses,
model selection, area context, the plan conflict scan, and every rationalization row word for word
except one.
- Setup: work on the current feature branch, or in the worktree the session already uses. After the
  first dispatch, nothing creates, switches or checks out a branch. Only the controller commits.
- The wave loop, for each wave of the plan's Waves table: write the wave base to the ledger;
  dispatch every task of the wave in one message as background subagents, in batches up to the
  concurrency cap when the wave is larger; handle each report as it arrives, and re-dispatch a
  NEEDS_CONTEXT or BLOCKED task on its own while the others continue; when all tasks report, check
  that each changed file belongs to one task's owned files and record any other file as a finding
  for the final review; run the wave's test commands once and send a failure to the owner of the
  failing file; commit each task as its own commit; write `Wave N: complete (base..head)`.
- Resume: a wave with no completion line re-dispatches only the tasks whose files are not
  committed.
- No stop between waves except the stop reasons the skill names. Remove the slice-one checkpoint.
- Remove "Never dispatch multiple implementation subagents in parallel (conflicts)."
- Final review, after the last wave: it reads the whole branch diff from the branch base, the spec
  and the plan. One reviewer by default. When the diff has more than 2,000 changed lines, three
  parallel reviewers: spec compliance, correctness, quality. No review per task or per wave. The
  3-mutation rule for the final review stays.
- Fix wave: group the findings by file, one fixer per group, in parallel, under the owned-files and
  no-git rules. A fixer resumes the original implementer when it is reachable, else a fresh fixer
  one tier up. The controller commits. Then one scoped re-review of the fix diff only. No second
  fix wave. A remaining finding: trivial, the controller fixes it; a correctness or spec break,
  stop and ask your human partner; anything else, the ledger and the pull request body.
- Change only this row: "I'll fix it myself, dispatching is overhead" applies to findings before
  the re-review. Keep its reality text and add that clause (REQ-7.6).
- Update the process flowchart, the Overview, the core principle, the Example Workflow and the
  `When to Use` diagram to match.
- `task-brief` is called with a plain task ID, for example `task-brief PLAN 3`.
**Interfaces:**
- Produces: the wave loop's ledger lines `Wave N: base <sha7>`, `Task N: complete (commits
  <base7>..<head7>, tests pass)`, `Wave N: complete (<base7>..<head7>)`. The implementer prompt
  (Task 4) uses the terms "owned files" and "git state command" as the spec's Vocabulary defines
  them.
**Steps:**
- [ ] Read the spec and the current skill.
- [ ] Rewrite the sections the brief names.
- [ ] Run `git grep -in slice -- skills/subagent-driven-development/SKILL.md` and see no
  plan-slice mention.
- [ ] Report the files you changed.

### Task 4: The implementer, final review and re-review prompts

**Satisfies:** REQ-4, REQ-5, REQ-6, REQ-7
**Files:** Modify `skills/subagent-driven-development/implementer-prompt.md`,
`skills/subagent-driven-development/task-reviewer-prompt.md`,
`skills/subagent-driven-development/re-review-prompt.md`.
**Depends on:** none
**Model:** standard tier.
**Brief:**
- Implementer prompt: the implementer edits only its owned files, the files its task lists under
  **Files**. It runs no git state command: no `add`, `commit`, `stash`, `checkout`, `switch`. It
  reports its status and the files it changed. Replace the slice wording at line 92 with the same
  idea for tasks: an implementer that repairs the plan to fit its own task leaves the other tasks
  building against text that no longer describes the work.
- Task reviewer prompt: it becomes the final review prompt. The reviewer reads the whole branch diff
  from the branch base, the spec and the plan, and checks each top-level requirement, correctness
  and quality. Remove every slice reference. Add a variant line for the split review: when the
  controller names one category (spec compliance, correctness or quality), the reviewer checks only
  that category.
- Re-review prompt: it reads only the fix diff, checks that each finding is fixed and that nothing
  new broke. Remove every slice reference.
**Interfaces:**
- Consumes: "owned files" and "git state command" as the spec's Vocabulary defines them. The report
  statuses DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT and BLOCKED are unchanged.
**Steps:**
- [ ] Read the spec and the three prompts.
- [ ] Edit the three prompts.
- [ ] Run `git grep -in slice -- skills/subagent-driven-development/*.md` for these files and see
  no plan-slice mention.
- [ ] Report the files you changed.

### Task 5: `writing-specs` keeps proofs inside their requirement

**Satisfies:** REQ-8
**Files:** Modify `skills/writing-specs/SKILL.md`.
**Depends on:** none
**Model:** standard tier.
**Brief:** In "Requirement Form":
- Extend "State what proves it": a proof names evidence that exists or costs nothing to produce, such
  as a reviewer who reads named files, an existing test or command, or a `git grep`. The spec author
  adds no requirement whose only purpose is to build a proof, unless the intent asks for that tool.
- Replace "A sub-requirement covers a named edge" with: a sub-requirement states a detail of how its
  parent requirement is met. An edge case the intent does not name goes under
  `## Open questions carried from intent`, not into a sub-requirement.
- Keep the Red Flags table word for word, including the proof row.
**Steps:**
- [ ] Read the spec and the skill.
- [ ] Edit the two rules.
- [ ] Run `python3 skills/asd-ste100/scripts/ste-lint.py skills/writing-specs/SKILL.md` and see no
  new hard violation.
- [ ] Report the files you changed.

### Task 6: `executing-plans` runs waves inline

**Satisfies:** REQ-9
**Files:** Modify `skills/executing-plans/SKILL.md`.
**Depends on:** none
**Model:** cheap tier. One file, and the behaviour is stated here.
**Brief:** Replace all 11 slice mentions. The session runs the waves of the plan in order, does the
tasks of each wave one at a time in this session, commits each task, and ends with the one final
review that `subagent-driven-development` describes. Remove slice checkpoints and demonstration
commands.
**Steps:**
- [ ] Read the spec and the skill.
- [ ] Edit the skill.
- [ ] Run `git grep -in slice -- skills/executing-plans` and see nothing.
- [ ] Report the files you changed.

### Task 7: Remove slices from the chain's other skills

**Satisfies:** REQ-9
**Files:** Modify `skills/brainstorming/SKILL.md`, `skills/requesting-code-review/SKILL.md`,
`skills/reconciling-specs/SKILL.md`.
**Depends on:** none
**Model:** cheap tier. Three small edits of the same kind.
**Brief:**
- `brainstorming/SKILL.md` line 148: `plan.md       the vertical slices, in order` becomes
  `plan.md       the tasks, grouped in waves`. Change nothing else in the file.
- `requesting-code-review/SKILL.md` line 15: "After each slice in subagent-driven development, and
  at its final whole-branch review" becomes "At the final whole-branch review in subagent-driven
  development".
- `reconciling-specs/SKILL.md` "When To Run": it runs after the final review and its scoped
  re-review, and compares the top-level requirements with the branch diff.
**Steps:**
- [ ] Make the three edits.
- [ ] Run `git grep -in slice -- skills/brainstorming/SKILL.md skills/requesting-code-review skills/reconciling-specs`
  and see nothing.
- [ ] Report the files you changed.

### Task 8: `task-brief` test uses plain task IDs

**Satisfies:** REQ-9
**Files:** Modify `tests/claude-code/test-task-brief.sh`,
`skills/subagent-driven-development/scripts/task-brief` (header comment only).
**Depends on:** none
**Model:** cheap tier.
**Brief:** The script already extracts `Task <n>`. The test fixture still uses slices. Rewrite the
fixture as a wave plan: `### Task 1`, `### Task 2` (with the fenced fake heading inside it),
`### Task 3`, then a `## Waves` section. The test asserts four things:
- the brief for `2` contains Task 2's body and the text after the fence
- the brief for `2` does not contain Task 3's body or the fenced heading as a start
- the brief for `3` ends before `## Waves`
- the old form `Task 1.2` in a second fixture still extracts, for plans written before this change
The header comment of `task-brief` names plain task IDs and says nothing about slices. The script
body does not change.
**Steps:**
- [ ] Rewrite the fixture and the assertions.
- [ ] Run `bash tests/claude-code/test-task-brief.sh` and see every case pass. The behaviour already
  exists, so there is no red run. Break the `## Waves` assertion once by hand to see it fail, then
  restore it.
- [ ] Edit the header comment.
- [ ] Report the files you changed.

### Task 9: Record the after-evals and the full set

**Satisfies:** REQ-10
**Files:** Create `docs/changes/2026-09-parallel-plans-without-slices/eval-after.md`.
**Depends on:** 1, 2, 3, 4, 5, 6, 7, 8
**Model:** session task.
**Brief:** Run the evals against the edited skills in this tree. Record the results beside the
baseline. For each scenario that goes from pass to fail, label it: the scenario holds slice or
per-slice-review behaviour this change removes on purpose, or the change broke it. Then run the
full scenario set once.
**Steps:**
- [ ] Run `bun run quorum check`.
- [ ] Run each affected scenario with `SUPERPOWERS_ROOT=$HOME/dev/superpowers2`.
- [ ] Run the full set once.
- [ ] Write `eval-after.md` with the labels.

## Waves

| Wave | Tasks | Why |
|---|---|---|
| 1 | 1, 2, 3, 4, 5, 6, 7, 8 | Each task owns different files. Task 1 runs against a separate worktree. |
| 2 | 9 | It measures the edits of Wave 1. |

After Wave 2: the final review, the fix wave and the scoped re-review, then `reconciling-specs`.

## Risks, worst first

1. **Task 3 and Task 4 drift apart.** They edit the skill and its prompts in parallel. The
   Interfaces blocks fix the shared terms and ledger lines. The final review reads both together.
2. **A tested rationalization row changes by accident.** Task 3 rewrites the file that holds the
   table. The Global Constraints name the one row that may change. The final review diffs the
   table.
3. **An eval that passed before fails for a reason other than removed slices.** Task 9 labels each
   pass-to-fail case. A case labeled broken goes to the fix wave.
4. **The baseline measures edited skills.** Task 1 runs against a worktree of `225ad6a`, not the
   main tree.

**Most risk:** Task 3. It is the largest edit, and it holds the tested table.

**Ruled out:**
- Splitting Task 3 across subagents. Two tasks in one wave cannot share a file.
- A check script like the last change's `check.sh`. The spec's proofs are `git grep`, the
  `task-brief` test, `diff CLAUDE.md AGENTS.md`, and the evals. No new tooling (REQ-1.5).
- Editing `CLAUDE.md` and `AGENTS.md`. They name no slice, and they are identical today.
