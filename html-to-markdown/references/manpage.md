# html-to-markdown(1)

| html-to-markdown(1) | General Commands Manual | html-to-markdown(1) |
| ------------------- | ----------------------- | ------------------- |

## NAME

html-to-markdown - Command-line interface for html-to-markdown -
high-performance HTML to Markdown converter

## SYNOPSIS

**html-to-markdown** [**--url**] [**--user-agent**]
 [**-o**|**--output**] [**--generate-completion**]
 [**--generate-man**] [**--heading-style**] [**--list-indent-type**]
 [**--list-indent-width**] [**-b**|**--bullets**]
 [**--strong-em-symbol**] [**--escape-asterisks**]
 [**--escape-underscores**] [**--escape-misc**] [**--escape-ascii**]
 [**--sub-symbol**] [**--sup-symbol**] [**--newline-style**]
 [**--code-block-style**] [**-l**|**--code-language**]
 [**-a**|**--autolinks**] [**--link-style**]
 [**--default-title**] [**--keep-inline-images-in**]
 [**--br-in-tables**] [**--highlight-style**]
 [**--extract-metadata**] [**--json**] [**--include-structure**]
 [**--extract-inline-images**] [**--show-warnings**]
 [**--no-content**] [**--extract-document**] [**--extract-headers**]
 [**--extract-links**] [**--extract-images**]
 [**--extract-structured-data**] [**--whitespace-mode**]
 [**--strip-newlines**] [**-w**|**--wrap**] [**--wrap-width**]
 [**--convert-as-inline**] [**--strip-tags**]
 [**-p**|**--preprocess**] [**--preset**] [**--keep-navigation**]
 [**--keep-forms**] [**-e**|**--encoding**] [**--debug**]
 [**-f**|**--output-format**] [**-h**|**--help**]
 [**-V**|**--version**] [*FILE*]

## DESCRIPTION

Command-line interface for html-to-markdown - high-performance HTML to
Markdown converter

## OPTIONS

**--url** *\<URL\>*
Fetch HTML from a URL (alternative to file/stdin)

**--user-agent** *\<UA\>*
User-Agent header when fetching via --url (default mimics a real browser)

**-o**, **--output** *\<FILE\>*
Output file (default: stdout)

**--generate-completion** *\<SHELL\>*
Generate shell completion script

*Possible values:*

- bash
- zsh
- fish
- power-shell
- elvish

**--generate-man**
Generate man page

**-h**, **--help**
Print help (see a summary with '-h')

**-V**, **--version**
Print version

[*FILE*]
Input HTML file (use "-" or omit for stdin)

## HEADING OPTIONS

**--heading-style** *\<STYLE\>*
Heading style

Controls how headings are formatted in the output: - 'atx': # for h1, ## for
h2, etc. (default, `CommonMark`) - 'underlined': h1 uses ===, h2 uses --- -
'atx-closed': # Title # with closing hashes

*Possible values:*

- atx: ATX style: # for h1, ## for h2 (default)
- underlined: Underlined: === for h1, --- for h2
- atx-closed: ATX closed: # Title #

## LIST OPTIONS

**--list-indent-type** *\<TYPE\>*
List indentation type

*Possible values:*

- spaces: Use spaces for indentation
- tabs: Use tabs for indentation

**--list-indent-width** *\<N\>*
Spaces per list indent level

Default is 2 (`CommonMark` standard). Use 4 for wider indentation.

**-b**, **--bullets** *\<CHARS\>*
Bullet characters for unordered lists

Characters cycle through nesting levels. Default "-" uses hyphen consistently.
"*+-" uses "*" for level 1, "+" for level 2, "-" for level 3.

## TEXT FORMATTING

**--strong-em-symbol** *\<CHAR\>*
Symbol for bold and italic

Choose '*' (default) or '_' for **bold** and *italic* text

**--escape-asterisks**
Escape asterisk (*) characters

**--escape-underscores**
Escape underscore (_) characters

**--escape-misc**
Escape misc Markdown characters

Escape characters like [, ], <, >, #, etc.

**--escape-ascii**
Escape all ASCII punctuation

For strict `CommonMark` spec compliance (usually not needed)

**--sub-symbol** *\<SYMBOL\>*
Symbol to wrap subscript text

Example: "~" wraps \<sub>text\</sub> as ~text~

**--sup-symbol** *\<SYMBOL\>*
Symbol to wrap superscript text

Example: "^" wraps \<sup>text\</sup> as ^text^

**--newline-style** *\<STYLE\>*
Line break style

How to represent \<br\> tags: - 'backslash': Backslash at end of line (default,
`CommonMark`) - 'spaces': Two spaces at end of line

*Possible values:*

- spaces: Two spaces at end of line
- backslash: Backslash at end of line (default)

## CODE BLOCKS

**--code-block-style** *\<STYLE\>*
Code block style

How to format code blocks: - 'indented': 4-space indentation (default,
`CommonMark`) - 'backticks': Fenced with backticks (\`\`\`) - 'tildes':
Fenced with tildes (~~~)

*Possible values:*

- indented: Indented code blocks: 4 spaces (default)
- backticks: Fenced code blocks: \`\`\`
- tildes: Fenced code blocks: ~~~

**-l**, **--code-language** *\<LANG\>*
Default language for code blocks

Sets the language for fenced code blocks when not specified in HTML

## LINKS

**-a**, **--autolinks**
Convert URLs to autolinks

When link text equals href, use \<url\> instead of [url](url)

**--link-style** *\<STYLE\>*
Link rendering style

Controls how links are formatted: - 'inline': `[text](url)` (default) -
'reference': `[text][1]` with definitions at end

*Possible values:*

- inline: Inline links: `[text](url)` (default)
- reference: Reference-style links: `[text][1]` with definitions at end

**--default-title**
Add default title to links

Use href as link title when no title attribute exists

## IMAGES

**--keep-inline-images-in** *\<ELEMENTS\>*
Keep inline images in specific elements

Comma-separated list of HTML elements where images should remain as markdown
(not converted to alt text). Example: "a,strong"

## TABLES

**--br-in-tables**
Use \<br\> in table cells

Preserve line breaks in table cells using \<br\> tags instead of converting to
spaces

## HIGHLIGHTING

**--highlight-style** *\<STYLE\>*
Style for \<mark\> elements

How to represent highlighted text: - 'double-equal': ==text== (default) -
'html': \<mark\>text\</mark\> - 'bold': **text** - 'none': plain text

*Possible values:*

- double-equal: ==text== (default)
- html: \<mark\>text\</mark\>
- bold: **text**
- none: Plain text

## METADATA

**--extract-metadata**
Extract metadata from HTML

Extract title and meta tags as HTML comment header

**--extract-document**
Extract document-level metadata

Requires --with-metadata or --json. Extracts title, description, charset,
language, etc.

**--extract-headers**
Extract header elements

Requires --with-metadata or --json. Extracts h1-h6 headers with hierarchy.

**--extract-links**
Extract link elements

Requires --with-metadata or --json. Extracts anchor tags with types (internal,
external, etc.).

**--extract-images**
Extract image elements (metadata)

Requires --with-metadata or --json. Extracts img tags with sources and
metadata.

**--extract-structured-data**
Extract structured data

Requires --with-metadata or --json. Extracts JSON-LD, Microdata, and `RDFa`
blocks.

## JSON OUTPUT

**--json**
Output full ConversionResult as JSON instead of markdown text

Serializes all result fields (content, metadata, tables, document tree,
warnings) as a JSON object. Use with --include-structure,
--extract-inline-images, --no-content to control which fields are populated.

**--include-structure**
Include structured document tree in output

Requires --json. Populates the "document" field with a semantic node tree.

**--extract-inline-images**
Extract inline images from data URIs and SVGs

Requires --json. Populates the "images" field with extracted inline image data.

**--show-warnings**
Print processing warnings to stderr

Emits each non-fatal warning to stderr in the format:
"Warning [\<kind\>]: \<message\>"

**--no-content**
Skip text content generation, only extract metadata and structure

Requires --json. Sets output_format to plain text extraction mode; the
"content" field in the JSON output will be empty.

## WHITESPACE

**--whitespace-mode** *\<MODE\>*
Whitespace handling mode

How to handle whitespace in HTML: - 'normalized': Clean up excess whitespace
(default) - 'strict': Preserve whitespace as-is

*Possible values:*

- normalized: Normalize whitespace (default)
- strict: Preserve whitespace as-is

**--strip-newlines**
Strip newlines from input

Remove all newlines from HTML before processing (useful for minified HTML)

## WRAPPING

**-w**, **--wrap**
Enable text wrapping

Wrap output lines at --wrap-width columns

**--wrap-width** *\<N\>*
Wrap width in columns

Column width for text wrapping when --wrap is enabled

## ELEMENT HANDLING

**--convert-as-inline**
Treat block elements as inline

Convert block-level elements without adding paragraph breaks

**--strip-tags** *\<TAGS\>*
HTML tags to strip

Comma-separated list of HTML tags to strip (output only text content, no
markdown conversion). Example: "script,style"

## PREPROCESSING

**-p**, **--preprocess**
Enable HTML preprocessing

Clean up HTML before conversion (removes navigation, ads, forms, etc.)

**--preset** *\<LEVEL\>*
Preprocessing aggressiveness preset

How aggressively to clean HTML: - 'minimal': Basic cleanup only - 'standard':
Balanced cleaning (default) - 'aggressive': Maximum cleaning for web scraping

*Possible values:*

- minimal: Basic cleanup
- standard: Balanced cleaning (default)
- aggressive: Maximum cleaning

**--keep-navigation**
Keep navigation elements

Don't remove \<nav\>, menus, etc. during preprocessing

**--keep-forms**
Keep form elements

Don't remove \<form\>, \<input\>, etc. during preprocessing

## PARSING

**-e**, **--encoding** *\<ENCODING\>* [default: utf-8]
Input character encoding

Encoding to use when reading input files (e.g., 'utf-8', 'latin-1')

## DEBUGGING

**--debug**
Enable debug mode

Output diagnostic warnings and information

## OUTPUT FORMAT

**-f**, **--output-format** *\<FORMAT\>*
Output format (markdown or djot)

Choose the output format: - 'markdown': Standard Markdown (CommonMark
compatible, default) - 'djot': Djot lightweight markup language

*Possible values:*

- markdown: Standard Markdown (CommonMark compatible)
- djot: Djot lightweight markup language
- plain: Plain text (no markup)

## EXTRA

### EXAMPLES

#### Basic conversion from stdin

```bash
echo '\<h1>Title\</h1>\<p\>Content\</p\>' | html-to-markdown
```

#### Convert file to stdout

```bash
html-to-markdown input.html
```

#### Convert and save to file

```bash
html-to-markdown input.html -o output.md
```

#### Generate shell completions

```bash
html-to-markdown --generate-completion bash > html-to-markdown.bash
html-to-markdown --generate-completion zsh > _html-to-markdown
```

#### Generate man page

```bash
html-to-markdown --generate-man > html-to-markdown.1
```

#### Web scraping with preprocessing

```bash
html-to-markdown page.html --preprocess --preset aggressive
```

#### Fetch remote HTML and convert

```bash
html-to-markdown --url <https://example.com> > output.md
```

#### Discord/Slack-friendly (2-space indents)

```bash
html-to-markdown input.html --list-indent-width 2
```

#### Custom heading and list styles

```bash
html-to-markdown input.html \
--heading-style atx \
--bullets '*' \
--list-indent-width 2
```

For more information: <https://github.com/kreuzberg-dev/html-to-markdown>

## VERSION

v3.2.2

| html-to-markdown 3.2.2 |     |
| ---------------------- | --- |
