#!/usr/bin/env bash
# linkr — manage symlinks from the skills repo into agent skill directories.
#
# Usage:
#   linkr.sh list [--crisp]
#   linkr.sh link    <skill> [agent] [--crisp]
#   linkr.sh unlink  <skill> [agent] [--crisp]
#   linkr.sh enable  <skill> [agent] [--crisp]
#   linkr.sh disable <skill> [agent] [--crisp]
#
# <agent> is one of: claude, codex, pi, all. Omitted means "all".
#
# Environment overrides (mainly for testing):
#   LINKR_REPO        skills repo root (default: ~/Repos/dev.nicholaswagner/skills)
#   LINKR_CRISP_DIR   crisp skills dir (default: $LINKR_REPO/crisp)
#   LINKR_CLAUDE_DIR  claude skills dir (default: ~/.claude/skills)
#   LINKR_CODEX_DIR   codex skills dir  (default: ~/.codex/skills)
#   LINKR_PI_DIR      pi skills dir     (default: ~/.agents/skills)
set -euo pipefail

REPO="${LINKR_REPO:-$HOME/Repos/dev.nicholaswagner/skills}"
CRISP_DIR="${LINKR_CRISP_DIR:-$REPO/crisp}"
CLAUDE_DIR="${LINKR_CLAUDE_DIR:-$HOME/.claude/skills}"
CODEX_DIR="${LINKR_CODEX_DIR:-$HOME/.codex/skills}"
PI_DIR="${LINKR_PI_DIR:-$HOME/.agents/skills}"

AGENTS=(claude codex pi)
VARIANT=frontier

die() { echo "linkr: error: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage:
  linkr.sh list [--crisp]
  linkr.sh link    <skill> [claude|codex|pi|all] [--crisp]
  linkr.sh unlink  <skill> [claude|codex|pi|all] [--crisp]
  linkr.sh enable  <skill> [claude|codex|pi|all] [--crisp]
  linkr.sh disable <skill> [claude|codex|pi|all] [--crisp]

Options:
  --crisp     Work with crisp/<skill>: compact, explicit skill variants.
  --frontier  Work with root skill directories. This is the default.
EOF
}

args=()
for arg in "$@"; do
  case "$arg" in
    --crisp) VARIANT=crisp ;;
    --frontier) VARIANT=frontier ;;
    -h|--help) usage; exit 0 ;;
    *) args+=("$arg") ;;
  esac
done
set -- "${args[@]}"

agent_dir() {
  case "$1" in
    claude) echo "$CLAUDE_DIR" ;;
    codex)  echo "$CODEX_DIR" ;;
    pi)     echo "$PI_DIR" ;;
    *)      die "unknown agent '$1' (expected claude, codex, pi, or all)" ;;
  esac
}

source_root() {
  case "$VARIANT" in
    frontier) echo "$REPO" ;;
    crisp) echo "$CRISP_DIR" ;;
    *) die "unknown variant '$VARIANT'" ;;
  esac
}

# All frontier skills: top-level directories containing a SKILL.md.
frontier_skills() {
  local d
  for d in "$REPO"/*/; do
    [ -f "$d/SKILL.md" ] && basename "$d"
  done
}

crisp_skills() {
  local d
  for d in "$CRISP_DIR"/*/; do
    [ -f "$d/SKILL.md" ] && basename "$d"
  done 2>/dev/null
}

require_skill() {
  local root; root="$(source_root)"
  [ -d "$root/$1" ] || die "no $VARIANT skill directory '$1' in $root"
  [ -f "$root/$1/SKILL.md" ] || die "'$1' exists in $root but has no SKILL.md"
}

# Does this symlink point at $root/$skill? Compare resolved physical paths
# when the target exists; fall back to a case/slash-normalized string compare
# for broken links (macOS filesystems are case-insensitive, and hand-made
# links vary in casing and trailing slashes).
points_at_skill() {
  local link="$1" root="$2" skill="$3" target
  target="$(readlink "$link")"
  if [ -e "$link" ]; then
    [ "$link" -ef "$root/$skill" ]  # same inode, regardless of path spelling
  else
    [ "$(printf %s "${target%/}" | tr '[:upper:]' '[:lower:]')" = \
      "$(printf %s "$root/$skill" | tr '[:upper:]' '[:lower:]')" ]
  fi
}

managed_variant_of() {
  local link="$1" skill="$2"
  if points_at_skill "$link" "$REPO" "$skill"; then
    echo frontier
  elif points_at_skill "$link" "$CRISP_DIR" "$skill"; then
    echo crisp
  else
    return 1
  fi
}

# State of <skill> in <agent-dir> for the selected root:
# linked | disabled | broken | frontier | crisp | foreign | absent
state_of() {
  local dir="$1" root="$2" skill="$3"
  local active="$dir/$skill" disabled="$dir/.disabled/$skill"
  local other_variant
  if [ -L "$active" ]; then
    if points_at_skill "$active" "$root" "$skill"; then
      [ -e "$active" ] && echo linked || echo broken
    elif other_variant="$(managed_variant_of "$active" "$skill")"; then
      echo "$other_variant"
    else
      echo foreign
    fi
  elif [ -e "$active" ]; then
    echo foreign
  elif [ -L "$disabled" ]; then
    if points_at_skill "$disabled" "$root" "$skill"; then
      echo disabled
    elif other_variant="$(managed_variant_of "$disabled" "$skill")"; then
      echo "$other_variant"
    else
      echo foreign
    fi
  else
    echo absent
  fi
}

do_link() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  local root; root="$(source_root)"
  mkdir -p "$dir"
  case "$(state_of "$dir" "$root" "$skill")" in
    linked)   echo "$agent: $skill ($VARIANT) already linked" ;;
    disabled) echo "$agent: $skill ($VARIANT) is disabled — use 'enable' to reactivate it" ;;
    frontier|crisp) echo "$agent: SKIPPED — $dir/$skill is linked to the other managed variant (unlink it first)" ;;
    foreign)  echo "$agent: SKIPPED — $dir/$skill exists and is not a linkr symlink (not touching it)" ;;
    broken)   rm "$dir/$skill"; ln -s "$root/$skill" "$dir/$skill"; echo "$agent: relinked $skill ($VARIANT, was broken)" ;;
    absent)   ln -s "$root/$skill" "$dir/$skill"; echo "$agent: linked $skill ($VARIANT)" ;;
  esac
}

do_unlink() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  local root; root="$(source_root)"
  case "$(state_of "$dir" "$root" "$skill")" in
    linked|broken) rm "$dir/$skill"; echo "$agent: unlinked $skill ($VARIANT)" ;;
    disabled)      rm "$dir/.disabled/$skill"; echo "$agent: removed disabled link for $skill ($VARIANT)" ;;
    frontier|crisp) echo "$agent: SKIPPED — $dir/$skill is linked to the other managed variant (rerun with that variant)" ;;
    foreign)       echo "$agent: SKIPPED — $dir/$skill is not a linkr symlink (not touching it)" ;;
    absent)        echo "$agent: $skill ($VARIANT) not linked (nothing to do)" ;;
  esac
}

do_disable() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  local root; root="$(source_root)"
  case "$(state_of "$dir" "$root" "$skill")" in
    linked|broken) mkdir -p "$dir/.disabled"; mv "$dir/$skill" "$dir/.disabled/$skill"; echo "$agent: disabled $skill ($VARIANT)" ;;
    disabled)      echo "$agent: $skill ($VARIANT) already disabled" ;;
    frontier|crisp) echo "$agent: SKIPPED — $dir/$skill is linked to the other managed variant (rerun with that variant)" ;;
    foreign)       echo "$agent: SKIPPED — $dir/$skill is not a linkr symlink (not touching it)" ;;
    absent)        echo "$agent: $skill ($VARIANT) not linked (nothing to disable)" ;;
  esac
}

do_enable() {
  local agent="$1" skill="$2" dir; dir="$(agent_dir "$agent")"
  local root; root="$(source_root)"
  case "$(state_of "$dir" "$root" "$skill")" in
    disabled) mv "$dir/.disabled/$skill" "$dir/$skill"; echo "$agent: enabled $skill ($VARIANT)" ;;
    linked)   echo "$agent: $skill ($VARIANT) already enabled" ;;
    broken)   rm "$dir/$skill"; ln -s "$root/$skill" "$dir/$skill"; echo "$agent: relinked $skill ($VARIANT, was broken)" ;;
    frontier|crisp) echo "$agent: SKIPPED — $dir/$skill is linked to the other managed variant (unlink it first)" ;;
    foreign)  echo "$agent: SKIPPED — $dir/$skill is not a linkr symlink (not touching it)" ;;
    absent)   do_link "$agent" "$skill" ;;  # enabling something never linked just links it
  esac
}

list_variant() {
  local variant="$1" root="$2" skill agent dir state row
  while IFS= read -r skill; do
    row=""
    for agent in "${AGENTS[@]}"; do
      dir="$(agent_dir "$agent")"
      state="$(state_of "$dir" "$root" "$skill")"
      [ "$state" = absent ] && state="-"
      row="$row$(printf ' %-10s' "$state")"
    done
    printf '%-24s %-10s%s\n' "$skill" "$variant" "$row"
  done
}

do_list() {
  printf '%-24s %-10s %-10s %-10s %-10s\n' SKILL VARIANT CLAUDE CODEX PI
  if [ "$VARIANT" = crisp ]; then
    list_variant crisp "$CRISP_DIR" < <(crisp_skills)
  else
    list_variant frontier "$REPO" < <(frontier_skills)
    list_variant crisp "$CRISP_DIR" < <(crisp_skills)
  fi

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
    skill="${2:-}"; [ -n "$skill" ] || die "usage: linkr.sh $cmd <skill> [claude|codex|pi|all] [--crisp]"
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
