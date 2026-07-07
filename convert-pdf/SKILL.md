---
name: convert-pdf
description: "Convert PDF documents to other formats using poppler CLI utilities and Ghostscript. Use this for format conversion: PDF-to-image (PNG, JPEG, TIFF), PDF-to-text, PDF-to-HTML, splitting/merging PDFs, compressing PDFs, and extracting embedded images. Install via `brew install poppler ghostscript`. DO NOT use for reading PDF content (text, tables, metadata) — use the `pdf-extraction` skill (pdfplumber) for that."
---

# Convert PDF

Convert PDF documents to other formats using **poppler** command-line utilities and **Ghostscript** (`gs`).

**Use this skill for:** Converting PDFs to images, text, HTML; splitting/merging PDFs; compressing PDFs; extracting embedded images.

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
| Compress/reduce PDF file size | `gs` | [pdf-compress.md](./pdf-compress.md) |
| View PDF metadata/properties | `pdfinfo` | [pdf-info.md](./pdf-info.md) |
| Extract embedded images from PDF | `pdfimages` | [pdfimages.md](./pdfimages.md) |

## Installation

Poppler and Ghostscript are assumed to be installed. If a command fails with `command not found`, install them:

```bash
brew install poppler ghostscript
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
| `gs` (pdfwrite) | Filename (via `-sOutputFile`) | `compressed.pdf` |
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

### "Compress this PDF" / "Make this PDF smaller"

```bash
# 1. Compress with ebook settings (good balance of quality/size)
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed.pdf input.pdf
ls -lh input.pdf compressed.pdf  # verify: size reduced
```

**PDFSETTINGS presets** (choose based on your needs):

| Setting | Quality | DPI | Use case |
|---|---|---|---|
| `/screen` | Lowest | 72 | Web viewing, smallest file |
| `/ebook` | Low | 150 | General purpose, good balance |
| `/printer` | Medium | 300 | Print-quality output |
| `/prepress` | High | 300 | Professional printing |
| `/press` | Highest | 300 | Press-ready, largest file |

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | `brew install poppler ghostscript` |
| "Cannot open PDF file" | Check path with `ls -la input.pdf`; check file type with `file input.pdf` |
| "Cannot open output file" | Output directory doesn't exist — `mkdir -p output_dir` |
| "PDF permissions error" | PDF is restricted — use `-opw "password"` or `-upw "password"` |
| Empty or missing output | PDF may have 0 pages — check with `pdfinfo input.pdf` |
| Output has unexpected name | Remember: output arg is a **prefix** for pdftoppm/pdfimages/pdftohtml |
| Wrong file extension | Explicitly set format: `-png`, `-jpeg`, or `-tiff` for pdftoppm |
| `gs: command not found` | `brew install ghostscript` |

## Resources

- [Poppler Documentation](https://poppler.freedesktop.org/)
- [Poppler CLI Reference](https://poppler.freedesktop.org/poppler-cli.html)
- [Ghostscript Documentation](https://www.ghostscript.com/doc/)
