# Conversion Recipes

Select one recipe after choosing the input mode, output format, and cleaning
level in `SKILL.md`. Replace placeholders with quoted paths or URLs. Do not add
unrelated flags.

## File to Markdown

Use this for an HTML document or fragment that does not need webpage cleanup:

```bash
html-to-markdown --show-warnings \
  --strip-tags img,picture,source,svg \
  -o "<output.md>" -- "<input.html>"
```

## File to GFM-Friendly Markdown

Use fenced code blocks, ATX headings, and autolinks:

```bash
html-to-markdown \
  --strip-tags img,picture,source,svg \
  --code-block-style backticks \
  --heading-style atx \
  --autolinks \
  --show-warnings \
  -o "<output.md>" -- "<input.html>"
```

Add `--br-in-tables` only when line breaks inside table cells must remain
explicit.

## Clean a Saved Webpage

Start with standard preprocessing:

```bash
html-to-markdown \
  --strip-tags img,picture,source,svg \
  --preprocess \
  --preset standard \
  --code-block-style backticks \
  --heading-style atx \
  --autolinks \
  --show-warnings \
  -o "<output.md>" -- "<page.html>"
```

If navigation, ads, or repeated page chrome remain, retry with
`--preset aggressive`. Compare both outputs. Keep the standard result if the
aggressive result drops article content.

## URL to Markdown

Fetch only the explicit URL:

```bash
html-to-markdown \
  --url "<https://example.com/page>" \
  --strip-tags img,picture,source,svg \
  --preprocess \
  --preset standard \
  --code-block-style backticks \
  --heading-style atx \
  --autolinks \
  --show-warnings \
  -o "<output.md>"
```

The URL fetch does not guarantee that client-rendered content is present. If
the output contains only an application shell, save rendered HTML with an
available browser tool and use the saved-webpage recipe.

## Markdown with Metadata Comment

Use this when the user wants Markdown plus title and meta tags:

```bash
html-to-markdown \
  --strip-tags img,picture,source,svg \
  --extract-metadata \
  --show-warnings \
  -o "<output.md>" -- "<input.html>"
```

## Structured JSON

Use `--json` for structured extraction. Add only fields the user requested:

```bash
html-to-markdown \
  --strip-tags img,picture,source,svg \
  --json \
  --extract-document \
  --extract-headers \
  --extract-links \
  --extract-structured-data \
  --show-warnings \
  -o "<output.json>" -- "<input.html>"
```

Use `--include-structure` only when the semantic document tree is required.
Use `--no-content` only when the user explicitly wants metadata without the
converted text.

Do not add `--extract-images` or `--extract-inline-images` unless the user
explicitly requests image metadata or embedded image data.

## Plain Text or Djot

```bash
html-to-markdown --strip-tags img,picture,source,svg \
  --output-format plain --show-warnings \
  -o "<output.txt>" -- "<input.html>"
```

```bash
html-to-markdown --strip-tags img,picture,source,svg \
  --output-format djot --show-warnings \
  -o "<output.dj>" -- "<input.html>"
```

## Preserve Navigation or Forms

These flags only matter when preprocessing is enabled:

```bash
html-to-markdown \
  --strip-tags img,picture,source,svg \
  --preprocess \
  --preset standard \
  --keep-navigation \
  --keep-forms \
  --show-warnings \
  -o "<output.md>" -- "<input.html>"
```

Include only the preservation flag required by the request.

## Non-UTF-8 Input

Specify a known input encoding rather than guessing repeatedly:

```bash
html-to-markdown --strip-tags img,picture,source,svg \
  --encoding latin-1 --show-warnings \
  -o "<output.md>" -- "<input.html>"
```

## Preserve Images When Explicitly Requested

Remove `--strip-tags img,picture,source,svg` only when the user asks to keep
images. For structured JSON, add `--extract-images` for image element metadata
or `--extract-inline-images` for embedded data URI and SVG image data only when
requested.

## Verification

Run these checks after every file-producing recipe:

```bash
test -s "<output-path>"
wc -c "<output-path>"
sed -n '1,80p' "<output-path>"
grep -nE '!\[|data:image' "<output-path>"
```

For long documents, also inspect sections containing code, tables, links, and
the end of the document. Inspect any image matches; ordinary conversion output
should be image-free unless the user opted in. Confirm that preprocessing did
not remove the main content.
