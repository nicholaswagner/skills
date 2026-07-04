# Skills

My personal collection of guardrails for models that have never doubted
themselves.

I use these primarily with locally hosted models using [Pi](https://pi.dev/), but they work equally well with [Claude](https://claude.ai) and [Codex](https://chatgpt.com/codex).

Each skill is self-contained in its own directory and begins with a `SKILL.md`.

## The skills

| Skill | What it does |
| --- | --- |
| [`analytical-wit`](./analytical-wit/) | An experiment in creating a stable AI voice inspired by the analytical, conversational style of my favorite comedian, [Dara Ó Briain](https://x.com/daraobriain). It combines routing, examples, and drift controls so humor emerges from reasoning instead of being stapled on afterward. |
| [`conventional-commits`](./conventional-commits/) | Inspects Git changes, drafts [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/#specification) messages, and creates commits only when explicitly asked. |
| [`convert-pdf`](./convert-pdf/) | Uses [Poppler](https://poppler.freedesktop.org/) utilities to convert PDFs to text, HTML, or images; extract embedded images; and split or merge documents. |
| [`html-to-markdown`](./html-to-markdown/) | Converts files, pasted HTML, and web pages into clean Markdown or other text formats, (removing images by default). [html-to-markdown](https://github.com/xberg-io/html-to-markdown) |
| [`vhs`](./vhs/) | Writes and validates [VHS](https://github.com/charmbracelet/vhs) tape files for reproducible terminal GIFs, videos, and screenshots. |
| [`yt-dlp`](./yt-dlp/) | Downloads video, audio, playlists, subtitles, and metadata using task-specific [yt-dlp](https://github.com/yt-dlp/yt-dlp) recipes. |

## License

Licensed under the [GNU General Public License v3.0](./LICENSE).
