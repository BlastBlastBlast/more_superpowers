# Eval evidence after the change

Date: 2026-09-23. Skills under test: commit `2b8d1b5`. Before state: commit `c4a3d9f` (see `eval-baseline.md`).

## `bun run quorum check`

Before: 96 `ok` lines, exit 0. After: 96 `ok` lines, exit 0. No line changed.

## Live scenarios: not run, before or after

No live scenario ran for this change. `quorum run` stops on macOS at preflight with "host stats
probe requires the Linux appliance (got darwin)". Live runs need the Docker runtime and an Anthropic
API key, which Lars owns. **This table records no observed live result.** The "Expected" column is
a prediction from the spec, not evidence.

| Scenario | Before | After | Expected | Classification if it flips |
|---|---|---|---|---|
| `spec-writing-blind-spot` | not run | not run | pass | broke: REQ-1 |
| `triggering-writing-plans` | not run | not run | pass | broke: REQ-3 |
| `sdd-svelte-todo` | not run | not run | may fail | removed on purpose: REQ-5 |
| `sdd-final-review-single-wave` | not run | not run | pass | broke: REQ-6.4 |
| `sdd-re-review-scoped` | not run | not run | pass | broke: REQ-7.5 |
| `sdd-same-plan-resume` | not run | not run | pass | broke: REQ-9.3 |
| `sdd-round4-escalates-model` | not run | not run | fail | removed on purpose: REQ-7 (F2 ruling A) |
| `sdd-breaker-adjudicates-at-cap` | not run | not run | fail at round 5, pass at round 2 | removed on purpose: REQ-7 (F2 ruling A) |
| `sdd-breaker-rules-and-continues` | not run | not run | fail at round 5, pass at round 2 | removed on purpose: REQ-7 (F2 ruling A) |
| `sdd-breaker-structural-blocks` | not run | not run | fail at round 5, pass at round 2 | removed on purpose: REQ-7 (F2 ruling A) |
| `sdd-fix-loop-resumes-implementer` | not run | not run | depends on the round it asserts | removed on purpose if it asserts rounds 1-3 resume; else pass |
| `sdd-quality-reviewer-catches-planted-defect` | not run | not run | may fail | removed on purpose: REQ-5 |
| `sdd-survives-compaction` | not run | not run | may fail | removed on purpose: REQ-5 |
| `sdd-escalates-broken-plan` | not run | not run | may fail | removed on purpose: REQ-5 |
| `sdd-rejects-extra-features` | not run | not run | may fail | removed on purpose: REQ-5 |

## What stands in for live evidence

`docs/changes/2026-09-right-size-change-chain/check.sh all` turns each spec proof line into a pass
or fail check: 24 checks, all PASS, exit 0 at `2b8d1b5`. Each check went from FAIL to PASS in its task
(reports under the SDD workspace). The check proves that the skill text says what the spec
requires. It does not prove that an agent reading the text behaves that way. Only the live
scenarios prove that.

## To finish REQ-10

Run the eleven scenarios twice in the Docker runtime: once with `SUPERPOWERS_ROOT` at a worktree
of `c4a3d9f`, once at `2b8d1b5` or later. Replace the Before and After columns with the verdicts.
