# herdr CLI reference (verified against herdr 0.7.1, protocol 14, 2026-07-07)

Everything below was verified against a live instance. Re-verify after herdr
upgrades — id formats and output shapes have changed between versions before
(pre-0.7 `1-1` / `1:1` pane and tab ids are now legacy; current ids are
`wQ` / `wQ:t1` / `wQ:p3`).

## Output conventions

- Structured commands print single-line JSON: `{"id":"cli:<cmd>","result":{...}}`.
- Errors print `{"error":{"code":"...","message":"..."}}` and exit 1.
  Known codes: `pane_not_found`, `timeout`.
- `pane read` prints plain text (or ANSI with `--format ansi`).
  `agent read` prints JSON with the text in `result.read.text` — prefer
  `pane read` when you just want the screen contents.
- Silent on success: `pane send-text`, `pane send-keys`, `pane run`.

## Where new ids appear in create/split/start JSON

| Command            | New ids at                                              |
|--------------------|---------------------------------------------------------|
| `pane split`       | `result.pane.pane_id`                                   |
| `tab create`       | `result.tab.tab_id`, `result.root_pane.pane_id`         |
| `workspace create` | `result.workspace.workspace_id`, `result.tab`, `result.root_pane` |
| `agent start`      | `result.agent.pane_id`, `result.agent.name`             |

## pane

```
herdr pane list [--workspace ID]
herdr pane current | get <pane_id> | layout | process-info
herdr pane neighbor --direction left|right|up|down [--pane ID|--current]
herdr pane edges | focus --direction ... | resize --direction ... [--amount F]
herdr pane zoom [<pane_id>] [--toggle|--on|--off]
herdr pane rename <pane_id> <label>|--clear
herdr pane read <pane_id> [--source visible|recent|recent-unwrapped] [--lines N] [--format text|ansi]
herdr pane split [<pane_id>] --direction right|down [--ratio F] [--cwd PATH] [--env K=V] [--focus|--no-focus]
herdr pane swap --direction ... | --source-pane ID --target-pane ID
herdr pane move <pane_id> --tab <tab_id> --split right|down [--target-pane ID]
herdr pane move <pane_id> --new-tab [--workspace ID] [--label TEXT]
herdr pane move <pane_id> --new-workspace [--label TEXT] [--tab-label TEXT]
herdr pane close <pane_id>
herdr pane send-text <pane_id> <text>       # literal, no Enter
herdr pane send-keys <pane_id> <key> ...    # e.g. Enter
herdr pane run <pane_id> <command>          # send-text + Enter in one request
```

`--source recent` = rendered scrollback; `recent-unwrapped` = soft wraps
joined (this is the transcript `wait output --source recent` matches, so use
it when debugging a failed wait).

`pane report-agent`, `report-agent-session`, `release-agent`,
`report-metadata` exist for agent integrations reporting their own status;
agents controlling herdr normally never call these.

## agent

Targets accept terminal ids, unique agent names (the `name` field from
`agent start`), detected agent labels (e.g. `claude`, `pi`), and legacy pane
ids.

```
herdr agent list
herdr agent get <target>
herdr agent read <target> [--source ...] [--lines N]     # JSON output, see above
herdr agent send <target> <text>                          # literal text, no Enter
herdr agent rename <target> <name>|--clear
herdr agent focus <target>
herdr agent wait <target> --status idle|working|blocked|unknown [--timeout MS]
herdr agent attach <target> [--takeover]
herdr agent start <name> [--cwd PATH] [--workspace ID] [--tab ID] [--split right|down]
                 [--env K=V] [--focus|--no-focus] -- <argv...>
herdr agent explain <target> [--json]     # detection rule + evidence for current status
```

Verified gotchas:

- `agent start` does NOT inherit the target workspace's cwd — always pass
  `--cwd` explicitly.
- `agent wait` has no `done` status. For done-and-unviewed semantics use
  `herdr wait agent-status <pane_id> --status done`.
- `agent send` writes literal text; use `pane run` to submit a prompt
  (text + Enter).
- `agent start` never creates a tab or workspace: with `--workspace` or
  `--tab` it splits into that (existing) tab, so pointing it at a freshly
  created tab leaves a stray empty root pane. Placement doctrine: split for
  sidecars, tab for a teammate, workspace for a different project. The
  clean non-sidecar spawn is `tab create` / `workspace create` →
  `pane run <root_pane> "<agent cmd>"` → `agent rename <pane_id> <name>`
  (rename works even before agent detection kicks in).

## wait

```
herdr wait output <pane_id> --match <text> [--regex] [--source ...] [--lines N] [--timeout MS] [--raw]
herdr wait agent-status <pane_id> --status idle|working|blocked|done|unknown [--timeout MS]
```

`wait output` matches only future output (start the command, then wait), and
matches against unwrapped recent text so pane width doesn't break matches.
Timeout → exit code 1 with `{"error":{"code":"timeout",...}}`.

## tab / workspace

```
herdr tab list [--workspace ID]
herdr tab create [--workspace ID] [--cwd PATH] [--label TEXT] [--env K=V] [--focus|--no-focus]
herdr tab get|focus|close <tab_id>
herdr tab rename <tab_id> <label>

herdr workspace list
herdr workspace create [--cwd PATH] [--label TEXT] [--env K=V] [--focus|--no-focus]
herdr workspace get|focus|close <workspace_id>
herdr workspace rename <workspace_id> <label>
```

Without `--label`: workspaces get cwd-based names, tabs get numbers.

## notification

```
herdr notification show <title> [--body TEXT]
                        [--position top-left|top-right|bottom-left|bottom-right]
                        [--sound none|done|request]
```

## Not covered by the skill (deliberately — see TODO.md)

`worktree` (git worktree ↔ workspace helpers), `session`, `integration`,
`config`, `channel`, `server`, `status`, `update`. Run `herdr <sub> --help`
if needed; the raw socket protocol is at https://herdr.dev/docs/socket-api/.
