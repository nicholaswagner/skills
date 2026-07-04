# Additional yt-dlp recipes

Read only the section needed for the current request. Replace all
angle-bracket placeholders before running a command. Quote URLs and paths.

## Recipe index

| Need | Section |
| --- | --- |
| Inspect or select formats | Formats |
| Select playlist entries | Playlist selection |
| Download or embed subtitles | Subtitles |
| Embed thumbnails or metadata | Embedded media and metadata |
| Download part of a video | Time ranges |
| Access logged-in or restricted media | Authentication |
| Avoid duplicate downloads | Download archive |
| Inspect without downloading | Inspection and simulation |
| Limit bandwidth | Rate limiting |
| Remove SponsorBlock segments | SponsorBlock |
| Customize filenames | Output templates |

## Formats

List available formats before selecting an ID:

```bash
yt-dlp -F "<URL>"
```

Download the selected video and audio format IDs:

```bash
yt-dlp -f "<VIDEO_ID>+<AUDIO_ID>" "<URL>"
```

Prefer format sorting when the user specifies constraints such as resolution:

```bash
yt-dlp -S "res:1080,fps,codec:h264" "<URL>"
```

## Playlist selection

Download playlist items 1 through 3 and item 7:

```bash
yt-dlp -I "1:3,7" "<PLAYLIST_URL>"
```

List playlist entries without downloading them:

```bash
yt-dlp --flat-playlist "<PLAYLIST_URL>"
```

## Subtitles

List available subtitles before choosing a language:

```bash
yt-dlp --list-subs "<URL>"
```

Download English subtitles without downloading the video:

```bash
yt-dlp --skip-download --write-subs --write-auto-subs --sub-langs "en.*" "<URL>"
```

Embed English subtitles in the downloaded video. Requires `ffmpeg`:

```bash
yt-dlp --embed-subs --sub-langs "en.*" "<URL>"
```

## Embedded media and metadata

Embed the thumbnail, metadata, and chapters. Requires `ffmpeg` and may require
additional post-processing dependencies for some output formats.

```bash
yt-dlp --embed-thumbnail --embed-metadata "<URL>"
```

## Time ranges

Download from 1:30 through 3:00. Requires `ffmpeg`.

```bash
yt-dlp --download-sections "*1:30-3:00" "<URL>"
```

## Authentication

Prefer cookies from the user's browser for logged-in, private, or
age-restricted media:

```bash
yt-dlp --cookies-from-browser "<BROWSER>" "<URL>"
```

Common browser values include `chrome`, `firefox`, and `safari`. Ask which
browser profile to use when more than one is plausible. A cookie file is an
alternative:

```bash
yt-dlp --cookies "<COOKIES_FILE>" "<URL>"
```

## Download archive

Skip media IDs already recorded in an archive file:

```bash
yt-dlp --download-archive "<ARCHIVE_FILE>" "<URL>"
```

## Inspection and simulation

Simulate the request without downloading:

```bash
yt-dlp --simulate "<URL>"
```

Print one JSON metadata object:

```bash
yt-dlp --dump-single-json "<URL>"
```

## Rate limiting

Limit the download rate to 2 MiB per second:

```bash
yt-dlp --limit-rate 2M "<URL>"
```

## SponsorBlock

Remove sponsor, intro, and outro segments. Post-processing requires `ffmpeg`:

```bash
yt-dlp --sponsorblock-remove "sponsor,intro,outro" "<URL>"
```

## Output templates

Choose a directory and filename template:

```bash
yt-dlp -P "<OUTPUT_DIR>" -o "%(title)s [%(id)s].%(ext)s" "<URL>"
```

Common fields include `%(title)s`, `%(id)s`, `%(ext)s`, `%(uploader)s`,
`%(upload_date)s`, `%(playlist_title)s`, and `%(playlist_index)s`.
