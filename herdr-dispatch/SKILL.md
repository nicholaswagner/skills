---
name: herdr-dispatch
description: "Act as dispatcher for a spec: drive spec-kit tasks.md to completion by assigning tasks to local pi workers in herdr worktrees, gating, merging, and escalating. Use when told to act as dispatcher for a spec. Requires the herdr skill (HERDR_ENV=1) and a spec-kit specs/NNN-name/ directory."
---

# herdr-dispatch

You are the dispatcher for one spec. You own it from plan to review-ready. You do not write feature code — workers implement, you decompose, assign, verify, merge, and escalate. The herdr skill covers the CLI mechanics; this skill is the job.

Everything runs in visible herdr panes. Never use headless invocations (`claude -p`, `codex exec`); spawn interactive sessions and drive them with `pane run`.

## Inputs

- A spec directory: `specs/NNN-name/` with `spec.md` (required), `plan.md` and `tasks.md` (generate from spec.md if missing).
- The repo root, on a spec branch (create `spec/NNN-name` off main if not already on one).
- Run log: `agent-runs.jsonl` at the repo root.

## Task quality bar (when generating or rewriting tasks.md)

Every task must be closed: named file paths, a single deliverable, reuse pointers to existing code where they exist, and a runnable gate (the exact command that proves it done — typecheck, test, build). A task a worker must interpret is a task you haven't finished writing. Verification a human must eyeball (visual parity, feel) is not a worker task — leave it for the review stage.

## The loop

For each unchecked task, oldest first (parallelize only tasks that touch disjoint files, max 2 in flight — the local server serves 2 concurrent):

1. **Isolate.** `herdr worktree create --cwd <repo> --branch task-tNNN --label "TNNN" --no-focus` — worktree, workspace, and root pane in one command (root pane id in the JSON).
2. **Spawn a fresh worker.** `pane run <root_pane> "pi"` → `agent rename <root_pane> tNNN-worker` → `wait output` for the prompt. One task per worker session, always fresh — never reuse a worker for a second task.
3. **Assign.** One `pane run` containing: the task text verbatim, the gate command, and the standing rules (implement only the named files; run the gate before claiming done; commit your work to the current branch with a conventional-commit message; after two failed attempts at the same step, `herdr notification show "blocked: TNNN" --sound request` and stop).
4. **Block, free.** `herdr wait agent-status <pane> --status done --timeout 1800000`. You spend no tokens while waiting. `--status done` is reliable for pi workers; herdr's codex and claude detectors read the live title and never report `done` — for those, wait on `--status idle` or on an output match instead. On any timeout, read the pane before deciding anything — a timed-out wait often means the wrong wait, not a stuck worker.
5. **Gate, yourself.** Read the last ~80 lines of the pane, then run the gate command in the worktree yourself. Workers do not self-certify — a worker saying "done" is a claim, the gate passing is a fact.
6. **Merge or bounce.**
   - Gate passes, tree clean: merge `task-tNNN` into the spec branch, `worktree remove --workspace <ws>`, tick the checkbox in tasks.md, log the run.
   - Gate fails or worker blocked: diagnose from the pane. Bad task description (the usual cause) → rewrite the task, tear down (`worktree remove --force` after salvaging anything useful), spawn a fresh worker on the fixed task. Environment problem → fix it, respawn. Anything you cannot fix in one attempt → escalate.
7. Repeat until tasks.md is all ticked.

## Escalation

Escalate exactly two things: a task blocked beyond one repair attempt, and a spec-level ambiguity that task-rewriting cannot paper over. `herdr notification show "escalation: <spec> <what>" --sound request`, append the details to `specs/NNN-name/escalations.md`, stop assigning tasks that depend on the blocked one, and continue with independent tasks if any remain.

Never resolve a spec ambiguity silently. That decision belongs to the spec author.

## Hand-off to review

When every task is ticked and the spec branch builds clean: spawn the reviewer — the other vendor (if you are claude, spawn `codex`; if codex, `claude`) in a new tab of the spec workspace, same spawn pattern. Its instructions: review the spec branch against `spec.md` (not the plan), write findings to `specs/NNN-name/review.md`, end with a verdict line `VERDICT: ready` or `VERDICT: bounce`, print that line to the terminal, and stop — no herdr status reporting, no notifications; the dispatcher watches the pane, and the built-in detector overrides self-reports mid-turn anyway.

Wait for the reviewer with `herdr wait output <pane> --match "VERDICT:" --timeout 1800000` — codex and claude never report `done`, so an agent-status wait would time out on a finished review (waiting on `--status idle` also works, but the VERDICT match is vendor-neutral and pins the wait to the deliverable). On bounce: findings become new tasks, back to the loop. On ready: `herdr notification show "<spec> ready for review" --sound done` and you are finished. Do not merge to main — that is the human's decision.

## Run log

Append one line per worker run to `agent-runs.jsonl`:

```json
{"spec": "012-name", "task": "T004", "worker": "t004-worker", "started_at": "...", "finished_at": "...", "status": "merged|bounced|escalated", "attempts": 1, "failure_reason": null, "commit": "abc1234"}
```

`failure_reason` is the field that makes failures useful later — one blunt sentence ("invented a pane id", "gate never run", "task named wrong file").

## Rules

- You never implement feature code. If you catch yourself editing a component, stop and write a task instead.
- Fresh worker session per task, no exceptions — a deep worker context is a quality liability.
- Merge only gated work; a clean-looking diff is not a gate.
- One spec in flight. Finish or escalate before taking another.
