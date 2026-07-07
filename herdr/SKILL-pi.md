---
name: herdr
description: "Control herdr from inside it: read other panes, run commands in splits, spawn and coordinate agents, wait for output or agent status. Use when running inside herdr (HERDR_ENV=1)."
---

# herdr

You are inside herdr, a terminal multiplexer for agents. The `herdr` CLI controls it. Structure: workspaces (id `wQ`) contain tabs (id `wQ:t1`) contain panes (id `wQ:p3`). Each pane is a terminal running a shell, server, or agent.

If `HERDR_ENV` is not `1`: you are not inside herdr. Say so and stop.

## Rules

1. Never guess ids and never reuse ids from earlier in the conversation. Get ids from `herdr pane list`, `herdr agent list`, or from the JSON printed by create/split/start commands.
2. Read ids straight from the JSON output and type them into your next command. Do not parse JSON with scripts.
3. `herdr wait output` matches only FUTURE output. Order matters: start the command first, then wait. For text already on screen use `herdr pane read`.
4. If a command prints a `not_found` error: do not retry the same id. Run `herdr pane list` and use a real id from its output. If the same command fails twice, stop and report the error.

## See what exists

```bash
herdr pane list        # every pane: pane_id, cwd, agent_status, focused
herdr agent list       # only panes running detected agents
herdr workspace list
```

The pane with `"focused": true` is yours. `agent_status` is one of: `idle`, `working`, `blocked`, `done`, `unknown`. `done` means the agent finished but nobody has looked at that pane yet.

## Read another pane's screen

```bash
herdr pane read wQ:p1 --source recent --lines 50
```

Prints plain text. Use `--source visible` for only the current viewport.

## Run a command in a new split

Step 1 — split your pane, keep focus:

```bash
herdr pane split wQ:p3 --direction right --no-focus
```

This prints JSON. The new pane id is the value of `"pane_id"` inside `"pane"`, for example `wQ:p4`. Use `--direction down` to split downward.

Step 2 — run the command in the new pane:

```bash
herdr pane run wQ:p4 "npm run dev"
```

Step 3 — wait for the output you expect:

```bash
herdr wait output wQ:p4 --match "ready" --timeout 30000
```

Exit code 1 means it timed out. If it times out, look at what actually happened:

```bash
herdr pane read wQ:p4 --source recent --lines 30
```

## Wait for another agent to finish, then read its result

```bash
herdr wait agent-status wQ:p1 --status done --timeout 120000
herdr pane read wQ:p1 --source recent --lines 80
```

## Spawn a new agent and give it a task

Always pass `--cwd`. The printed JSON has the new pane id at `"pane_id"`.

```bash
herdr agent start reviewer --cwd /path/to/repo --split right --no-focus -- pi
herdr wait output wQ:p4 --match ">" --timeout 15000
herdr pane run wQ:p4 "review the test coverage in src/api/"
```

The agent is now addressable by its name:

```bash
herdr agent get reviewer
herdr agent wait reviewer --status idle --timeout 120000
```

Note: `agent wait` accepts `idle|working|blocked|unknown` only. To wait for `done`, use `herdr wait agent-status <pane_id> --status done`.

## Notify the user

Use this when you finish a long task or become blocked:

```bash
herdr notification show "tests passed" --body "all 132 green" --sound done
herdr notification show "need input" --body "merge conflict in api.ts" --sound request
```

## Tabs, workspaces, cleanup

```bash
herdr tab create --workspace wQ --label "logs" --no-focus    # JSON: new ids under "tab" and "root_pane"
herdr workspace create --cwd /path --label "api" --no-focus  # JSON: new ids under "workspace", "tab", "root_pane"
herdr pane close wQ:p4
herdr tab close wQ:t2
herdr workspace close wR
```

## Other commands

```bash
herdr pane send-text wQ:p1 "text"   # literal text, no Enter (pane run = text + Enter)
herdr pane send-keys wQ:p1 Enter    # press a key
herdr agent explain claude          # shows why herdr assigned an agent its status
```
