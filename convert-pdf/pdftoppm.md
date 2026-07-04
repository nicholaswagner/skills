# pdftoppm — PDF to Image Conversion

> ⚠️ **Output is a PREFIX, not a filename.**
> `pdftoppm -png input.pdf mypage` produces `mypage-1.png`, `mypage-2.png`, etc. — NOT `mypage.png`.

## 3 Most Common Commands

```bash
# Convert all pages to PNG (default choice for most use cases)
mkdir -p output
pdftoppm -png input.pdf output/page
ls output/  # verify: page-1.png, page-2.png, ...

# Convert to JPEG for photo-heavy PDFs
mkdir -p output
pdftoppm -jpeg -jpegopt quality=85 input.pdf output/page
ls output/  # verify: page-1.jpg, page-2.jpg, ...

# Extract first page as a cover image
pdftoppm -png -f 1 -l 1 -scale-to 800 -singlefile input.pdf cover
file cover.png  # verify output
```

## Choosing Output Format

| Format | Use when... | Notes |
|---|---|---|
| **PNG** (default) | Text-heavy pages, need lossless quality | Default choice |
| **JPEG** | Photo-heavy pages, smaller file sizes | Use `-jpegopt quality=85` |
| **TIFF** | Archival, printing workflows | Use `-tiffcompression deflate` |

## Choosing Resolution

| Goal | Flag | Example |
|---|---|---|
| Screen viewing | `-r 150` | `pdftoppm -png -r 150 input.pdf output/page` |
| Printing quality | `-r 300` | `pdftoppm -png -r 300 input.pdf output/page` |
| Specific pixel width | `-scale-to <width>` | `pdftoppm -png -scale-to 1920 input.pdf output/page` |
| Thumbnail | `-scale-to 100` | `pdftoppm -png -scale-to 100 input.pdf output/thumb` |

> Use `-scale-to` instead of `-r` when you need predictable pixel dimensions.

## Advanced Options

### Page Range

| Flag | Use when... |
|---|---|
| `-f 5 -l 10` | Convert pages 5 through 10 |
| `-f 1 -l 1` | Convert only the first page |
| `-o` | Convert only odd pages |
| `-e` | Convert only even pages |
| `-singlefile` | Single page output (no page number suffix) |

### Image Quality

| Flag | Use when... |
|---|---|
| `-jpegopt quality=90,progressive=n,optimize=y` | JPEG with quality and optimization |
| `-gray` | Grayscale output (PGM format) |
| `-mono` | Monochrome output (PBM format) |

### TIFF Compression

| Flag | Use when... |
|---|---|
| `-tiffcompression lzw` | LZW compression |
| `-tiffcompression jpeg` | JPEG compression |
| `-tiffcompression deflate` | Deflate compression |
| `-tiffcompression none` | Uncompressed |

### Other Flags

| Flag | Use when... |
|---|---|
| `-cropbox` | Use crop box instead of media box |
| `-hide-annotations` | Remove comments and highlights |
| `-x 100 -y 100 -W 500 -H 700` | Crop to specific region |
| `-upw "password"` | User password-protected PDF |
| `-opw "password"` | Owner password-protected PDF |
| `-progress` | Track progress on large PDFs |
| `-q` | Suppress messages |
| `-sep _` | Custom page number separator |

## Verify Output (ALWAYS check after running)

```bash
# Check files were created and have content
ls -la output/

# Verify file type
file output/page-1.png

# Check dimensions
sips -g pixelWidth -g pixelHeight output/page-1.png 2>/dev/null
```

## Best Practices

1. **Choose format wisely**: PNG for text-heavy pages, JPEG for photo-heavy pages
2. **Use `-scale-to` instead of `-r` when target pixel size matters**: More predictable output dimensions
3. **Use `-progress` for large PDFs**: Track conversion progress
4. **Use `-cropbox` for PDFs with content outside margins**: Removes unwanted whitespace
5. **Use `-hide-annotations` for clean screenshots**: Removes comments and highlights
