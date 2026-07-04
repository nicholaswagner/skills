# Small Model Optimizations for convert-pdf

Guidelines for making this skill more reliable when executed by local or smaller models (e.g., qwen3.6-27b).

> ✅ All optimizations below have been applied to the skill files.

## Changes Made

### 1. Lead with Top-3 Patterns, Collapse Rarely-Used Flags

Each sub-doc now starts with **"3 Most Common Commands"** — copy-paste ready, no thinking required. Rarely-used flags are in an **"Advanced Options"** section.

### 2. Add Typical Session Walkthroughs

The main doc now includes end-to-end sessions for the 4 most common tasks:

- Convert PDF to images
- Extract text from PDF
- Split PDF into individual pages
- Merge multiple PDFs

### 3. Strengthen Prefix vs Filename Warning

- Main doc: dedicated **"Output Naming: Prefix vs Filename"** section with a reference table mapping each tool to its output behavior
- Every sub-doc: warning callout at the very top (⚠️ for prefix tools, ✅ for filename tools)

### 4. Add Troubleshooting Decision Tree

Replaced the old "Common Errors" section with a **Problem → Fix** table covering:

- Command not found
- Cannot open PDF
- Cannot open output file
- PDF permissions error
- Empty/missing output
- Unexpected output name
- Wrong file extension

### 5. Flesh Out Thin Sub-docs

- **`pdftohtml.md`**: Rewritten with 3 common commands, output mode table, and verify block
- **`pdf-info.md`**: Rewritten with 3 common commands, field reference table, parsing examples, and verify block

### 6. Add Resolution/DPI Decision Rules

`pdftoppm.md` now has a **"Choosing Resolution"** table mapping goals (screen, print, specific width, thumbnail) to flags.

### 7. Add Format Selection Guidance

`pdftoppm.md` now has a **"Choosing Output Format"** table (PNG/JPEG/TIFF) with when-to-use guidance.

### 8. Add Mandatory Verify Blocks

Every sub-doc ends with a **"Verify Output (ALWAYS check after running)"** section with concrete verification commands.

### 9. Sharpen Boundary with pdf-extraction

Main doc now has a **"DO NOT Use This Skill When"** table explicitly redirecting text reading, table extraction, content searching, and metadata analysis to `pdf-extraction`.

### 10. Convert code snippets to scannable tables

`pdftoppm.md`: Replaced ~80 lines of individual code examples with compact flag tables. Removed redundant "Output Naming" and "Resolution Control" sections. Fixed Best Practices hierarchy.
