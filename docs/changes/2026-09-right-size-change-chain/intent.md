# Intent: right-size the change chain

Author: Lars. Date: 2026-09-23. Status: approved.

## Problem

A change that is simple in concept but touches many systems takes most of a working day to go
through the chain. Trusthere PR #357 took about 6 hours: 24 subagent dispatches, 5.4 agent-hours run
one after another, a spec with about 40 requirements, and a 974-line plan. This happened although
Lars asked for a simple spec and plan. Each slice went to one subagent, so one slice grew into a
56-minute run, and one run died before it committed.

## Proposed outcome

The chain still runs intent, spec and plan, but the spec is only as big as the change. A simple
change gets a short spec that covers the behaviour someone can observe.

A slice is a checkpoint where Lars sees the full vertical picture. Slice one is the MVP with visible
output. A slice is not one subagent: each slice is split into small tasks that each fit one
subagent. Review happens once per slice, at its checkpoint, plus the final whole-branch review.

The plan says what to build and how to test it. It does not repeat code the implementer can read in
the repo.

## Affected users and systems

- Everyone on the team who uses the fork's change chain. Trusthere is the main consumer today.
- Skills: `writing-specs`, `writing-plans`, `subagent-driven-development`,
  `requesting-code-review` and its reviewer prompts, and
  `test-driven-development/writing-good-tests.md`.
- The eval scenarios that cover these skills.

## Constraints

- The chain keeps intent, spec and plan for changes that are not bounded. The bounded and
  architectural routing in `brainstorming` does not change.
- The slice-one checkpoint stays: the human sees slice one before the rest runs.
- The final whole-branch review stays on the most capable model. It found the most important bugs
  in #357.
- The implementer's mental mutation check in `writing-good-tests.md` stays as it is.
- A behaviour change to a skill carries eval evidence from before and after the change.
- Red Flags tables and rationalization lists change only with evidence.
- The change ships as one pull request.

## Out of scope

- The brainstorming interview and the spike, bounded and architectural classification.
- Parallel dispatch of independent slices.
- The spec reconciliation stage, except where a shorter spec changes what it reads.
- Changes in the trusthere repo itself.

## How we will know it worked

- The next trusthere change of similar size uses about half the dispatches and agent-hours of #357:
  about 12 dispatches or fewer, and less than 3 agent-hours.
- No subagent run takes longer than about 20 minutes.
- The final review still finds the kind of defects that reviews found in #357.
- The eval scenarios for the touched skills pass before and after, and every change from pass to
  fail is explained.

## Open questions

- **Q1:** How the spec skill measures "as big as the change". Lars leaves this to the spec author
  to evaluate.
- **Q2:** What size a task is, as a rule the plan writer can check. Lars leaves this to the spec
  author to evaluate.
- **Q3:** The fix loop after a slice review. Lars thinks 5 rounds is a lot, and asks whether
  reviewing can run in parallel.

## Decisions taken during the interview

- **D1** Review happens once per slice, at its checkpoint. After each task the session runs the
  tests. The final whole-branch review stays.
- **D2** Reviewers make real code mutations only in the final review. The implementer's mental
  mutation check stays.
- **D3** One pull request for the whole change.
