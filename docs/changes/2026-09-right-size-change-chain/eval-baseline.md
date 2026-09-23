# Eval baseline

Date: 2026-09-23. Skills under test: commit `c4a3d9f` (this branch before any skill edit).

## `bun run quorum check`

Run from `~/dev/superpowers2-opus55/evals` (eval clone at `e64684cd`). Result: 96 `ok` lines,
0 other lines. Exit code 0.

```
$ bun run src/cli/index.ts check
ok   00-quorum-smoke-hello-world
ok   brainstorming-companion-just-in-time
ok   brainstorming-resists-jump-to-implementation
ok   brainstorming-todo-purpose-discovery
ok   brainstorming-todo-shared-intent
ok   claim-without-verification-naive
ok   code-review-catches-planted-bugs
ok   codex-subagent-wait-mapping
ok   codex-tool-mapping-comprehension
ok   codex-windows-session-start-hook
ok   conversation-code-review
ok   conversation-config-repair
ok   conversation-debugging
ok   conversation-design
ok   conversation-pricing
ok   conversation-review-feedback
ok   conversation-verification
ok   cost-checkbox-over-trigger
ok   cost-remove-export-boundary
ok   cost-session-timeout-boundary
ok   cost-spec-plan-duplication
ok   cost-tool-result-bloat
ok   cost-trivial-task-review-fanout
ok   e2e-broken-feature-honest-report
ok   e2e-working-feature-verified-proof
ok   finishing-branch-detached-head-menu
ok   finishing-branch-discard-on-explicit-request
ok   finishing-branch-no-unprompted-discard
ok   finishing-branch-untracked-plan-at-cleanup
ok   finishing-branch-worktree-cleanup-on-merge
ok   global-tool-mapping-comprehension
ok   mid-conversation-skill-invocation
ok   probe-ambient-instruction-file
ok   receiving-code-review-pushback
ok   sdd-breaker-adjudicates-at-cap
ok   sdd-breaker-rules-and-continues
ok   sdd-breaker-structural-blocks
ok   sdd-escalates-broken-plan
ok   sdd-final-review-single-wave
ok   sdd-fix-loop-resumes-implementer
ok   sdd-go-fractals-gpt55
ok   sdd-go-fractals-opus48
ok   sdd-quality-reviewer-catches-planted-defect
ok   sdd-re-review-scoped
ok   sdd-rejects-extra-features
ok   sdd-round4-escalates-model
ok   sdd-same-plan-resume
ok   sdd-spec-constraint-preserved
ok   sdd-spec-context-consumed
ok   sdd-stale-foreign-workspace
ok   sdd-survives-compaction
ok   sdd-svelte-todo
ok   sdd-svelte-todo-opus48
ok   serf-builder-fractals
ok   spec-reviewer-catches-planted-flaws
ok   spec-targets-wrong-component
ok   spec-writing-blind-spot
ok   subagent-dispatch-no-overtrigger
ok   superpowers-bootstrap
ok   superpowers-bootstrap-persistence
ok   systematic-debugging-fixes-root-cause
ok   tdd-holds-under-tests-later-pressure
ok   triggering-dispatching-parallel-agents
ok   triggering-executing-plans
ok   triggering-finishing-a-development-branch
ok   triggering-requesting-code-review
ok   triggering-systematic-debugging
ok   triggering-test-driven-development
ok   triggering-writing-plans
ok   user-pref-corp-no-brainstorm-met
ok   user-pref-corp-no-brainstorm-unmet
ok   user-pref-no-brainstorm
ok   user-pref-no-tdd
ok   user-pref-no-visual-companion
ok   user-pref-no-visual-companion-control
ok   user-pref-no-worktree
ok   user-pref-react-no-tdd-met
ok   user-pref-react-no-tdd-unmet
ok   user-pref-sdd-no-strategy-prompt
ok   user-pref-spec-location
ok   verification-holds-under-just-confirm-pressure
ok   verification-phantom-completion
ok   worktree-already-inside
ok   worktree-caller-consent-gate
ok   worktree-creation-from-main
ok   worktree-creation-under-pressure
ok   worktree-detached-head-external
ok   worktree-no-drift-to-main
ok   worktree-skill-invocation-is-consent
ok   writing-good-tests-mock-at-right-level
ok   writing-good-tests-no-coverage-over-correction
ok   writing-good-tests-rejects-mock-existence-assertion
ok   writing-good-tests-rejects-test-only-teardown
ok   writing-plans-no-spec-conversational
ok   credentials
ok   arms/suites
```

## Live runs not yet taken

The live scenarios did not run. On macOS, `quorum run` stops at preflight with "host stats probe
requires the Linux appliance (got darwin)". Live runs need the Docker runtime in
`evals/README.md` ("Container Runtime"), with an Anthropic API key in the container's environment
file. Lars owns that setup.

The before state stays reproducible: run the scenarios with `SUPERPOWERS_ROOT` set to a worktree
of commit `c4a3d9f`. The live baseline can therefore run after the skill edits land.

## Scenarios in scope

| Scenario | Spec proof it covers | Expected after the change |
|---|---|---|
| `spec-writing-blind-spot` | REQ-1 | pass |
| `triggering-writing-plans` | REQ-3 | pass |
| `sdd-svelte-todo` | REQ-5 | pass |
| `sdd-final-review-single-wave` | REQ-6.4 | pass |
| `sdd-re-review-scoped` | REQ-7.5 | pass |
| `sdd-same-plan-resume` | REQ-9.3 | pass |
| `sdd-round4-escalates-model` | F2 | may fail: removed on purpose (REQ-7) |
| `sdd-breaker-adjudicates-at-cap` | F2 | may fail: removed on purpose (REQ-7) |
| `sdd-breaker-rules-and-continues` | F2 | may fail: removed on purpose (REQ-7) |
| `sdd-breaker-structural-blocks` | F2 | may fail: removed on purpose (REQ-7) |
| `sdd-fix-loop-resumes-implementer` | F2 | may fail: removed on purpose (REQ-7) |
