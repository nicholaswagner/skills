---
name: convert-pdf
description: "Convert PDF documents to other formats using poppler CLI utilities. Use this for format conversion: PDF-to-image (PNG, JPEG, TIFF), PDF-to-text, PDF-to-HTML, splitting/merging PDFs, and extracting embedded images. Install via `brew install poppler`. DO NOT use for reading PDF content (text, tables, metadata) — use the `pdf-extraction` skill (pdfplumber) for that."
---

# Convert PDF

Convert PDF documents to other formats using **poppler** command-line utilities.

**Use this skill for:** Converting PDFs to images, text, HTML; splitting/merging PDFs; extracting embedded images.

**Use `pdf-extraction` instead for:** Reading PDF content programmatically (text, tables, metadata via pdfplumber).

## DO NOT Use This Skill When

| You need to... | Use instead |
|---|---|
| Read or parse text content from a PDF | `pdf-extraction` |
| Extract tables from a PDF | `pdf-extraction` |
| Search PDF content for keywords | `pdf-extraction` |
| Analyze PDF metadata programmatically | `pdf-extraction` |

**This skill is for format conversion only:** turning PDFs into images, text files, HTML, or splitting/merging PDF files.

## Quick Decision Guide

| User wants... | Tool | See |
|---|---|---|
| Convert PDF to images (PNG, JPEG, TIFF) | `pdftoppm` | [pdftoppm.md](./pdftoppm.md) |
| Extract text from a PDF | `pdftotext` | [pdftotext.md](./pdftotext.md) |
| Convert PDF to HTML | `pdftohtml` | [pdftohtml.md](./pdftohtml.md) |
| Split PDF into individual pages | `pdfseparate` | [pdf-split-merge.md](./pdf-split-merge.md) |
| Merge multiple PDFs into one | `pdfunite` | [pdf-split-merge.md](./pdf-split-merge.md) |
| View PDF metadata/properties | `pdfinfo` | [pdf-info.md](./pdf-info.md) |
| Extract embedded images from PDF | `pdfimages` | [pdfimages.md](./pdfimages.md) |

## Installation

Poppler is assumed to be installed. If a command fails with `command not found`, install it:

```bash
brew install poppler
```

## Output Naming: Prefix vs Filename

This is the most common source of confusion. Read this carefully.

> ⚠️ **For `pdftoppm`, `pdfimages`, and `pdftohtml`: the `output` argument is a PREFIX, not a filename.**
> 
> `pdftoppm -png input.pdf mypage` produces `mypage-1.png`, `mypage-2.png`, etc. — **NOT** `mypage.png`.

> ✅ **For `pdftotext` and `pdfunite`: the `output` argument IS a filename.**

| Tool | Output arg is... | Example output |
|---|---|---|
| `pdftoppm` | Prefix | `mypage-1.png`, `mypage-2.png` |
| `pdfimages` | Prefix | `mypage-000.png`, `mypage-001.png` |
| `pdftohtml` | Prefix | `mypage.html`, `mypage-1.html` |
| `pdftotext` | Filename | `output.txt` |
| `pdfunite` | Filename | `combined.pdf` |
| `pdfseparate` | Pattern | `page-%d.pdf` → `page-1.pdf`, `page-2.pdf` |
| `pdfinfo` | None (stdout only) | — |

## Typical Sessions

### "Convert this PDF to images"

```bash
# 1. Convert all pages to PNG at 150 DPI
mkdir -p report_pages
pdftoppm -png -r 150 report.pdf report_pages/page
ls report_pages/  # verify: page-1.png, page-2.png, ...
```

### "Extract text from this PDF"

```bash
# 1. Extract text (linear flow, no layout)
pdftotext report.pdf report.txt
wc -l report.txt  # verify: non-zero line count
```

### "Split this PDF into individual pages"

```bash
# 1. Split into separate PDFs
mkdir -p split_pages
pdfseparate report.pdf split_pages/page-%d.pdf
ls split_pages/  # verify: page-1.pdf, page-2.pdf, ...
```

### "Merge these PDFs"

```bash
# 1. Merge files in order
pdfunite part1.pdf part2.pdf part3.pdf combined.pdf
pdfinfo combined.pdf  # verify: page count matches
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | `brew install poppler` |
| "Cannot open PDF file" | Check path with `ls -la input.pdf`; check file type with `file input.pdf` |
| "Cannot open output file" | Output directory doesn't exist — `mkdir -p output_dir` |
| "PDF permissions error" | PDF is restricted — use `-opw "password"` or `-upw "password"` |
| Empty or missing output | PDF may have 0 pages — check with `pdfinfo input.pdf` |
| Output has unexpected name | Remember: output arg is a **prefix** for pdftoppm/pdfimages/pdftohtml |
| Wrong file extension | Explicitly set format: `-png`, `-jpeg`, or `-tiff` for pdftoppm |

## Resources

- [Poppler Documentation](https://poppler.freedesktop.org/)
- [Poppler CLI Reference](https://poppler.freedesktop.org/poppler-cli.html)
