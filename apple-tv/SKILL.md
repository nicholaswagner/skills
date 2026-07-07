---
name: apple-tv
description: Control the Apple TV on the local network with pyatv/atvremote. Use when the user asks to discover, pair, turn on, turn off, wake, check power state, navigate, launch apps on, or send remote-control input to "the Apple TV".
---

# Apple TV control

Controls Apple TV devices on the local network with
[`pyatv`](https://pyatv.dev/) and its `atvremote` CLI.

## Device configuration

Device-specific values (name, IP, identifier) are **not** stored in this skill.
They come from environment variables, set in the local shell environment
(`~/.zshenv.local`, sourced by zshenv):

- `APPLE_TV_NAME` — device name as shown by `scan`
- `APPLE_TV_HOST` — device IP (DHCP; re-scan if unreachable)
- `APPLE_TV_ID` — optional device identifier (alternative to name)

The helper script reads these automatically, so no `--name`/`--host` flags are
needed once they are set. If they are unset, run `scan` to discover the device
and either export the variables or pass `--name`/`--host` explicitly.

Pairing is needed for AirPlay, Companion, and RAOP. pyatv stores pairing
credentials in its own local storage, not in this skill.

## Dependency

`atvremote` must be installed and on `PATH`.

```bash
pipx install pyatv --python /opt/homebrew/bin/python3.13
```

Python 3.14 caused a pyatv 0.18.0 CLI event-loop error here. Prefer Python
3.13 or 3.12 for now. If pyatv was installed with Python 3.14, reinstall:

```bash
pipx reinstall pyatv --python /opt/homebrew/bin/python3.13
```

The helper script checks for `atvremote` and prints a basic install command if
missing.

## Helper

Use the wrapper in this skill:

```bash
apple-tv/scripts/apple-tv.sh <command> [options]
```

Common commands:

```bash
apple-tv/scripts/apple-tv.sh scan
apple-tv/scripts/apple-tv.sh wizard
apple-tv/scripts/apple-tv.sh on          # target comes from APPLE_TV_NAME / APPLE_TV_HOST
apple-tv/scripts/apple-tv.sh state
apple-tv/scripts/apple-tv.sh off
apple-tv/scripts/apple-tv.sh home
apple-tv/scripts/apple-tv.sh launch-app com.netflix.Netflix
```

Target options (flags override the env vars):

- `--name NAME` or `APPLE_TV_NAME`
- `--id ID` or `APPLE_TV_ID`
- `--host IP` or `APPLE_TV_HOST` for faster unicast scanning/commands

`scan` and `wizard` do not need a target.

## Pairing

Run:

```bash
apple-tv/scripts/apple-tv.sh wizard
```

Choose the Apple TV from the list. Pair all protocols the wizard asks for. If
the Apple TV shows a PIN, stop and ask the user to read or enter the PIN. pyatv
saves credentials to its normal local storage, so future commands should not
need manual credentials.

Do not write pairing credentials into this skill or commit them to the repo.

Manual fallback:

```bash
apple-tv/scripts/apple-tv.sh scan
atvremote --id <identifier> --protocol companion pair
atvremote --id <identifier> --protocol airplay pair
atvremote --id <identifier> --protocol raop pair
```

Ignore disabled protocols.

## Power

After pairing:

```bash
apple-tv/scripts/apple-tv.sh on
apple-tv/scripts/apple-tv.sh state
apple-tv/scripts/apple-tv.sh off
```

If `turn_on` fails while the Apple TV is in deep sleep, make sure
`APPLE_TV_HOST` is set (or pass `--host <ip>`) so the command uses unicast. Wake behavior depends on the Apple TV
model, sleep state, and network.

## Remote input

The wrapper supports common remote keys:

```bash
apple-tv/scripts/apple-tv.sh up
apple-tv/scripts/apple-tv.sh down
apple-tv/scripts/apple-tv.sh left
apple-tv/scripts/apple-tv.sh right
apple-tv/scripts/apple-tv.sh select
apple-tv/scripts/apple-tv.sh menu
apple-tv/scripts/apple-tv.sh play-pause
```

For anything not wrapped, pass raw `atvremote` commands:

```bash
apple-tv/scripts/apple-tv.sh raw commands
apple-tv/scripts/apple-tv.sh raw app
```
