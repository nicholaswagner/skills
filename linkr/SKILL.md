---
name: linkr
description: Manage which skills from the dev.nicholaswagner/skills repo are available to each coding agent (Claude Code, Codex, Pi) by creating and removing symlinks in their skill directories. Use whenever the user asks to link, unlink, enable, disable, install, activate, deactivate, or list skills for an agent — e.g. "link the tv skill to codex", "disable herdr in pi", "enable yt-dlp everywhere", "which skills does claude have?".
---

# linkr — skill symlink manager

Frontier skills live in the repo root at `~/Repos/dev.nicholaswagner/skills`
(any top-level directory containing a `SKILL.md`). Crisp skills live in
`~/Repos/dev.nicholaswagner/skills/crisp/<skill>/`; these are compact,
explicit variants for bounded-context models. Each agent discovers skills in
its own directory, so making a skill available to an agent is just a symlink:

| Agent | Skill directory |
| --- | --- |
| `claude` (Claude Code) | `~/.claude/skills` |
| `codex` (Codex) | `~/.codex/skills` |
| `pi` (Pi) | `~/.agents/skills` |

All operations go through the bundled script — run it rather than composing
`ln`/`rm` by hand, because it enforces the safety rules below:

```sh
scripts/linkr.sh list                                # state of every skill × agent
scripts/linkr.sh link    <skill> [agent]             # symlink frontier skill into agent dir
scripts/linkr.sh unlink  <skill> [agent]             # remove the frontier symlink
scripts/linkr.sh disable <skill> [agent]             # park frontier symlink in <dir>/.disabled/
scripts/linkr.sh enable  <skill> [agent]             # restore from .disabled (or link fresh)
scripts/linkr.sh link <skill> [agent] --crisp        # use crisp/<skill> instead
scripts/linkr.sh list --crisp                        # only show crisp skill rows
```

`[agent]` is `claude`, `codex`, `pi`, or `all`; omitting it means `all`, so
"enable X globally" is just `enable <skill>`.

## Semantics worth knowing

- **disable vs unlink**: `disable` moves the symlink into the agent dir's
  `.disabled/` folder (hidden, so agents don't scan it) — re-enabling is a
  move back, no paths to remember. `unlink` removes the link entirely
  (including a disabled one).
- **enable** on a skill that was never linked simply links it.
- **frontier vs crisp**: root skills are the default frontier variant.
  Passing `--crisp` makes `link`, `enable`, `disable`, and `unlink` operate
  on `crisp/<skill>/` instead. A single agent cannot have both variants of
  the same skill name active at once; `list` shows the occupied variant in
  that agent column.
- **Safety**: the script only ever removes *symlinks*. If the target name is
  a real file or directory (e.g. a skill someone copied in rather than
  linked, or a link into a different repo), it reports `SKIPPED` and leaves
  it alone. Relay those skips to the user instead of forcing past them.
- **Broken links** (skill renamed/deleted in the repo) are repaired by
  `link`/`enable` and flagged by `list` as `stale`.
- New skills need no registration — anything added to the repo root with a
  `SKILL.md` shows up as `frontier`; anything added under `crisp/` with a
  `SKILL.md` shows up as `crisp`.

## Examples

- "link the tv skill to codex" → `scripts/linkr.sh link tv codex`
- "disable herdr in pi" → `scripts/linkr.sh disable herdr pi`
- "link the crisp herdr skill to pi" → `scripts/linkr.sh link herdr pi --crisp`
- "enable yt-dlp everywhere" → `scripts/linkr.sh enable yt-dlp`
- "what's linked where?" → `scripts/linkr.sh list`

The script is also on PATH as `linkr` (symlinked into `~/.local/bin`); if
that command isn't found, run it by absolute path (this skill directory +
`scripts/linkr.sh`). After a mutation, run `list` to confirm and show the
user the resulting state.
