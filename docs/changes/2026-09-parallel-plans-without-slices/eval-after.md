# Eval after

Date: 2026-09-25. Skills under test: commit `50ca8ae` (this branch after the fix wave).

## `bun run quorum check`

Run from `~/dev/superpowers2-opus55/evals` (eval clone at `e64684cd`) with
`SUPERPOWERS_ROOT=$HOME/dev/superpowers2`. Result: 96 `ok` lines, the same as the baseline.
Exit code 0. No scenario went from pass to fail in the static gate.

## Live scenarios: not run

Waived by Lars on 2026-09-25, as `eval-baseline.md` records. This file records no observed live
behaviour. No live scenario has a pass-to-fail label, because none ran.

To run them later: the 14 scenarios listed in `eval-baseline.md`, in the Docker runtime with
`DOCKER_DEFAULT_PLATFORM=linux/amd64` on Apple Silicon, once against `225ad6a` and once against
the merged result. Expected deliberate changes: scenarios that assert a per-slice review, a
slice-one checkpoint, or a second fix round now describe behaviour this change removes.

## What stands in for live evidence

- `tests/claude-code/test-task-brief.sh`: 5 of 5 pass, including the dotted legacy ID.
- `tests/claude-code/test-sdd-workspace.sh`: pass.
- `git grep -in slice -- skills`: no plan-slice mention (only JavaScript `.slice()` calls).
- `diff CLAUDE.md AGENTS.md`: identical.
- One final review, one fix wave and one scoped re-review: the fix wave closed every finding.
