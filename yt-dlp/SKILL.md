---
name: yt-dlp
description: Download video, audio, playlists, subtitles, and metadata with yt-dlp. Use for requests to save media from YouTube, Twitch, Vimeo, SoundCloud, Twitter/X, Reddit, TikTok, and other yt-dlp-supported sites.
---

# yt-dlp

Use `yt-dlp` to download media. Select the smallest recipe that satisfies the
request. Replace every angle-bracket placeholder before running a command.

## Safety and execution rules

- Quote URLs, paths, and output templates.
- Never pass secrets directly on the command line. Prefer browser cookies or a
  cookie file for authenticated downloads.
- Do not download an entire playlist when the user asks for one video. Use
  `--no-playlist` for a single-video request.
- Do not guess a format ID. Run `yt-dlp -F "<URL>"` first.
- State when a recipe requires `ffmpeg`.
- If the request needs behavior not shown below, read
  [references/recipes.md](references/recipes.md). Load only the relevant
  section.

## Recipe index

| User wants | Use |
| --- | --- |
| One video in the default best format | Download one video |
| An MP4 video | Download one video as MP4 |
| Audio as MP3 | Download audio as MP3 |
| An entire playlist | Download a playlist |
| Files saved in a chosen directory | Choose the output directory |
| Advanced requests | Read `references/recipes.md` |

## Core recipes

### Download one video

Use for a single video in yt-dlp's default best format.

```bash
yt-dlp --no-playlist "<URL>"
```

### Download one video as MP4

Use the built-in MP4 preset. Merging separate video and audio streams may
require `ffmpeg`.

```bash
yt-dlp --no-playlist -t mp4 "<URL>"
```

### Download audio as MP3

Requires `ffmpeg`.

```bash
yt-dlp --no-playlist -t mp3 "<URL>"
```

### Download a playlist

Use only when the user explicitly requests the complete playlist.

```bash
yt-dlp "<PLAYLIST_URL>"
```

### Choose the output directory

Keep yt-dlp's default filename and save it beneath the requested directory.

```bash
yt-dlp -P "<OUTPUT_DIR>" --no-playlist "<URL>"
```

## Completion checks

After a download:

1. Check the process exit status.
2. Report the resulting file path or paths.
3. Report skipped or failed playlist items without claiming complete success.
