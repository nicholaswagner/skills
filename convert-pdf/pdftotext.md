# pdftotext — PDF to Text Extraction

> ✅ **Output IS a filename (not a prefix).**
> `pdftotext input.pdf output.txt` produces exactly `output.txt`.

## 3 Most Common Commands

```bash
# Extract text (linear flow, best for copy-paste)
pdftotext input.pdf output.txt
wc -l output.txt  # verify: non-zero line count

# Extract text preserving layout (columns, tables)
pdftotext -layout input.pdf output.txt
head -20 output.txt  # verify layout

# Output to stdout (no file written)
pdftotext input.pdf - | head -20
```

## Page Range

```bash
# Extract pages 3-7
pdftotext -f 3 -l 7 input.pdf output.txt

# Single page only
pdftotext -f 1 -l 1 input.pdf output.txt
```

## Choosing Output Mode

| Mode | Use when... | Flag |
|---|---|---|
| Linear (default) | Copy-paste, searching, processing | none |
| Layout preserved | Columns, tables, spatial positioning | `-layout` |

## Verify Output (ALWAYS check after running)

```bash
# Check file exists and has content
ls -la output.txt
wc -l output.txt

# Preview first few lines
head -20 output.txt
```
