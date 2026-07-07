---
name: session-recall
description: "Answer temporal questions about this or past Claude Code sessions — e.g. \"what did we do earlier\", \"what was that command from yesterday\", \"what did we work on last week in project X\", \"what did that subagent do\". Looks up session transcripts under ~/.claude/projects/ and the global ~/.claude/history.jsonl instead of saying it has no access to session history. Use whenever the user asks about prior conversation turns, past sessions, or \"what did we do [time reference]\"."
---

# Session Recall

Claude Code logs every session to disk. This skill is how to actually query
that data instead of saying "I don't have the ability to do that."

## Where the data lives

| Source | What it has | Format |
|---|---|---|
| `~/.claude/projects/{slug}/{sessionId}.jsonl` | Full transcript for one session (one line per event) | ISO-8601 UTC timestamps (`"2026-06-29T17:57:50.551Z"`) |
| `~/.claude/projects/{slug}/{sessionId}/subagents/agent-{taskId}.jsonl` (+`.meta.json`) | Subagent transcripts spawned from that session | same as above |
| `~/.claude/history.jsonl` | Every prompt ever typed, across ALL projects, with literal (non-slugged) `project` path + `sessionId` | unix-ms integer `timestamp` |
| `~/.claude/sessions/{pid}.json` | Currently-running sessions (pid, sessionId, cwd, status) | unix-ms integer fields |

**Never `cat` or fully read a `.jsonl` transcript file.** They get huge fast.
Always filter with `jq`/`grep` first and pull only what's needed.

## Step 1: figure out what the user means by "when"

Disambiguate before picking a data source:

- **"earlier" / "a minute ago" / "just now" / no qualifier / anything about
  *this* conversation** → current session. Go straight to the current
  session's transcript (Step 2). Don't touch `history.jsonl`.
- **"yesterday" / "last week" / "a few sessions ago" / "that other project" /
  "when we worked on X"** (X not obviously this session) → past session(s).
  Start from `~/.claude/history.jsonl` (Step 3).
- **Ambiguous** → check the current session first (it's cheap); if nothing
  matches, fall back to `history.jsonl`. Ask the user only if both come up
  empty.

## Step 2: current session

The running session id is in the environment — no slug computation needed:

```bash
echo "$CLAUDE_CODE_SESSION_ID"
```

Find its transcript file (exactly one match expected):

```bash
find ~/.claude/projects -name "${CLAUDE_CODE_SESSION_ID}.jsonl"
```

If `$CLAUDE_CODE_SESSION_ID` is empty for some reason, fall back to the most
recently modified `.jsonl` in the project dir for the current cwd (see Step 4
for how to find that dir).

Extract just the user turns (skip synthetic `isMeta` messages) to reconstruct
what's been discussed:

```bash
jq -r 'select(.type=="user" and .isMeta!=true) | "\(.timestamp)  \(.message.content | if type=="string" then . else (map(.text // .content // "") | join(" ")) end)"' \
  ~/.claude/projects/*/"${CLAUDE_CODE_SESSION_ID}".jsonl 2>/dev/null | head -50
```

For "what tools did we use" style questions, filter `tool_use` entries
instead:

```bash
jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | "\(.name)"' \
  ~/.claude/projects/*/"${CLAUDE_CODE_SESSION_ID}".jsonl 2>/dev/null | sort | uniq -c
```

For "what did that subagent do", look in
`~/.claude/projects/*/${CLAUDE_CODE_SESSION_ID}/subagents/*.meta.json` for
the `agentType`/`description`, then filter its sibling `.jsonl` the same way.

## Step 3: past sessions (any project, any time)

Start with the global history log — it's small and has everything indexed by
project path and unix-ms timestamp, so filter here before opening any big
transcript:

```bash
# Sessions touching a specific project, most recent first
jq -r 'select(.project=="/Users/you/Repos/whatever") | "\(.timestamp)  \(.sessionId)  \(.display)"' \
  ~/.claude/history.jsonl | tail -50
```

For time-window questions ("yesterday", "last week"), convert unix-ms to a
local date and filter. Get today's local date/timezone from `date`, then
compute the window in ms:

```bash
# example: entries from the last 24h (adjust window as needed)
now_ms=$(($(date +%s) * 1000))
day_ms=$((24*60*60*1000))
jq --argjson since "$((now_ms - day_ms))" \
   'select(.timestamp >= $since)' ~/.claude/history.jsonl
```

Once you've identified candidate `sessionId`s + `project` paths, open just
those transcript files (found via `find ~/.claude/projects -name
"{sessionId}.jsonl"`) and filter with the same `jq` patterns as Step 2 —
never the whole file.

**Timezone note:** transcript-level timestamps are UTC (`Z` suffix);
`history.jsonl` and `date` use local time via unix-ms. When the user says
"yesterday", compute the window in local time, then compare against whichever
timestamp format the source you're querying actually uses — don't mix an ISO
UTC string against a raw local-day cutoff without converting.

## Step 4: project folder slug (fallback only)

If you need to locate a project's directory directly (e.g. user names a
project Claude isn't currently in, and `history.jsonl` didn't have it), the
folder name is derived from the absolute cwd by replacing every `/` and every
`.` with `-`:

```
/Users/x/Repos/dev.foo/skills  →  -Users-x-Repos-dev-foo-skills
```

This is lossy (can't always tell `.` from `/` apart after the fact, and it's
unconfirmed for spaces/other punctuation), so **treat it as a starting guess,
not ground truth**: after finding a candidate dir, verify by checking the
`cwd` field inside one of its `.jsonl` files matches the real path you
expect, don't just trust the slug string.

## Quick reference: answering "what did we do yesterday in this project?"

```bash
proj=$(pwd)
now_ms=$(($(date +%s) * 1000)); day_ms=$((24*60*60*1000))
jq --arg proj "$proj" --argjson since "$((now_ms - day_ms))" \
   'select(.project==$proj and .timestamp>=$since) | "\(.timestamp) \(.sessionId) \(.display)"' \
   ~/.claude/history.jsonl
# then, for each distinct sessionId returned, pull user turns from its transcript:
# jq -r 'select(.type=="user" and .isMeta!=true) | .message.content' \
#   $(find ~/.claude/projects -name "<sessionId>.jsonl")
```
