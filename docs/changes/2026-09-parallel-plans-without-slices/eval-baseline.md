# Eval baseline

Date: 2026-09-25. Skills under test: commit `225ad6a` (this branch before any skill edit), checked
out as a separate worktree so the Wave 1 edits could not leak in.

## `bun run quorum check`

Run from `~/dev/superpowers2-opus55/evals` (eval clone at `e64684cd`) with
`SUPERPOWERS_ROOT=$HOME/dev/sp2-baseline`. Result: 96 `ok` lines, 0 other lines apart from the
command echo. Exit code 0.

## Live scenarios: not run

`quorum run-all` stopped with "host stats probe requires the Linux appliance (got darwin)". Per-scenario
`quorum run` stopped at the same preflight, and parallel starts also collided on the live-spend lock.
Live runs need the Docker runtime and an `.env.container` holding `ANTHROPIC_API_KEY`.

**Lars waived the live runs on 2026-09-25.** This file records no observed live behaviour.

The 14 affected scenarios, for a later run: `triggering-writing-plans`,
`triggering-executing-plans`, `spec-writing-blind-spot`, `cost-spec-plan-duplication`,
`cost-trivial-task-review-fanout`, `sdd-final-review-single-wave`, `sdd-re-review-scoped`,
`sdd-fix-loop-resumes-implementer`, `sdd-same-plan-resume`, `sdd-survives-compaction`,
`sdd-spec-context-consumed`, `sdd-spec-constraint-preserved`, `sdd-breaker-adjudicates-at-cap`,
`sdd-svelte-todo`.
