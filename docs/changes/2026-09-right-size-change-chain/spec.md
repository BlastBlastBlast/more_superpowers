# Spec: right-size the change chain

Intent: `intent.md`. Date: 2026-09-23. Status: approved.

## Summary

This change makes the spec, the plan and the execution loop scale to the change they carry. The
spec traces each requirement to the intent. The plan cuts few slices and splits each slice into
tasks that fit one subagent. Execution reviews once per slice, caps the fix loop at two rounds, and
keeps real code mutations for the final review.

Size: 10 requirements from 13 intent items. Each requirement names its source in the intent.

## Vocabulary

- **Slice:** a checkpoint in the plan. It ends in a demonstration command that shows the vertical
  picture. Slice one is the MVP.
- **Task:** one unit of work inside a slice. One subagent implements one task.
- **Session:** the controller that runs `subagent-driven-development`. It dispatches subagents and
  does not write code.
- **Slice review:** one review of all the commits of one slice, at its checkpoint.
- **Trivial fix:** a fix diff that changes only documentation files, comments or docstrings.
  Skill instruction text, such as a `SKILL.md` or a prompt, is not documentation.

## Requirements

### Behavior

**REQ-1** The `writing-specs` skill MUST size a spec by the intent, not by the complexity of the
code.
  - **REQ-1.1** Each requirement MUST name its source: an outcome paragraph, a constraint, a
    decision or an open question of the intent.
  - **REQ-1.2** A requirement MUST state behaviour that a user, a caller or a respondent can
    observe. Function names, SQL and file placement belong in the plan.
  - **REQ-1.3** A sub-requirement MUST cover an edge case that the intent or the interview named.
    The spec author MUST list other edge cases as open questions.
  - **REQ-1.4** The spec MUST omit an optional section that has no content. Design notes and
    flagged concerns are optional sections.
  - **REQ-1.5** The spec author MUST report the size when presenting the spec, in the form
    "N requirements from M intent items".
  *Proof: the `writing-specs` skill text contains each rule. A spec written in the
  `spec-writing-blind-spot` scenario names a source for each requirement.*
  *Source: Proposed outcome, paragraph 1. Q1.*

**REQ-2** The `writing-plans` skill MUST treat a slice as a checkpoint, not as a unit of dispatch.
  - **REQ-2.1** Slice one MUST be the MVP: the thinnest path through the change with visible output.
  - **REQ-2.2** The plan writer MUST start a new slice only where there is something new to show
    and a reviewer can reject that slice alone.
  - **REQ-2.3** Each slice MUST keep its demonstration command and its "suite green at the
    boundary" rule.
  *Proof: the `writing-plans` skill text contains each rule. The execution handoff text no longer
  says "a fresh subagent per slice".*
  *Source: Proposed outcome, paragraph 2.*

**REQ-3** The `writing-plans` skill MUST split each slice into tasks that each fit one subagent.
  - **REQ-3.1** A task MUST change 3 production files or fewer, plus their tests.
  - **REQ-3.2** A task MUST have 5 steps or fewer.
  - **REQ-3.3** A task MUST have one focused test command, and the suite MUST be green when the
    task ends.
  - **REQ-3.4** The plan writer MUST split a task that breaks REQ-3.1, REQ-3.2 or REQ-3.3.
  - **REQ-3.5** The plan MUST name the model per task, not per slice.
  *Proof: the plan self-review in `writing-plans` checks each limit. A plan written in the
  `triggering-writing-plans` scenario has tasks inside slices, and each task keeps to the limits.*
  *Source: Proposed outcome, paragraph 2. Q2.*

**REQ-4** The `writing-plans` skill MUST NOT ask the plan to repeat code that the implementer can
read in the repository.
  - **REQ-4.1** Each task MUST give its files, the behaviour it builds with the requirement it
    traces to, the tests it writes with what each test asserts, and its test command.
  - **REQ-4.2** The plan MAY contain code only for an exact value that more than one task uses:
    an interface signature, or a value that the spec gives.
  - **REQ-4.3** The skill MUST NOT contain the instructions "zero context and questionable taste"
    or "repeat the code".
  *Proof: grep of `writing-plans/SKILL.md` finds neither phrase. The "No Placeholders" list no
  longer calls a missing code block a plan failure.*
  *Source: Proposed outcome, paragraph 3.*

**REQ-5** The `subagent-driven-development` skill MUST dispatch one implementer per task and MUST
NOT review each task.
  - **REQ-5.1** After each task, the session MUST run the task's test command and read only the
    result: pass or fail.
  - **REQ-5.2** If the test command fails, the session MUST send the failure back to the same
    implementer.
  - **REQ-5.3** The `executing-plans` skill MUST run the tasks of a slice in order, and the tests
    after each task.
  - **REQ-5.4** If the same test command fails again after the resend, the session MUST handle
    the task as BLOCKED.
  *Proof: the SDD flowchart has a per-task loop with no reviewer dispatch in it. The
  `sdd-svelte-todo` scenario shows one reviewer dispatch per slice, not per task.*
  *Source: Proposed outcome, paragraph 2. D1.*

**REQ-6** The `subagent-driven-development` skill MUST review each slice once, at its checkpoint.
  - **REQ-6.1** At the checkpoint, the session MUST run the demonstration command and then dispatch
    one slice reviewer.
  - **REQ-6.2** The slice review package MUST cover every commit from the commit before the
    slice's first task to the current head.
  - **REQ-6.3** For slice one of an architectural change, the session MUST dispatch the slice
    review at the same time as it shows the demonstration to the human. The session MUST wait for
    both the review and the human.
  - **REQ-6.4** The final whole-branch review MUST keep its behaviour: the most capable model, one
    fix dispatch and one scoped re-review. Its section gains one line: the dispatch sets the
    `[FINAL_REVIEW]` marker of REQ-8.4.
  *Proof: the SDD skill text and flowchart contain each rule. The `sdd-final-review-single-wave`
  scenario still passes.*
  *Source: Proposed outcome, paragraph 2. D1. Q3. Constraints.*

**REQ-7** The `subagent-driven-development` skill MUST cap the fix loop of a slice review at 2
rounds.
  - **REQ-7.1** Round 1 MUST resume the implementer of the task that owns the finding.
  - **REQ-7.2** Round 2 MUST dispatch a fresh implementer on a more capable model.
  - **REQ-7.3** If findings stay open after round 2, the session MUST rule on each finding as the
    breaker does today.
  - **REQ-7.4** If a fix is a trivial fix, the session MUST read the fix diff, run the tests, and
    skip the scoped re-review.
  - **REQ-7.5** If a fix changes code or test bodies, the session MUST dispatch a scoped re-review.
  *Proof: the SDD skill text contains each rule, and no text still names rounds 3, 4 or 5. The
  `sdd-re-review-scoped` scenario still passes for a code fix.*
  *Source: Q3.*

**REQ-8** Only the final reviewer MAY make real code mutations.
  - **REQ-8.1** The final reviewer MUST make each mutation in a separate temporary worktree and
    MUST NOT change the working tree.
  - **REQ-8.2** The slice reviewer and the scoped re-reviewer MUST NOT mutate code. If a slice
    reviewer suspects a mutation that no test catches, it MUST report that as a finding.
  - **REQ-8.3** The mental mutation check in `test-driven-development/writing-good-tests.md` MUST
    stay as it is.
  - **REQ-8.4** The `code-reviewer.md` template MUST grant the mutation licence only to a dispatch
    that sets the `[FINAL_REVIEW]` marker.
  *Proof: the prompt text of `code-reviewer.md`, the task reviewer prompt and `re-review-prompt.md`
  contains each rule. `git diff` shows no change to `writing-good-tests.md`.*
  *Source: D2. Constraints.*

### Interface

**REQ-9** The plan format and the SDD scripts MUST use the same name for a task.
  - **REQ-9.1** A task heading MUST have the form `#### Task <slice>.<task>: <title>` inside its
    slice.
  - **REQ-9.2** The `task-brief` script MUST accept a task identifier `<slice>.<task>`, and the brief
    MUST end at the next task heading or slice heading.
  - **REQ-9.3** The ledger MUST record `Task <slice>.<task>: complete` for a task,
    `Slice <N>: complete` for a slice, and `Slice <N>: base <sha7>` before the first task of a
    slice. The slice review and the resume rule read the slice range from the base line. On
    resume, the session MUST start at the slice review of a slice whose tasks are all complete
    and that has no `Slice <N>: complete` line.
  - **REQ-9.4** If a plan has no slice headings, SDD MUST run each task as its own slice, with its
    own test run, slice review and ledger lines.
  *Proof: a new test under `tests/claude-code/` runs `task-brief` on a fixture plan with two
  slices and checks that the brief of the last task in slice 1 does not contain slice 2's text.
  The `sdd-same-plan-resume` scenario still passes. REQ-9.4: the `check.sh` I1 check.*
  *Source: Proposed outcome, paragraph 2. REQ-9.4: reconciliation.*

### Operations

**REQ-10** The pull request MUST carry eval evidence from before and after the change.
  - **REQ-10.1** The evidence MUST cover every scenario named in a proof line of this spec, and
    `bun run quorum check`.
  - **REQ-10.2** For each scenario that goes from pass to fail, the evidence MUST say whether the
    scenario holds behaviour this change removes on purpose, or the change broke it.
  *Proof: `eval-baseline.md` and `eval-after.md` in this change record.*
  *Source: Constraints.*

## Non-goals

- **The dispatch target.** Lars reads the intent's measure after the next trusthere change of
  similar size: about 16 dispatches or fewer, less than 3 agent-hours, and no subagent run longer than
  about 20 minutes. It is a measure, not a requirement that this change can prove. The target
  moved from 12 to 16 during the design, with Lars's approval.
- **Parallel dispatch of independent slices.** The intent puts it out of scope.
- **Review of slice N while slice N+1 runs.** The design rejected it. It saves about 10 minutes per
  run and adds fixes that arrive out of order.
- **Separate spec and quality reviewers in parallel.** It adds dispatches and does not remove
  fix rounds.
- **Changes to `brainstorming`, `reconciling-specs` or the trusthere repository.** The intent puts
  them out of scope.

## Constraints applied

Rules and area guides:
- `CLAUDE.md` at the fork root: eval evidence for each behaviour change (REQ-10), and Red Flags
  and rationalization wording changes only with evidence (flagged concern F1).
- `CLAUDE.md` "one problem per pull request": this change is one problem, the size of the chain.
  Lars decided one pull request (D3).
- `CLAUDE.md` "nothing reaches outside the plugin": no requirement references a personal file.
- The ASD-STE100 rules in `skills/asd-ste100/references/writing-rules.md`, for this document.

Policy skills: none. This is a tooling repository with no domain, so it has no policy to apply.

## Flagged concerns

**F1. The rationalization table contradicts REQ-7.4.** The SDD table has the row "The fix was
small, skip the re-review → Every round ends with a scoped re-review." The fork's `CLAUDE.md` says
that wording changes only with evidence. The evidence is PR #357: the slice 1 re-review checked
only three docstring edits.
- Option A: rewrite the row to "The fix touched code, but it was small → Any change to code or
  test bodies gets a scoped re-review." Cost: the eval must show the new row still holds for code
  fixes (`sdd-re-review-scoped`).
- Option B: keep the row and withdraw REQ-7.4. Cost: every trivial fix keeps its re-review.
- Recommendation: option A. Owner: Lars.
- **Ruling (Lars, 2026-09-23): option A.**

**F2. Five eval scenarios encode the 5-round loop.** `sdd-round4-escalates-model`,
`sdd-breaker-adjudicates-at-cap`, `sdd-breaker-rules-and-continues`,
`sdd-breaker-structural-blocks` and `sdd-fix-loop-resumes-implementer` can fail after REQ-7. The
scenarios live in the upstream `superpowers-evals` repository, outside this fork.
- Option A: record each failure as removed on purpose (REQ-10.2), and leave the scenarios as they
  are.
- Option B: add fork copies of the scenarios with a 2-round cap to the eval clone. Cost: a second
  set of scenarios to keep in step with upstream.
- Recommendation: option A for this pull request. Owner: Lars.
- **Ruling (Lars, 2026-09-23): option A.**

## Open questions carried from intent

- **Q1** Answered by REQ-1: a source trace for each requirement, and a size report, not a fixed
  limit.
- **Q2** Answered by REQ-3: 3 production files, 5 steps and one test command per task.
- **Q3** Answered by REQ-6.3 and REQ-7: a 2-round cap, no re-review for a trivial fix, and the
  slice-one review during the demonstration.

## Design notes

- The model tiers in SDD give the cheap tier to a task whose plan contains the complete code.
  REQ-4 removes most of that code, so most tasks move to the standard tier. The #357 implementers
  already ran on the standard tier, so the cost does not change.
- The eval clone is at `~/dev/superpowers2-opus55/evals`, not at `evals/` in this repository. The
  eval runs for REQ-10 use that clone.

## Reconciled 2026-09-23

- Vocabulary, trivial fix: the build excludes skill instruction text from documentation. In this
  repository the skill text is the product. Ruling: the spec was wrong.
- REQ-5.4: added. The build handles a second failure of the same test command as BLOCKED, so the
  per-task loop has a cap. Ruling: the spec was wrong.
- REQ-6.4: the Final Review keeps its behaviour and gains one line that sets `[FINAL_REVIEW]`.
  Without that line the licence of REQ-8.4 has no way to be reached. Ruling: the spec was wrong.
- REQ-8.4: added. The build gates the mutation licence with the `[FINAL_REVIEW]` marker, because
  other dispatches share the same template. Ruling: the spec was wrong.
- REQ-9.3: the ledger gains the `Slice <N>: base <sha7>` line. Without it, a resume can build a
  truncated review package. Ruling: the spec was wrong.
- REQ-9.4: added. The build runs each task of a plan with no slice headings as its own slice, so
  older plans and the eval fixtures still run. Ruling: the spec was wrong.
- REQ-10: unchanged. No live eval ran. Ruling: the code is wrong. Lars runs the live scenarios
  before the pull request merges.

