# Skills

My personal collection of guardrails for models that have never doubted themselves.

I use these primarily with locally hosted models using [Pi](https://pi.dev/), but
they work equally well with [Claude](https://claude.ai) and [Codex](https://chatgpt.com/codex).

## Installing skills

Skills live once in this repo and are made available to an agent by
symlinking them into that agent's skill directory:

| Agent | Skill directory |
| --- | --- |
| [Claude Code](https://claude.ai) | `~/.claude/skills` |
| [Codex](https://chatgpt.com/codex) | `~/.codex/skills` |
| [Pi](https://pi.dev/) | `~/.agents/skills` |

The [`linkr`](./linkr/) skill manages these links (it is also handy as a
plain CLI — symlink `linkr/scripts/linkr.sh` onto your PATH as `linkr`):

```sh
linkr list                  # state of every skill × agent
linkr link tv codex         # make a skill available to one agent
linkr enable yt-dlp         # link a skill for all agents
linkr disable herdr pi      # park a link without losing it
linkr unlink vhs claude     # remove a link
```

Anything added to this repo with a `SKILL.md` is picked up automatically —
no registration needed.

## The skills

| Skill | What it does |
| --- | --- |
| [`analytical-wit`](./analytical-wit/) | An experiment in creating a stable AI voice inspired by the analytical, conversational style of my favorite comedian, [Dara Ó Briain](https://x.com/daraobriain). It combines routing, examples, and drift controls so humor emerges from reasoning instead of being stapled on afterward. |
| [`apple-tv`](./apple-tv/) | Controls Apple TV devices on the local network with [pyatv](https://pyatv.dev/) for pairing, power, app launching, and remote input. |
| [`conventional-commits`](./conventional-commits/) | Inspects Git changes, drafts [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/#specification) messages, and creates commits only when explicitly asked. |
| [`convert-pdf`](./convert-pdf/) | Uses [Poppler](https://poppler.freedesktop.org/) utilities to convert PDFs to text, HTML, or images; extract embedded images; and split or merge documents. |
| [`herdr`](./herdr/) | Controls a running herdr instance (a terminal multiplexer for agents) from inside one of its panes — managing workspaces, tabs, and pane splits, spawning agents, reading pane output, and waiting on state changes over its local unix socket. |
| [`html-to-markdown`](./html-to-markdown/) | Converts files, pasted HTML, and web pages into clean Markdown or other text formats, (removing images by default). [html-to-markdown](https://github.com/xberg-io/html-to-markdown) |
| [`linkr`](./linkr/) | Manages which skills in this repo are available to each agent (Claude Code, Codex, Pi) by creating, removing, and parking symlinks in their skill directories — link, unlink, enable, disable, per agent or globally. |
| [`motion-skills`](./motion-skills/) | A set of focused [Motion](https://motion.dev/docs/react) skills for React and vanilla JS animation: core props, gestures, layout, scroll, hooks, exit animations, vanilla APIs, and performance. |
| [`session-recall`](./session-recall/) | Answers "what did we do earlier / yesterday / last week" questions by querying Claude Code's on-disk session transcripts and prompt history instead of claiming no access to past sessions. |
| [`tv`](./tv/) | Controls a TCL Roku TV over the local network with plain `curl` via Roku's [External Control Protocol](https://developer.roku.com/docs/developer-program/dev-tools/external-control-api.md) — status, key presses, app launching, and text entry. |
| [`vhs`](./vhs/) | Writes and validates [VHS](https://github.com/charmbracelet/vhs) tape files for reproducible terminal GIFs, videos, and screenshots. |
| [`yt-dlp`](./yt-dlp/) | Downloads video, audio, playlists, subtitles, and metadata using task-specific [yt-dlp](https://github.com/yt-dlp/yt-dlp) recipes. |

## License

Licensed under the [GNU General Public License v3.0](./LICENSE).
