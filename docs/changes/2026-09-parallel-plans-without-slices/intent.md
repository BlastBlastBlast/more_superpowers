# Intent: parallel plans without slices

Author: Lars. Date: 2026-09-25. Status: approved.

## Problem

The change chain turns a clear spec into a long sequential chain. The plan cuts work into slices,
runs implement, review, fix and re-review per slice, and orders the backend before the frontend, so
Lars waits hours before he sees anything. The trusthere CLAUDE.md rewrite (session `97dcc43a`) was
md-only work against one audit. It became 22 tasks in 5 slices, Slices 1–4 took 7.5 hours, and the
run continued overnight.

## Proposed outcome

- An approved spec becomes a plan of tasks in the traditional superpowers style.
- Tasks that do not depend on each other run as parallel subagents, the way Anthropic runs its own
  fan-outs: independent units, clear task boundaries, and a script or test as the referee.
- No slices, no demo commands, no per-slice reviews.
- The whole diff gets one review and then one fix wave. One reviewer is the default; reviewers split
  by failure category only when the diff is too large for one reviewer to read well.
- Parallel tasks in one wave edit disjoint files in one shared working tree on the one feature
  branch. Subagents do not run git state commands. The controller commits once per wave. Tasks that
  must edit the same file go into a later wave. Execution never switches branches.
- A task is one independent unit, not a count of files. The three-file task limit goes.
- A docs or instruction-file change gets its own path, with no TDD steps.
- One spec requirement is enough to make a task. Sub-requirements add detail to their requirement;
  they are not tasks of their own.
- The spec keeps its guardrails and its clear statement of what is about to happen.
- `reconciling-specs` stays as the finishing check that the spec was implemented, with no slice
  concepts left in it.

## Affected users and systems

- Everyone who uses this fork.
- Skills: `writing-plans`, `subagent-driven-development` (with its reviewer and re-review prompts),
  `executing-plans`, `brainstorming`, `writing-specs`, `reconciling-specs`,
  `requesting-code-review`.
- `CLAUDE.md` and `AGENTS.md`, which describe the change chain.

## Constraints

- The chain stays: intent, spec, plan, implement, review, reconcile, finish.
- The spec keeps its guardrails and its RFC 2119 clarity.
- Red Flags tables, rationalization lists and "your human partner" wording change only with evidence.
- Eval evidence: the static gate, plus before-and-after runs of the affected scenarios. The full set
  runs once before the PR.
- The plugin stays zero-dependency and self-contained.

## Out of scope

- An early view or human checkpoint during execution. Lars sees the result at the final review.
- Changes submitted to obra/superpowers.
- The Claude Code bug that routed a mid-turn stop message to a subagent.

## How we will know it worked

- A change the size of the trusthere rewrite runs in about 1.5 hours, not 7.5.
- Independent tasks go out in one wave.
- The run uses one review and one fix wave.
- Nothing switches branches during execution.
- Read on the next real spec-driven change.

## Open questions

- The threshold at which the final review splits into reviewers by failure category.
