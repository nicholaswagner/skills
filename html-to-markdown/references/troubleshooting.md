# Troubleshooting

Diagnose from the observed failure. Change one condition at a time.

## Command Is Missing

Run:

```bash
command -v html-to-markdown
```

If it is missing, report that result. Do not install without permission. The
official macOS Homebrew command is:

```bash
brew install xberg-io/tap/html-to-markdown
```

The cross-platform Cargo command is:

```bash
cargo install html-to-markdown-cli
```

## Input File Cannot Be Opened

Confirm the exact quoted path:

```bash
test -f "<input.html>"
wc -c "<input.html>"
```

Do not substitute a similarly named file without asking.

## Output File Already Exists

Do not overwrite it by default. Choose a distinct output name or ask the user
whether replacement is intended.

## Output Is Empty or Nearly Empty

1. Confirm the input is non-empty.
2. Inspect the input and verify that it contains HTML content.
3. Retry with `--show-warnings --debug`.
4. If the input is a URL, determine whether it returned an application shell,
   access-denied page, login page, or error page.

Do not report successful conversion merely because the command exited with
status zero.

## Saved Webpage Contains Too Much Chrome

Retry once with:

```text
--preprocess --preset standard
```

If chrome remains, retry with `aggressive` and compare outputs. Keep the less
aggressive result when the stronger preset removes meaningful content.

## Main Content Is Missing

Reduce preprocessing in this order:

1. `aggressive` to `standard`
2. `standard` to `minimal`
3. Remove preprocessing

If navigation or form content was intentionally requested, add
`--keep-navigation` or `--keep-forms` with preprocessing enabled.

## URL Output Contains Only an Application Shell

The page likely depends on client-side rendering. Use an available browser tool
to load the page, save or capture the rendered HTML, and convert that file. Do
not crawl additional links unless the user asks.

## Code Blocks Are Hard to Read

Use:

```text
--code-block-style backticks
```

Add `--code-language "<language>"` only when one default language is correct for
all otherwise-unlabeled code blocks.

## Table Cell Line Breaks Disappear

Retry with `--br-in-tables`. Inspect the rendered Markdown because raw table
syntax can still look dense.

## Images or Embedded Image Data Remain

Confirm that the command includes:

```text
--strip-tags img,picture,source,svg
```

Inspect matches with:

```bash
grep -nE '!\[|data:image' "<output-path>"
```

No matches is the expected default. A match can still be legitimate text when
the source document is explaining Markdown image syntax, so inspect before
removing textual content.

## Text Uses the Wrong Encoding

Use `--encoding` only when the source encoding is known. Common values include
`utf-8` and `latin-1`. Do not cycle through encodings without evidence.

## Structured Fields Are Missing

Use `--json` with the specific extraction flag. For example,
`--extract-document`, `--extract-headers`, and `--extract-links` require JSON
output in the bundled 3.2.2 CLI. Do not use the undocumented
`--with-metadata` spelling mentioned in parts of the generated manual.

Image extraction is intentionally disabled by default. Add `--extract-images`
or `--extract-inline-images` only when the user explicitly requests it.

## Bounded Recovery

After two materially different attempts fail:

1. Stop retrying.
2. Report the exact commands and exit status.
3. Include warnings or the relevant error text.
4. State what was verified and what remains uncertain.
