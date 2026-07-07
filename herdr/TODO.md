# herdr skill — deferred work

- ~~Worktrees pass~~ — done 2026-07-07: verified live (create/list/remove,
  dirty-worktree --force behavior) and documented in SKILL.md +
  references/cli.md. Frontier files only — workers don't create worktrees,
  the dispatcher does, so SKILL-pi.md keeps its token budget.
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
