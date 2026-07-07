# herdr skill — deferred work

- **Worktrees pass** — document `herdr worktree list/create/open/remove`
  (git worktree ↔ workspace helpers) for parallel-agent workflows on one
  repo. Deliberately skipped in the 2026-07-07 rewrite to keep the core
  skill small; add once the slim core proves itself with the pi agents.
- ~~Wire up the pi variant~~ — done 2026-07-07: `~/.agents/skills/herdr/`
  is a real directory whose `SKILL.md` symlinks to this repo's
  `SKILL-pi.md`; Claude's `~/.claude/skills/herdr` symlinks to this
  directory (frontier `SKILL.md`). Two consumers, two entry points, one
  source of truth.
- **Re-verify on herdr upgrades** — everything was verified against
  herdr 0.7.1 / protocol 14. Id formats and output shapes have changed
  across versions before (legacy `1-1` pane ids → `wQ:p3`). After an
  upgrade, spot-check: `pane list` id format, `pane split` JSON shape,
  `agent start` cwd behavior, `agent wait` status list (still no `done`?).
- **Eval the pi variant** — run a few scripted tasks (split-and-serve,
  wait-for-sibling, spawn-and-task) through a pi agent and count
  invented-id / wrong-command failures vs the old skill. skill-creator has
  an eval harness if this wants to be systematic.
