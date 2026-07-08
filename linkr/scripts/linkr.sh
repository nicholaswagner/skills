#!/usr/bin/env bash
# linkr — manage symlinks from the skills repo into agent skill directories.
#
# Usage:
#   linkr.sh list
#   linkr.sh link    <skill> [agent]
#   linkr.sh unlink  <skill> [agent]
#   linkr.sh enable  <skill> [agent]
#   linkr.sh disable <skill> [agent]
#
# <agent> is one of: claude, codex, pi, all. Omitted means "all".
#
# Environment overrides (mainly for testing):
#   LINKR_REPO        skills repo root (default: ~/Repos/dev.nicholaswagner/skills)
#   LINKR_CLAUDE_DIR  claude skills dir (default: ~/.claude/skills)
#   LINKR_CODEX_DIR   codex skills dir  (default: ~/.codex/skills)
#   LINKR_PI_DIR      pi skills dir     (default: ~/.agents/skills)
set -euo pipefail

REPO="${LINKR_REPO:-$HOME/Repos/dev.nicholaswagner/skills}"
CLAUDE_DIR="${LINKR_CLAUDE_DIR:-$HOME/.claude/skills}"
CODEX_DIR="${LINKR_CODEX_DIR:-$HOME/.codex/skills}"
PI_DIR="${LINKR_PI_DIR:-$HOME/.agents/skills}"

AGENTS=(claude codex pi)

die() { echo "linkr: error: $*" >&2; exit 1; }

agent_dir() {
  case "$1" in
    claude) echo "$CLAUDE_DIR" ;;
    codex)  echo "$CODEX_DIR" ;;
    pi)     echo "$PI_DIR" ;;
    *)      die "unknown agent '$1' (expected claude, codex, pi, or all)" ;;
  esac
}

# All skills in the repo: top-level directories containing a SKILL.md.
repo_skills() {
  local d
  for d in "$REPO"/*/; do
    [ -f "$d/SKILL.md" ] && basename "$d"
  done
}

require_skill() {
  [ -d "$REPO/$1" ] || die "no directory '$1' in $REPO"
  [ -f "$REPO/$1/SKILL.md" ] || die "'$1' exists in the repo but has no SKILL.md"
}

# Does this symlink point at $REPO/$skill? Compare resolved physical paths
# when the target exists; fall back to a case/slash-normalized string compare
# for broken links (macOS filesystems are case-insensitive, and hand-made
# links vary in casing and trailing slashes).
points_at_skill() {
  local link="$1" skill="$2" target
  target="$(readlink "$link")"
  if [ -e "$link" ]; then
    [ "$link" -ef "$REPO/$skill" ]  # same inode, regardless of path spelling
  else
    [ "$(printf %s "${target%/}" | tr '[:upper:]' '[:lower:]')" = \
      "$(printf %s "$REPO/$skill" | tr '[:upper:]' '[:lower:]')" ]
  fi
}

# State of <skill> in <agent-dir>: linked | disabled | broken | foreign | absent
state_of() {
  local dir="$1" skill="$2"
  local active="$dir/$skill" disabled="$dir/.disabled/$skill"
  if [ -L "$active" ]; then
    if points_at_skill "$active" "$skill"; then
      [ -e "$active" ] && echo linked || echo broken
    else
      echo foreign
    fi
  elif [ -e "$active" ]; then
    echo foreign
  elif [ -L "$disabled" ]; then
    echo disabled
  else
    echo absent
  fi
}

do_link() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  mkdir -p "$dir"
  case "$(state_of "$dir" "$skill")" in
    linked)   echo "$agent: $skill already linked" ;;
    disabled) echo "$agent: $skill is disabled — use 'enable' to reactivate it" ;;
    foreign)  echo "$agent: SKIPPED — $dir/$skill exists and is not a linkr symlink (not touching it)" ;;
    broken)   rm "$dir/$skill"; ln -s "$REPO/$skill" "$dir/$skill"; echo "$agent: relinked $skill (was broken)" ;;
    absent)   ln -s "$REPO/$skill" "$dir/$skill"; echo "$agent: linked $skill" ;;
  esac
}

do_unlink() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  case "$(state_of "$dir" "$skill")" in
    linked|broken) rm "$dir/$skill"; echo "$agent: unlinked $skill" ;;
    disabled)      rm "$dir/.disabled/$skill"; echo "$agent: removed disabled link for $skill" ;;
    foreign)       echo "$agent: SKIPPED — $dir/$skill is not a linkr symlink (not touching it)" ;;
    absent)        echo "$agent: $skill not linked (nothing to do)" ;;
  esac
}

do_disable() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  case "$(state_of "$dir" "$skill")" in
    linked|broken) mkdir -p "$dir/.disabled"; mv "$dir/$skill" "$dir/.disabled/$skill"; echo "$agent: disabled $skill" ;;
    disabled)      echo "$agent: $skill already disabled" ;;
    foreign)       echo "$agent: SKIPPED — $dir/$skill is not a linkr symlink (not touching it)" ;;
    absent)        echo "$agent: $skill not linked (nothing to disable)" ;;
  esac
}

do_enable() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  case "$(state_of "$dir" "$skill")" in
    disabled) mv "$dir/.disabled/$skill" "$dir/$skill"; echo "$agent: enabled $skill" ;;
    linked)   echo "$agent: $skill already enabled" ;;
    broken)   rm "$dir/$skill"; ln -s "$REPO/$skill" "$dir/$skill"; echo "$agent: relinked $skill (was broken)" ;;
    foreign)  echo "$agent: SKIPPED — $dir/$skill is not a linkr symlink (not touching it)" ;;
    absent)   do_link "$agent" "$skill" ;;  # enabling something never linked just links it
  esac
}

do_list() {
  printf '%-24s %-10s %-10s %-10s\n' SKILL CLAUDE CODEX PI
  local skill agent dir state row
  while IFS= read -r skill; do
    row=""
    for agent in "${AGENTS[@]}"; do
      dir="$(agent_dir "$agent")"
      state="$(state_of "$dir" "$skill")"
      [ "$state" = absent ] && state="-"
      row="$row$(printf ' %-10s' "$state")"
    done
    printf '%-24s%s\n' "$skill" "$row"
  done < <(repo_skills)

  # Surface anything in the agent dirs that points into the repo but whose
  # source skill no longer exists (stale links from renamed/deleted skills).
  local entry target
  for agent in "${AGENTS[@]}"; do
    dir="$(agent_dir "$agent")"
    for entry in "$dir"/* "$dir"/.disabled/*; do
      [ -L "$entry" ] || continue
      target="$(readlink "$entry")"
      case "$(printf %s "$target" | tr '[:upper:]' '[:lower:]')" in
        "$(printf %s "$REPO" | tr '[:upper:]' '[:lower:]')"/*)
          [ -e "$entry" ] || echo "stale: $entry -> $target (source gone; 'unlink' it)" ;;
      esac
    done
  done 2>/dev/null
}

cmd="${1:-list}"
case "$cmd" in
  list) do_list ;;
  link|unlink|enable|disable)
    skill="${2:-}"; [ -n "$skill" ] || die "usage: linkr.sh $cmd <skill> [claude|codex|pi|all]"
    require_skill "$skill"
    agent="${3:-all}"
    if [ "$agent" = all ]; then
      for a in "${AGENTS[@]}"; do "do_$cmd" "$a" "$skill"; done
    else
      agent_dir "$agent" >/dev/null  # validate name before acting
      "do_$cmd" "$agent" "$skill"
    fi
    ;;
  *) die "unknown command '$cmd' (expected list, link, unlink, enable, disable)" ;;
esac
