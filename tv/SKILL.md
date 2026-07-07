---
name: tv
description: Control the TCL Roku TV in the living room over the local network via Roku's External Control Protocol (ECP). Use when the user asks to check, launch an app on, power, navigate, or send remote-control input to "the TV" or "the Roku".
---

# TV control (TCL Roku TV)

Controls the living room TCL•Roku TV over the local network using Roku's
[External Control Protocol (ECP)](https://developer.roku.com/docs/developer-program/dev-tools/external-control-api.md),
a plain HTTP API the TV exposes on port 8060. No auth, no SDK — just `curl`.

## Device configuration

The TV's address is **not** stored in this skill. It comes from an environment
variable, set in the local shell environment (`~/.zshenv.local`, sourced by
zshenv):

- `ROKU_TV_HOST` — the TV's LAN IP (DHCP; re-discover if unreachable, see below)

Device: TCL 55S405 (Roku TV, 55"), living room.

This was originally found by ARP-sweeping the LAN to populate the ARP table,
then probing every host on port 8060 with
`curl http://<ip>:8060/query/device-info` until one replied with Roku's
device-info XML. No mDNS/SSDP discovery was needed — ECP just answered directly
once the right IP was hit.

## Re-discovering the TV if the IP changes

If `$ROKU_TV_HOST` stops responding (or is unset), re-scan the subnet for the
ECP port:

```bash
subnet=$(ipconfig getifaddr en0 | cut -d. -f1-3)
for i in $(seq 1 254); do
  (r=$(curl -s -m 1 "http://${subnet}.${i}:8060/query/device-info" 2>/dev/null); \
   [ -n "$r" ] && echo "=== ${subnet}.${i} ===" && echo "$r" | grep -E "friendly-device-name|vendor-name") &
done; wait
```

Look for `<vendor-name>TCL</vendor-name>`. Update `ROKU_TV_HOST` in
`~/.zshenv.local` once found.

## Checking status

```bash
curl -s "http://${ROKU_TV_HOST}:8060/query/device-info"
```

Useful fields: `<power-mode>` (`PowerOn` / `PowerOff` / standby states),
`<uptime>`, `<software-version>`.

List installed apps/channels:

```bash
curl -s "http://${ROKU_TV_HOST}:8060/query/apps"
```

## Sending remote-control key presses

ECP keypress endpoint: `POST /keypress/<key>`

```bash
curl -s -X POST "http://${ROKU_TV_HOST}:8060/keypress/<KEY>"
```

Common `<KEY>` values:

| Key | Action |
|---|---|
| `Home` | Go to home screen |
| `Back` | Back |
| `Select` | OK/Select |
| `Up`, `Down`, `Left`, `Right` | D-pad navigation |
| `Play` | Play/Pause |
| `Rev`, `Fwd` | Rewind / Fast-forward |
| `InstantReplay` | Instant replay |
| `Info` | Info/options (`*` button) |
| `VolumeUp`, `VolumeDown`, `VolumeMute` | Volume |
| `PowerOff`, `PowerOn` | Power (may not work on all models over Wi-Fi-only standby) |
| `ChannelUp`, `ChannelDown` | Broadcast tuner channel (this TV has an ATSC tuner) |

Example — mute the TV:

```bash
curl -s -X POST "http://${ROKU_TV_HOST}:8060/keypress/VolumeMute"
```

## Launching an app/channel

First find the app's ID via `/query/apps`, then:

```bash
curl -s -X POST "http://${ROKU_TV_HOST}:8060/launch/<APP_ID>"
```

## Typing text (e.g. search box)

ECP also supports literal character keypresses for text entry, URL-encoded:

```bash
curl -s -X POST "http://${ROKU_TV_HOST}:8060/keypress/Lit_h"
```

(Each character is sent individually as `Lit_<char>`; prefer using on-screen
keyboard navigation for anything beyond trivial input.)

## Notes

- No authentication is required for ECP by default (`<ecp-setting-mode>permissive</ecp-setting-mode>` on this TV) — anyone on the LAN can control it. Don't expose port 8060 outside the local network.
- This is unofficial-but-standard Roku tooling — ECP is documented and stable across Roku OS versions.
