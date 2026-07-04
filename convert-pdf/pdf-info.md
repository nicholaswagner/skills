# pdfinfo — PDF Metadata and Properties

> ✅ **Output goes to stdout only. No output file is created.**

## 3 Most Common Commands

```bash
# Basic info (pages, size, creation date, etc.)
pdfinfo input.pdf

# Page count only
pdfinfo input.pdf | grep Pages

# Full info including page dimensions
pdfinfo -box input.pdf
```

## Common Fields

| Field | Description |
|---|---|
| `Pages` | Number of pages |
| `Page size` | Dimensions in points (72 pts = 1 inch) |
| `File size` | Size in bytes |
| `Title` / `Author` | Document metadata |
| `Creator` / `Producer` | Software that created the PDF |
| `Encrypted` | Whether the PDF is password-protected |

## Parsing Output

```bash
# Get page count
pdfinfo input.pdf | awk '/Pages/ {print $2}'

# Get page size
pdfinfo input.pdf | awk '/Page size/ {print $3, $4}'

# Check if encrypted
pdfinfo input.pdf | grep -i encrypted
```

## Verify Output (ALWAYS check after running)

```bash
# Confirm pdfinfo returns data (not an error)
pdfinfo input.pdf | head -5

# Confirm page count is non-zero
pdfinfo input.pdf | grep Pages
```
