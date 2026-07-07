---
name: herdr
description: "Control herdr from inside it. Manage workspaces and tabs, split panes, spawn agents, read output, and wait for state changes — all via CLI commands that talk to the running herdr instance over a local unix socket. Use when running inside herdr (HERDR_ENV=1)."
---

# herdr

herdr is a terminal multiplexer for agents; when `HERDR_ENV=1` you are running in one of its panes and the `herdr` CLI (in PATH) controls the whole instance over a local socket. If `HERDR_ENV` is not `1`, say you are not inside herdr and stop.

Hierarchy: workspace (`wQ`) → tabs (`wQ:t1`) → panes (`wQ:p3`). Each pane is a real terminal running a shell, server, or agent. You can read any pane, run commands in new splits, spawn more agents, and block on output or agent status.

## Ground rules (verified against herdr 0.7.1)

- **Ids come from output, never from memory.** Read them from `pane list` / `agent list` / `workspace list` or from create/split/start JSON (`pane split` → `result.pane.pane_id`; `agent start` → `result.agent.pane_id`). Ids can compact when things close; `1-1`-style ids are legacy.
- **`wait output` matches only future output.** Launch first, then wait; use `pane read` for text already on screen. On timeout (exit 1), `pane read` to see what actually happened.
- **Placement: split for sidecars, tab for a teammate, workspace for a different project.** Splits are for processes you watch alongside your current work (server, logs, tests). A new agent with its own task gets its own tab (same project) or workspace (different project) — create the container, run the agent in its root pane.
- **`agent start` does not inherit the workspace cwd (always pass `--cwd`) and never creates a tab** — with `--workspace`/`--tab` it splits into the existing tab. Use it only for sidecar-placed agents.
- **`agent wait` lacks `done`.** For finished-but-unviewed, use `herdr wait agent-status <pane_id> --status done`.
- **On `not_found`: re-run `pane list` and pick a real id.** Never retry the failed id; stop after two failures of the same command.
- Structured commands print JSON; `pane read` prints plain text; `send-text`/`send-keys`/`run` print nothing on success.

## Core commands

```bash
herdr pane list                                        # all panes; "focused": true is you
herdr agent list                                       # panes with detected agents; status: idle|working|blocked|done|unknown
herdr pane read wQ:p1 --source recent --lines 50       # plain text; --source visible for viewport only
herdr pane split wQ:p3 --direction right --no-focus    # or down; new id in printed JSON
herdr pane run wQ:p4 "npm run dev"                     # text + Enter (send-text/send-keys for finer control)
herdr wait output wQ:p4 --match "ready" --timeout 30000        # --regex supported
herdr wait agent-status wQ:p1 --status done --timeout 120000
herdr notification show "done" --body "tests green" --sound done   # --sound request when blocked
herdr pane close wQ:p4 / tab close wQ:t2 / workspace close wR
herdr tab create --workspace wQ --label "logs" --no-focus
herdr workspace create --cwd /path --label "api" --no-focus
herdr agent explain claude                             # detection rule + evidence for an agent's status
```

## Spawn an agent and give it a task

New tab in the current workspace (use `workspace create --cwd ... --label ...` instead for a different project — same flow, root pane id in its JSON too):

```bash
herdr tab create --workspace wQ --label "reviewer" --cwd /path/to/repo --no-focus   # root pane id in JSON
herdr pane run wQ:p5 "pi"
herdr agent rename wQ:p5 reviewer                      # optional: name it for agent-targeting
herdr wait output wQ:p5 --match ">" --timeout 15000
herdr pane run wQ:p5 "review the test coverage in src/api/"
```

The name (`reviewer`) then works as a target: `agent get reviewer`, `agent read reviewer`, `agent wait reviewer --status idle`. For a sidecar agent next to your current pane, `herdr agent start reviewer --cwd /path --split right --no-focus -- pi` does spawn + name in one command.

## Full reference

Complete verified command surface, output shapes, and gotchas: [references/cli.md](references/cli.md). Anything not covered there (worktrees, sessions, config): `herdr <subcommand> --help`. Raw socket protocol: https://herdr.dev/docs/socket-api/
