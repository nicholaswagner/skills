---
name: vhs
description: Write terminal GIFs as code. This skill is used to create, record, and run `.tape` files to generate high-quality GIFs, MP4s, or PNG screenshots of terminal sessions for integration testing, demos, and social media. Includes a deterministic, step-by-step recipe for converting an arbitrary shell one-liner into a ready-to-render `.tape` file — written so it can be followed mechanically without trial-and-error iteration.
---

# 📼 vhs Skill

**Trigger Phrases:** `"vhs help"`, `"how to use vhs"`, `"vhs commands"`, `"create a vhs tape"`, `"record terminal session"`, `"vhs usage"`, `"vhs syntax"`, `"vhs record"`, `"vhs publish"`, `"make a gif of this command"`, `"screenshot this command"`.

---

## 🚀 Quick Start

1.  **Create a new tape:** `vhs new demo.tape`
2.  **Edit the tape:** Use your preferred editor (e.g., `vim demo.tape`).
3.  **Check it before rendering:** `vhs validate demo.tape` (syntax only, no ttyd/ffmpeg needed).
4.  **Run the tape:** `vhs demo.tape` (Generates `demo.gif` by default).
5.  **Record an action:** `vhs record > session.tape` (Then `exit` the terminal to stop).

---

## 🛠 Prerequisites

VHS requires the following tools to be installed and available in your `$PATH`:
- `ttyd`
- `ffmpeg`

**Installation (macOS/Linux):** `brew install vhs`

**Check before generating anything:** `command -v vhs ttyd ffmpeg`. `vhs validate` works without `ttyd`/`ffmpeg` (it only parses), but actually rendering (`vhs <tape>.tape`) needs both.

---

## 🧩 Recipe: turn a shell command into a `.tape`

Use this when given a bash one-liner and asked to produce a GIF or screenshot of it. Follow the steps in order — don't skip the verification step.

1. **Find where it goes.** Look for an existing `scripts/`, `tapes/`, or `vhs/` directory with `.tape` files already in it.
   - If found, put the new file there and copy `Set` values (FontFamily/FontSize/Width/Height/WindowBar/Theme) from an existing tape of similar purpose in that directory — match the project's convention rather than inventing new values.
   - If not found, default to `scripts/<name>.tape` at the project root. Name it for what it demonstrates, or `sample.tape` if no better name is given.

2. **Make the command runnable in a bare, non-interactive shell.** The tape runs the command in a fresh shell that has **not** loaded the user's interactive setup — no `.bashrc`/`.zshrc` aliases, no functions, no activated virtualenv, no `direnv`. A command that works when *you* paste it in a terminal can fail here with `command not found`.
   - If the program lives in a project virtualenv, do not call it bare. Prefix it with the project's runner: `uv run <cmd>`, `poetry run <cmd>`, `npx <cmd>`, or `./node_modules/.bin/<cmd>`. In a `uv` project, **every** binary in the pipeline needs `uv run` — including both sides of a `|` pipe (e.g. `uv run gen ... | uv run render ...`).
   - When unsure, test the exact command first: `bash -lc '<command>'` from the project root. If that prints `command not found`, the tape will too — fix the invocation before writing the tape.

3. **Prepare the `Type` string — there are TWO independent quoting layers. Get both right.**
   - **Layer A — the shell:** once typed, the characters must form a valid command for the shell. Quotes that the command needs (e.g. JSON passed to `echo`, like `echo '{"a":1}'`) must still be there. If you drop them, bash strips characters and the program receives garbage. Keep the command exactly as it must appear at a real prompt.
   - **Layer B — the VHS `Type` delimiter:** VHS does **not** process backslash escapes inside `Type` strings — it reads literally until the next occurrence of the delimiter character, full stop. So pick a delimiter that does **not** appear in the (already shell-correct) command:
     - Check whether the command contains `"`, `'`, and `` ` ``.
     - Use the first of `"`, `'`, `` ` `` (in that order) that does **not** appear anywhere in the command.
     - If the command contains all three characters, split it across consecutive `Type` lines — VHS just concatenates keystrokes — switching delimiter for the segment that needs it.
   - **Worked quoting case:** the command `echo '{"values":[[1,2,3]]}' | uv run heatgraph` contains both `'` and `"`. The `'` is required by the shell (Layer A), so the only safe VHS delimiter (Layer B) is the backtick: `` Type `echo '{"values":[[1,2,3]]}' | uv run heatgraph` ``. Using `Type '...'` here would end the string early at the first `'`; dropping the `'` would feed bash invalid JSON.

4. **Write the skeleton in this fixed order.** `Output`, `Require`, and `Set` lines are only honored before the first interaction command — anything that isn't `Output`/`Require`/`Set` (e.g. the first `Type`, `Sleep`, key press) ends the window. `Set TypingSpeed` is the one exception and can be changed again later.
   ```
   Output <path>.gif        # omit entirely if only a Screenshot is wanted — Output is not mandatory
   Require <binary>         # one line per external program the command needs
   Set Width <px>
   Set Height <px>
   Set FontSize <px>
   # ...other Set lines

   Type "<the command>"
   Sleep 500ms
   Enter
   Sleep <Ns>                # let the command finish before capturing
   Screenshot <path>.png     # only if a still image was asked for
   Sleep 1s                  # REQUIRED after Screenshot — see step 8
   ```
   Two non-obvious rules baked into this skeleton:
   - **For a still image, use `Screenshot`, never `Output <path>.png`.** A `.png` given to `Output` is treated as a *frame-sequence directory* — VHS dumps hundreds of `frame-text-*.png` / `frame-cursor-*.png` files into a directory at that path. `Output` is only for `.gif` / `.mp4` / `.webm` / `.ascii`.
   - **Always follow `Screenshot` with a `Sleep` (≥ one frame).** `Screenshot` only *flags* the next recorded frame for capture; it does not block. If the tape ends immediately after, teardown cancels recording before the next frame tick fires and **the PNG is silently never written** (exit 0, no error, no file). A trailing `Sleep 1s` guarantees a frame is captured. Without it, capture is a coin-flip.

5. **Size the canvas for the content, not a guess.** Default to `Set Width 1200` / `Set Height 600` for ordinary commands. If the command's output is wide or tabular (grids, tables, long lines), start wider — 1600–2400px — then render once and look at it. A wrapped or clipped line is a `Width` problem; widen and re-render.

6. **Pick a `Sleep` after `Enter`.** ~1s for instant commands; 2–4s for anything invoking `uv run`, `npm`, `docker`, or a network call. Prefer `Wait /pattern/` over a guessed `Sleep` when a stable string in the output can be matched (default regex `/>$/`, default timeout `15s`, default scope `Line`).

7. **Never place a bare `Escape`, `Ctrl+<key>`, or other control keypress immediately before a `Type`.** The shell's readline can interpret `Escape` immediately followed by a letter as a Meta-key combo — e.g. `Escape` then `u` is read as `Alt+u` ("upcase word"), which silently swallows that character out of the typed text instead of inserting it (a real tape in the wild had `Type "uv run ..."` render as `v run ...` plus `bash: v: command not found` for exactly this reason). If the terminal needs a moment, use `Sleep`, not a stray keypress.

8. **Verify before calling it done — this is the step that actually matters:**
   ```
   vhs validate <tape>     # syntax only — catches typos, NOT a bad render
   vhs <tape>               # actually renders
   ```
   Then open the resulting PNG/GIF and confirm: the full command is visible and intact, it executed without an in-frame error (no `command not found`, traceback, JSON/parse error, etc.), and no line wrapped or got clipped by the canvas. `vhs validate` passing is not evidence the image looks right — only looking at the image is. **Also confirm the output file actually exists** — a `Screenshot` with no trailing `Sleep` exits 0 but writes nothing (see step 4).

### Worked example

Command:
```
uv run heatgraph-helpers mock-data --cols 80 --rows 7 --seed 12 --sparsity 0.5 --vmax 5 | uv run heatgraph --message '[COUNT] / [CELLS]' --legend 'less  [GRADIENT]  more' --no-row-labels --no-col-labels --normalize quantile --glyphs squarespace --no-invert-headers --theme rose-pine
```

- Delimiter: the command contains `'` but no `"` or `` ` `` → wrap the whole thing in `Type "..."`.
- This renders an 80-column heatmap grid (~280 visible characters wide) — too wide for a default 1200px canvas at a 13px font, so the canvas was widened and verified by rendering before settling on these numbers.

```
Output scripts/sample.gif

Require uv

Set Shell "bash"
Set FontFamily "Dank Mono"
Set FontSize 13
Set Width 1450
Set Height 380
Set WindowBar Colorful
Set BorderRadius 10
Set Theme "rose-pine"

Type "uv run heatgraph-helpers mock-data --cols 80 --rows 7 --seed 12 --sparsity 0.5 --vmax 5 | uv run heatgraph --message '[COUNT] / [CELLS]' --legend 'less  [GRADIENT]  more' --no-row-labels --no-col-labels --normalize quantile --glyphs squarespace --no-invert-headers --theme rose-pine"
Sleep 500ms
Enter
Sleep 3s

Screenshot scripts/sample.png
Sleep 1s
```

---

## 📜 Command Line Interface (CLI)

| Command | Description |
| :--- | :--- |
| `vhs new <name>.tape` | Creates a new template `.tape` file. |
| `vhs validate <tape>...` | Parses tape file(s) and reports syntax errors without rendering (no ttyd/ffmpeg required). |
| `vhs <tape>.tape` | Executes the tape and renders the animation. |
| `vhs record > <name>.tape` | Records your current terminal session into a tape file. |
| `vhs publish <file>.gif` | Uploads your GIF to `vhs.charm.sh` for easy sharing. |
| `vhs serve` | Starts an SSH server for remote session interaction. |
| `vhs themes` | Lists built-in theme names. |
| `vhs manual` | Opens the full CLI documentation. |

---

## ⌨️ Tape File Commands (`.tape`)

Tape files consist of a sequence of instructions. Most key-press commands can optionally include a `@<time>` argument to slow them down, and a trailing count to repeat them.

### 1. Setup & Output
- `Output <path>`: Specify output format (`.gif`, `.mp4`, `.webm`) or directory for PNG sequence. Optional if you only need `Screenshot` stills — VHS does not require an `Output` line to run.
- `Require <program>`: Declare required dependencies (e.g., `Require gum`).
- `Set <Setting> <Value>`: Configure the virtual terminal environment.

**Ordering rule:** `Output`, `Require`, and `Set` lines are only honored above the first interaction command (`Type`, any key press, `Sleep`, `Wait`, `Hide`...). Anything of that kind below the first interaction line is silently ignored — except `Set TypingSpeed`, which can be changed again later inline.

**Available Settings:**
- **Shell:** `Set Shell <shell>` (e.g. `Set Shell "fish"`)
- **Dimensions:** `Set Width <px>`, `Set Height <px>`, `Set Padding <px>`, `Set Margin <px>`, `Set MarginFill <hex>`
- **Appearance:** `Set FontSize <px>`, `Set FontFamily "<font>"`, `Set Theme <json|name>` (see `vhs themes` or THEMES.md for built-in names), `Set BorderRadius <px>`, `Set WindowBar <Rings|RingsRight|Colorful|ColorfulRight>`, `Set WindowBarSize <px>`
- **Animation:** `Set Framerate <fps>`, `Set PlaybackSpeed <multiplier>`, `Set LoopOffset <time|percent>`, `Set CursorBlink <bool>`
- **Line Style:** `Set LetterSpacing <px>`, `Set LineHeight <px>`
- **Typing:** `Set TypingSpeed <time>` — only setting that may also be set again after interaction commands begin.

### 2. Terminal Interaction
- `Type "<string>"`: Emulates typing. Use `@<time>` to slow down (e.g., `Type@500ms "text"`).
  - **Quoting:** the string can be delimited with `"`, `'`, or `` ` ``. There is no backslash-escaping inside any of them — the lexer reads literally until it hits the delimiter character again. Pick whichever of `"` / `'` / `` ` `` does not appear in the text you're typing (see the Recipe above for the full algorithm).
- `Key [@<time>] [count]`: Emulates key presses.
    - **Special Keys:** `Enter`, `Tab`, `Space`, `Backspace`, `Delete`, `Insert`, `Escape`, `Ctrl[+Alt][+Shift]+<key>`
    - **Navigation:** `Up`, `Down`, `Left`, `Right`, `PageUp`, `PageDown`
    - **Viewport:** `ScrollUp [@<time>] [count]`, `ScrollDown [@<time>] [count]`
  - Avoid sending `Escape` or other control keys immediately before a `Type` — see Recipe step 7 for why that can eat the first character(s) of the typed text.
- `Env <Key> Value`: Sets an environment variable for the session.
- `Source <tape>`: Executes another `.tape` file within the current session.

### 3. Control & Wait
- `Sleep <time>`: Pauses the recording for a duration (e.g., `Sleep 2s`).
- `Wait[+Screen|+Line] [@<time>] [/regex/]`: Pauses until a pattern appears on screen (whole screen or just the last line). Defaults: regex `/>$/`, timeout `15s`, scope `Line`.
- `Hide`: Stops capturing frames (used to hide setup/cleanup commands).
- `Show`: Resumes capturing frames.

### 4. Multimedia
- `Screenshot <path>.png`: Captures the current terminal frame as a single PNG. **Always follow it with a `Sleep`** (see Pitfalls) and **never** use `Output` for a `.png` — `Output <path>.png` produces a directory of frame images, not a still.
- `Copy "string"`: Copies text to the system clipboard.
- `Paste`: Pastes the current clipboard content into the terminal.

---

## ⚠️ Pitfalls

- **`vhs validate` only checks syntax.** It will pass on a tape that renders garbage (wrong width, failed command, swallowed keystrokes). The only real verification is rendering and looking at the output.
- **The tape's shell is bare and non-interactive.** No aliases, functions, activated venv, or `direnv` from the user's normal terminal. A bare `mytool ...` that works for the user becomes `command not found` here — prefix venv/project binaries with their runner (`uv run`, `poetry run`, `npx`), on **every** stage of a pipe. Test with `bash -lc '<command>'` first.
- **Two quoting layers, not one.** The typed text must be valid for the *shell* (keep quotes the command needs, e.g. `echo '{"a":1}'`) AND the `Type` line needs a VHS delimiter (`"`, `'`, or `` ` ``) that doesn't appear in that text. When the command already contains both `'` and `"`, the `Type` delimiter must be the backtick.
- **No escaping inside `Type` strings.** Choose a delimiter (`"`, `'`, `` ` ``) absent from the text instead of trying to escape the one you picked.
- **`Output`/`Require`/`Set` after the first interaction line are ignored**, not deferred — put all of them at the top.
- **A stray `Escape`/`Ctrl` keypress right before `Type` can be merged into a Meta-key combo** by the shell's readline, dropping a character from what gets typed. Use `Sleep` instead.
- **Wide or tabular command output needs a wide canvas.** A grid/table that's visually fine in your normal terminal can silently wrap or clip in a narrow VHS frame — size `Width` for the content and verify by rendering.
- **`Screenshot` with no trailing `Sleep` silently writes nothing.** It flags the *next* recorded frame; if the tape ends first, recording is torn down before that frame exists and you get exit 0 with no file (and no error). Put a `Sleep 1s` after every `Screenshot`. If a PNG intermittently appears or not, this is almost always the cause — it is a race, not a dimension or content issue.
- **`Output <path>.png` is not a screenshot.** It writes a directory full of `frame-*.png` files. Use the `Screenshot` command for a single still; reserve `Output` for `.gif`/`.mp4`/`.webm`/`.ascii`.
