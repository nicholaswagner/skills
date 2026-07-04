# pdftohtml — PDF to HTML Conversion

> ⚠️ **Output is a PREFIX, not a filename.**
> `pdftohtml input.pdf output` produces `output.html` plus supporting files (images, CSS).

## 3 Most Common Commands

```bash
# Convert to HTML with embedded images (single self-contained file)
pdftohtml -embed input.pdf output
ls output.html  # verify

# Convert to one HTML file per page
mkdir -p output
pdftohtml -s input.pdf output
ls output/  # verify: output-1.html, output-2.html, ...

# Convert to HTML with separate image files
mkdir -p output
pdftohtml -i output input
ls output/  # verify: output.html, output/images/, output.css
```

## Output Modes

| Mode | Flag | Output | Use when... |
|---|---|---|---|
| Default | none | `output.html` + images | Quick conversion |
| Embedded images | `-embed` | `output.html` (self-contained) | Single file to share |
| Split per page | `-s` | `output-1.html`, `output-2.html` | Page-by-page viewing |
| Separate files | `-i dir` | `output.html` + `dir/images/` + CSS | Full fidelity |

## Verify Output (ALWAYS check after running)

```bash
# Check generated files
ls -la output*

# Preview HTML
head -20 output.html
```
