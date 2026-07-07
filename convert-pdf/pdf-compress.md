# PDF Compression with Ghostscript

Compress PDFs to reduce file size using Ghostscript's `gs` command with the `pdfwrite` device.

## Basic Usage

```bash
gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=output.pdf \
   input.pdf
```

## Flags Explained

| Flag | Purpose |
|---|---|
| `-sDEVICE=pdfwrite` | Output a PDF (not a printer device) |
| `-dCompatibilityLevel=1.4` | PDF 1.4 (Acrobat 5) — widely compatible |
| `-dPDFSETTINGS=/ebook` | Quality preset (see table below) |
| `-dNOPAUSE` | Don't pause between pages |
| `-dQUIET` | Suppress non-error output |
| `-dBATCH` | Exit after processing |
| `-sOutputFile=...` | **Filename** (not a prefix) |

## PDFSETTINGS Presets

| Setting | Quality | Target DPI | Typical Reduction |
|---|---|---|---|
| `/screen` | Lowest | 72 dpi | Maximum compression |
| `/ebook` | Low | 150 dpi | Good balance of size/quality |
| `/printer` | Medium | 300 dpi | Print-quality |
| `/prepress` | High | 300 dpi | Professional printing |
| `/press` | Highest | 300 dpi | Press-ready |

**Recommendation:** Start with `/ebook` for general use. Use `/screen` only for web-only PDFs where quality doesn't matter.

## Typical Session

```bash
# Check original size
ls -lh input.pdf          # e.g., 15M

# Compress
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed.pdf input.pdf

# Verify size reduction
ls -lh input.pdf compressed.pdf   # e.g., 15M → 3M

# Verify page count is preserved
pdfinfo compressed.pdf
```

## Advanced: Custom Compression

For finer control, set individual parameters instead of presets:

```bash
gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/printer \
   -dColorImageDownsampleType=/Bicubic \
   -dColorImageResolution=150 \
   -dGrayImageDownsampleType=/Bicubic \
   -dGrayImageResolution=150 \
   -dMonoImageDownsampleType=/Bicubic \
   -dMonoImageResolution=150 \
   -dAutoRotatePages=/None \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=output.pdf \
   input.pdf
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `gs: command not found` | `brew install ghostscript` |
| Output is blank/empty | PDF may have transparency issues — try `-dAutoFilterColorImages=false` |
| Fonts look different | Ghostscript may substitute fonts — try `-dPreserveEPSInfo=true -dPreserveAnnots=true` |
| Form fields lost | Add `-dPDFSETTINGS=/prepress` to preserve more features |
| Output larger than input | PDF is already compressed — try a lower preset like `/screen` |
