# pdfseparate / pdfunite — Split and Merge PDFs

> ⚠️ **`pdfseparate` output is a PATTERN (uses `%d` placeholder).**
> ✅ **`pdfunite` output IS a filename.**

## 3 Most Common Commands

### Split PDF into Individual Pages

```bash
mkdir -p split
pdfseparate input.pdf split/page-%d.pdf
ls split/  # verify: page-1.pdf, page-2.pdf, ...
```

### Merge Multiple PDFs

```bash
pdfunite file1.pdf file2.pdf file3.pdf combined.pdf
pdfinfo combined.pdf  # verify: page count matches
```

### Extract a Page Range

```bash
pdfseparate -f 5 -l 10 input.pdf pages-%d.pdf
ls pages-*.pdf  # verify: pages-5.pdf through pages-10.pdf
```

## Verify Output (ALWAYS check after running)

```bash
# Check split files
ls -la page-*.pdf

# Check page count matches
ls page-*.pdf | wc -l

# Verify merged file
pdfinfo combined.pdf
```
