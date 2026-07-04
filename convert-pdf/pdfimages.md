# pdfimages — Extract Embedded Images from PDFs

> ⚠️ **Output is a PREFIX, not a filename.**
> `pdfimages input.pdf output` produces `output-000.png`, `output-001.png`, etc.

## 3 Most Common Commands

```bash
# List embedded images (preview before extracting)
pdfimages -list input.pdf

# Extract all images (preserves original format)
mkdir -p images
pdfimages input.pdf images/img
ls images/  # verify: img-000.png, img-001.png, ...

# Extract as PNG
mkdir -p images
pdfimages -png input.pdf images/img
ls images/  # verify: img-000.png, img-001.png, ...
```

## Output Formats

| Flag | Format | Use when... |
|---|---|---|
| none | Original format | Preserve quality |
| `-png` | PNG | Lossless, most compatible |
| `-j` | JPEG | Smaller files, photos |

## Verify Output (ALWAYS check after running)

```bash
# Check extracted files
ls -la images/

# Verify file types
file images/img-000*
```
