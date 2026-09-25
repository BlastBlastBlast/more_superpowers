# Spec: parallel plans without slices

Intent: `intent.md`. Date: 2026-09-25. Status: approved.

## Summary

This change removes slices from the change chain. A plan becomes a list of tasks that the plan groups
in waves, and execution sends every task of a wave to parallel subagents. The whole branch then gets
one review, one fix wave and one scoped re-review. The spec format keeps its guardrails but stops
creating requirements that exist only to build proofs.

Size: 10 requirements from 17 intent items: 11 outcome items, 5 constraints and 1 open question. Each requirement names its source in the intent.

## Vocabulary

- **Task:** one independent unit of work. One subagent implements one task.
- **Owned files:** the files that a task lists under **Files**. In one wave, only that task edits
  them.
- **Wave:** a group of tasks that share no owned file and that depend only on earlier waves.
- **Controller:** the session that runs `subagent-driven-development`. It dispatches subagents,
  runs tests and makes commits.
- **Final review:** the one review of the whole branch diff, after the last wave.
- **Fix wave:** the one parallel dispatch that fixes the findings of the final review.
- **Trivial fix:** a fix that changes only documentation files, comments or docstrings. Skill
  instruction text, such as a `SKILL.md` or a prompt, and test bodies are not trivial.
- **Git state command:** a git command that changes the index, HEAD, a branch or the stash, for
  example `add`, `commit`, `stash`, `checkout` and `switch`.

## Requirements

### Behavior

**REQ-1** The `writing-plans` skill MUST produce a plan of tasks with no slices.
  - **REQ-1.1** The plan MUST NOT contain slices, slice demonstration commands, slice checkpoints
    or per-slice risk blocks.
  - **REQ-1.2** Each task MUST list these fields: **Satisfies**, **Files**, **Depends on**,
    **Model**, **Brief** and **Steps**.
  - **REQ-1.3** The steps of a code task MUST follow test-driven development: write the test, see
    it fail, implement, see it pass.
  - **REQ-1.4** The steps of a documentation or configuration task MUST NOT include test-writing
    steps. The task MAY name a check command that already exists, such as a lint.
  - **REQ-1.5** The plan MUST NOT contain a task whose only purpose is to build test tooling that
    the spec does not require.
  - **REQ-1.6** The plan MUST carry one risk list for the whole plan, worst risk first.
  *Proof: the `writing-plans` skill text contains each rule and no slice concept. A plan written in
  the `triggering-writing-plans` scenario has a Waves table and no slice heading.*
  *Source: Proposed outcome, items 1, 3 and 7.*

**REQ-2** The `writing-plans` skill MUST size a task as one independent unit, not by a count of
files or steps.
  - **REQ-2.1** The plan writer MUST NOT limit a task by the number of files or the number of
    steps.
  - **REQ-2.2** The plan writer MUST put small edits of the same kind across many files into one
    task.
  - **REQ-2.3** Each top-level requirement of the spec MUST map to one task or more.
  - **REQ-2.4** A sub-requirement MUST NOT own a task. The task of its parent requirement carries
    it.
  *Proof: the `writing-plans` skill text contains each rule. The three-file and five-step limits
  are gone from the skill text.*
  *Source: Proposed outcome, items 6 and 8.*

**REQ-3** The `writing-plans` skill MUST group the tasks of a plan in waves.
  - **REQ-3.1** The plan MUST contain a Waves table that names the tasks of each wave.
  - **REQ-3.2** Two tasks in one wave MUST NOT share an owned file.
  - **REQ-3.3** The plan writer MUST put a task in the first wave after the waves of all the tasks
    it depends on.
  - **REQ-3.4** The plan writer MUST use the fewest waves that the dependencies allow.
  - **REQ-3.5** The self-review of the plan MUST check REQ-2.3, REQ-3.2 and REQ-3.3.
  *Proof: the `writing-plans` skill text contains each rule and each self-review check.*
  *Source: Proposed outcome, items 2 and 5.*

**REQ-4** The `subagent-driven-development` skill MUST dispatch each wave in parallel.
  - **REQ-4.1** The controller MUST dispatch every task of a wave in one message, as background
    subagents.
  - **REQ-4.2** The controller MUST dispatch a wave that exceeds the concurrency cap in batches up
    to the cap.
  - **REQ-4.3** The implementer brief MUST tell the implementer to edit only its owned files.
  - **REQ-4.4** The implementer brief MUST tell the implementer not to run git state commands.
  - **REQ-4.5** The controller MUST re-dispatch a task that reports NEEDS_CONTEXT or BLOCKED on its
    own, while the other tasks of the wave continue.
  - **REQ-4.6** After every task of a wave reports, the controller MUST check that each changed
    file belongs to the owned files of one task. The controller MUST record a changed file outside
    every task as a finding for the final review, and commit that file on its own so the final
    reviewer sees it in the diff.
  - **REQ-4.7** The controller MUST run the test commands of the wave once, and send a failure to
    the implementer that owns the failing file.
  - **REQ-4.8** The controller MUST commit each task of the wave as its own commit.
  - **REQ-4.9** The ledger MUST record the base and the completion of each wave, so that a resumed
    controller dispatches again only the tasks whose files are not committed.
  - **REQ-4.10** The controller MUST NOT wait for your human partner between waves, except for the
    stop reasons that the skill names.
  *Proof: the `subagent-driven-development` skill text and the implementer prompt contain each
  rule. The rule "Never dispatch multiple implementation subagents in parallel" is gone. The
  `sdd-same-plan-resume` scenario passes.*
  *Source: Proposed outcome, items 2 and 5. Out of scope, item 1.*

**REQ-5** The controller and its subagents MUST NOT run a git state command that changes the branch
after the first dispatch.
  - **REQ-5.1** Execution MUST NOT create, switch or check out a branch after the first dispatch.
  - **REQ-5.2** A subagent MUST NOT make a commit. The controller makes every commit.
  *Proof: the `subagent-driven-development` skill text and the implementer prompt contain each
  rule.*
  *Source: Proposed outcome, item 5.*

**REQ-6** The `subagent-driven-development` skill MUST review the branch once, after the last wave.
  - **REQ-6.1** The final review MUST read the whole branch diff from the branch base, the spec and
    the plan.
  - **REQ-6.2** The controller MUST NOT dispatch a review per task or per wave.
  - **REQ-6.3** The controller SHOULD dispatch one final reviewer. Escape: when the diff has more
    than 2,000 changed lines, the controller dispatches three parallel reviewers, for spec
    compliance, correctness and quality.
  - **REQ-6.4** A final reviewer MAY test a named risk with at most 3 reverted mutations.
  *Proof: the `subagent-driven-development` skill text contains each rule. The
  `sdd-final-review-single-wave` scenario passes.*
  *Source: Proposed outcome, item 4. Open question 1.*

**REQ-7** The `subagent-driven-development` skill MUST end the review with one fix wave and one
scoped re-review.
  - **REQ-7.1** The controller MUST group the findings by file and dispatch one fixer per group,
    under the rules of REQ-4.3 and REQ-4.4.
  - **REQ-7.2** A fixer MUST resume the original implementer when that agent is reachable. Else the
    controller MUST dispatch a fresh fixer one model tier up.
  - **REQ-7.3** One scoped re-review MUST read only the fix diff.
  - **REQ-7.4** The controller MUST NOT run a second fix wave.
  - **REQ-7.5** The controller MUST handle each finding that remains after the re-review in one of
    three ways. It fixes a trivial finding itself. It stops and asks your human partner about a
    correctness or spec break. It records any other finding in the ledger and in the pull request
    body.
  - **REQ-7.6** The rationalization row "I'll fix it myself, dispatching is overhead" MUST apply
    to findings before the re-review only.
  *Proof: the `subagent-driven-development` skill text contains each rule. The
  `sdd-re-review-scoped` and `sdd-fix-loop-resumes-implementer` scenarios pass.*
  *Source: Proposed outcome, item 4.*

**REQ-8** The `writing-specs` skill MUST keep proofs and sub-requirements inside the requirement
they serve.
  - **REQ-8.1** A proof MUST name evidence that exists or that costs nothing to produce: a reviewer
    who reads named files, an existing test or command, or a search such as `git grep`.
  - **REQ-8.2** The spec author MUST NOT add a requirement whose only purpose is to build a proof,
    unless the intent asks for that tool.
  - **REQ-8.3** A sub-requirement MUST state a detail of how its parent requirement is met. This
    rule replaces the rule that a sub-requirement covers a named edge.
  - **REQ-8.4** The spec author MUST list an edge case that the intent does not name under
    `## Open questions carried from intent`, not as a sub-requirement.
  *Proof: the `writing-specs` skill text contains each rule. A spec written in the
  `spec-writing-blind-spot` scenario contains no requirement that only builds a proof.*
  *Source: Proposed outcome, items 8, 9 and 10. Constraint 2.*

### Interface

**REQ-9** The other skills and the repository guide MUST describe the chain without slices.
  - **REQ-9.1** The `executing-plans` skill MUST run the waves in order in one session, do their
    tasks one at a time, commit each task, and end with the same final review.
  - **REQ-9.2** The `reconciling-specs` skill MUST run after the final review and the re-review,
    and compare the top-level requirements with the branch diff.
  - **REQ-9.3** The `brainstorming` skill MUST describe `plan.md` as the tasks, grouped in waves.
  - **REQ-9.4** The `task-brief` script MUST accept a plain task ID.
  - **REQ-9.5** A skill instruction file MUST NOT mention a slice of a plan.
  - **REQ-9.6** `CLAUDE.md` and `AGENTS.md` MUST hold the same text.
  - **REQ-9.7** The Codex tool reference in `using-superpowers` MUST describe the fix wave, not fix
    rounds or a review per task.
  *Proof: `git grep -in slice -- skills` finds no plan slice in an instruction file.
  `tests/claude-code/test-task-brief.sh` passes. `diff CLAUDE.md AGENTS.md` prints nothing.*
  *Source: Proposed outcome, item 11. Affected users and systems.*

### Operations

**REQ-10** The change MUST carry eval evidence from the harness.
  - **REQ-10.1** The contributor MUST run `bun run quorum check` and show a pass.
  - **REQ-10.2** The contributor MUST run the affected scenarios before and after the change.
  - **REQ-10.3** The contributor MUST run the full scenario set once before the pull request opens.
  - **REQ-10.4** For each scenario that goes from pass to fail, the contributor MUST state whether
    the scenario holds behavior that this change removes on purpose, or whether the change broke
    it.
  *Proof: `eval-baseline.md` and `eval-after.md` in this directory hold the runs and the labels.*
  *Source: Constraint 4.*
  *Ruling (Lars, 2026-09-25): the live runs of REQ-10.2 and REQ-10.3 are waived. `quorum run` stops
  on macOS at the Linux preflight. REQ-10.1 still holds.*

## Non-goals

- An early view or a human checkpoint during execution. The intent puts it out of scope.
- A separate path for documentation changes. Documentation goes through the full chain.
- One worktree per task. Disjoint owned files in one working tree remove the need for a merge back.
- Waves that the controller computes at run time. The plan fixes the waves so that your human
  partner can check them before execution.
- Changes submitted to obra/superpowers.
- The Claude Code defect that routed a mid-turn stop message to a subagent.

## Constraints applied

Rules and area guides:
- `CLAUDE.md` and `AGENTS.md`: eval evidence for a behavior change, tested Red Flags wording,
  "your human partner" language, zero dependencies, and the two files kept identical.
- `skills/writing-skills/SKILL.md`: the contributor tests a skill change before and after.
- `skills/asd-ste100/references/writing-rules.md`: the prose of this spec.

Policy skills: this repository is a plugin of skills with no domain data, so no policy skill
applies.

## Flagged concerns

**F1. The controller fixes a trivial finding, but a tested rationalization row forbids that.**
REQ-7.5 lets the controller fix a trivial remaining finding itself. The Common Rationalizations
table in `subagent-driven-development` has the row "I'll fix it myself, dispatching is overhead",
which says controller fixes pollute context and skip review. `CLAUDE.md` forbids a change to that
table without evidence.
- Option A: keep the row. A trivial remaining finding goes to the ledger and the pull request body
  instead. Cost: small findings reach the pull request unfixed.
- Option B: narrow the row to findings before the re-review, and record this trusthere session as
  the evidence. Cost: the row changes without an eval of the new wording.
- Owner: Lars.
- **Ruling (Lars, 2026-09-25): Option B.** REQ-7.6 records it.

**F2. The fix loop drops from two rounds to one, and three tested rows name the cap.** The rows
"One more round will converge", "This finding is obviously wrong, I'll drop it" and "Close enough on
spec compliance" refer to the cap of the fix loop. REQ-7.4 sets the cap to one fix wave.
- Option A: keep the rows as they are. The word "cap" then means the end of the one fix wave.
- Option B: reword the rows to name the one fix wave. Cost: the rows change without an eval of the
  new wording.
- Owner: Lars.
- **Ruling (Lars, 2026-09-25): Option A.** The three rows stay word for word.

## Open questions carried from intent

- The threshold for a split final review. Answered by REQ-6.3: 2,000 changed lines.

## Design notes

- The trusthere session `97dcc43a` is the motivating evidence. Its spec proofs pointed at checks
  that REQ-9 of that spec then required. Those checks became three tasks and a hook rename.
- The upstream `writing-plans` at commit `87d2780~1` is the base for the task format. Upstream
  `subagent-driven-development` reviews after each task, so the wave loop has no upstream base.
- Anthropic describes the same fan-out for its own work: independent subtasks in parallel, a
  dependency map before the fan-out, and a test or a script as the referee.

## Reconciled 2026-09-25

- REQ-7.5: the spec did not define "trivial". The build reused the skill's tested definition, which
  excludes skill text and test bodies. The Vocabulary now defines it. Ruling: the spec was wrong.
- REQ-4.6: the build also commits a stray file on its own, so the final reviewer sees it. Ruling:
  the spec was wrong.
- REQ-9.7: added. The fix wave also updated the Codex tool reference, which still named fix rounds
  and a review per task. Ruling: the spec was wrong.
- REQ-10.2 and REQ-10.3: the live runs were waived. The ruling note sits under REQ-10.
