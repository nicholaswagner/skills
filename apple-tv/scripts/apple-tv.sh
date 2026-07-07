#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  apple-tv.sh [--name NAME | --id ID] [--host IP] <command> [args...]

Commands:
  scan                         Discover Apple TV and AirPlay devices
  wizard | setup | pair         Run pyatv's pairing wizard
  on | turn-on | wake           Turn on / wake the selected Apple TV
  off | turn-off                Turn off the selected Apple TV
  state | power-state           Print power state
  home | menu | up | down       Send remote input
  left | right | select
  play | pause | play-pause
  app                           Print current app
  app-list | apps               List installed apps
  launch-app BUNDLE_ID          Launch an app, e.g. com.netflix.Netflix
  raw <atvremote args...>       Pass commands directly to atvremote

Target selection:
  --name NAME                   Apple TV name, or APPLE_TV_NAME
  --id ID                       Apple TV identifier, or APPLE_TV_ID
  --host IP                     Optional scan host, or APPLE_TV_HOST

Examples:
  apple-tv.sh scan
  apple-tv.sh wizard
  apple-tv.sh --name "Living Room" on
  apple-tv.sh --name "Living Room" launch-app com.netflix.Netflix
USAGE
}

die() {
  printf 'apple-tv: %s\n' "$*" >&2
  exit 1
}

require_atvremote() {
  if ! command -v atvremote >/dev/null 2>&1; then
    cat >&2 <<'EOF'
apple-tv: atvremote was not found.

Install pyatv first:
  pipx install pyatv --python /opt/homebrew/bin/python3.13
EOF
    exit 127
  fi
}

name=${APPLE_TV_NAME:-}
id=${APPLE_TV_ID:-}
host=${APPLE_TV_HOST:-}

while (($#)); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -n|--name)
      (($# >= 2)) || die "--name requires a value"
      name=$2
      shift 2
      ;;
    -i|--id)
      (($# >= 2)) || die "--id requires a value"
      id=$2
      shift 2
      ;;
    --host)
      (($# >= 2)) || die "--host requires a value"
      host=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      break
      ;;
  esac
done

(($# >= 1)) || {
  usage >&2
  exit 2
}

command_name=$1
shift

require_atvremote

base_args=()
if [[ -n $host ]]; then
  base_args+=(--scan-hosts "$host")
fi

target_args=("${base_args[@]}")
if [[ -n $name && -n $id ]]; then
  die "use either --name or --id, not both"
elif [[ -n $name ]]; then
  target_args+=(-n "$name")
elif [[ -n $id ]]; then
  target_args+=(-i "$id")
fi

require_target() {
  if [[ -z $name && -z $id ]]; then
    die "no Apple TV target specified; run scan/wizard, then pass --name or --id"
  fi
}

case "$command_name" in
  scan)
    atvremote "${base_args[@]}" scan
    ;;
  wizard|setup|pair)
    atvremote "${base_args[@]}" wizard
    ;;
  on|turn-on|wake)
    require_target
    atvremote "${target_args[@]}" turn_on
    ;;
  off|turn-off)
    require_target
    atvremote "${target_args[@]}" turn_off
    ;;
  state|power-state)
    require_target
    atvremote "${target_args[@]}" power_state
    ;;
  home|menu|up|down|left|right|select|play|pause)
    require_target
    atvremote "${target_args[@]}" "$command_name"
    ;;
  play-pause)
    require_target
    atvremote "${target_args[@]}" play_pause
    ;;
  app)
    require_target
    atvremote "${target_args[@]}" app
    ;;
  app-list|apps)
    require_target
    atvremote "${target_args[@]}" app_list
    ;;
  launch-app)
    require_target
    (($# >= 1)) || die "launch-app requires an app bundle id"
    atvremote "${target_args[@]}" "launch_app=$1"
    ;;
  raw)
    require_target
    (($# >= 1)) || die "raw requires atvremote arguments"
    atvremote "${target_args[@]}" "$@"
    ;;
  *)
    die "unknown command: $command_name"
    ;;
esac
