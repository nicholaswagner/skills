# Analytical Wit Agent

A modular AI voice system that reproduces an **analytical,
conversational reasoning style** inspired by Irish comedian **Dara Ó
Briain**.

The goal is not stand-up comedy, but a tone that feels like:

> a curious rationalist who enjoys following ideas until the logic
> reveals something amusing.

Humor emerges from **reasoning**, not punchlines.

------------------------------------------------------------------------

# Design Philosophy

The system separates the personality into layers so the voice stays
stable across models, long conversations, and prompt changes.

Core principles:

• curiosity over confrontation\
• logic before humor\
• ideas are the target --- never people\
• operational tasks remain clear and neutral

------------------------------------------------------------------------

## Skill Loading

Standard skill loaders discover the package from the `name` and `description`
in `SKILL.md`, then load its body when the task matches. `SKILL.md` routes the
agent to optional voice, reasoning, guardrail, and example files only when they
are relevant. Tests and human documentation are not inference context.

------------------------------------------------------------------------

## Execution Flow

```mermaid
%%{init: {"flowchart": {"useMaxWidth": true, "nodeSpacing": 18, "rankSpacing": 28}} }%%
flowchart TD

start([Skill loaded]) --> router["SKILL.md<br/>(router + core behavior)"]

router --> mode{"Select mode<br/>(docs/VOICE_RUNTIME.md)"}

mode -->|NO| no["Neutral Operator (NO)<br/>Direct / procedural output"]
mode -->|AW| aw["Analytical Wit (AW)<br/>Conversational reasoning voice"]

aw --> boot["Optional BOOT_SEQUENCE.md<br/>(stronger voice calibration)"]
boot --> checklist["docs/VOICE_CHECKLIST.md<br/>(mode/tone/target/structure)"]
checklist --> drift["docs/VOICE_DRIFT_MONITOR.md<br/>(anti-snark + anti-debate)"]

drift --> defs["Voice Definition Layer<br/>CHARACTER_SPEC + STYLE_GUIDE + VOICE_GRAMMAR + RESPONSE_PACING + VOICE_EVOLUTION"]
defs --> toolpick{"Pick ONE tool"}

toolpick --> esc["ESCALATION_PATTERNS.md"]
toolpick --> traps["docs/LOGICAL_TRAP_PATTERNS.md"]
toolpick --> misdir["docs/INTELLECTUAL_MISDIRECTION_LOOP.md"]
toolpick --> comedy["COMEDY_ENGINE.md"]
toolpick --> patterns["docs/RHETORICAL_PATTERNS_LIBRARY.md"]
toolpick --> speech["SPEECH_AND_PATTERNS.md"]

esc --> compose["Compose response<br/>(beats, curiosity → reasoning → implication)"]
traps --> compose
misdir --> compose
comedy --> compose
patterns --> compose
speech --> compose

compose --> anchors["Optional calibration<br/>examples/VOICE_SEED_PROMPTS.md<br/>examples/REASONING_CORPUS.md<br/>examples/VOICE_EDGE_CASES.md"]
anchors --> out([User-visible response])

no --> out

out --> devtests["(Dev) Validate voice<br/>tests/VOICE_TESTS.md<br/>tests/VOICE_REGRESSION_TESTS.md<br/>tests/MODE_SELECTION_TESTS.md"]
```


------------------------------------------------------------------------

## Architecture Overview
See docs/SYSTEM_ARCHITECTURE.md for detailed explanation.

```sh
/   Root
│
├── README.md
│
├── SKILL.md
├── BOOT_SEQUENCE.md
├── COMEDY_ENGINE.md
├── SPEECH_AND_PATTERNS.md
├── ESCALATION_PATTERNS.md
│
├── docs/
│   ├── SYSTEM_ARCHITECTURE.md
│   ├── VOICE_RUNTIME.md
│   ├── VOICE_DRIFT_MONITOR.md
│   ├── VOICE_CHECKLIST.md
│   ├── RESPONSE_PACING.md
│   ├── REASONING_GUARDRAILS.md
│   ├── STYLE_GUIDE.md
│   ├── VOICE_GRAMMAR.md
│   ├── CHARACTER_SPEC.md
│   ├── VOICE_EVOLUTION.md
│   ├── VOICE_TUNING.md
│   ├── RHETORICAL_PATTERNS_LIBRARY.md
│   ├── LOGICAL_TRAP_PATTERNS.md
│   ├── ANTI_PATTERNS.md
│   └── INTELLECTUAL_MISDIRECTION_LOOP.md
│
├── examples/
│   ├── VOICE_SEED_PROMPTS.md
│   ├── REASONING_CORPUS.md
│   ├── LOGIC_PLAYGROUND.md
│   └── VOICE_EDGE_CASES.md
│
└── tests/
    ├── VOICE_TESTS.md
    ├── VOICE_REGRESSION_TESTS.md
    └── MODE_SELECTION_TESTS.md
```
------------------------------------------------------------------------

# Runtime Behavior

SKILL router\
→ VOICE_RUNTIME mode selection (AW vs NO)\
→ optional BOOT_SEQUENCE calibration\
→ VOICE_CHECKLIST\
→ VOICE_DRIFT_MONITOR\
→ voice definition + reasoning tools\
→ response

Modes:

**Analytical Wit (AW)** -- reasoning, explanation, philosophical
questions, playful dialogue.\
**Neutral Operator (NO)** -- technical tasks, instructions, debugging,
sensitive topics.

------------------------------------------------------------------------

# Repository Structure

See `docs/SYSTEM_ARCHITECTURE.md` for the full explanation.

Layers:

• skills → core behavior and reasoning tools\
• docs → personality definition and guardrails\
• examples → seed prompts and calibration data\
• tests → evaluation and regression checks

------------------------------------------------------------------------

# Development and Testing

Key test files:

tests/VOICE_TESTS.md\
tests/VOICE_REGRESSION_TESTS.md\
tests/MODE_SELECTION_TESTS.md

------------------------------------------------------------------------

# Credits

Voice inspiration: **Dara Ó Briain**

# Acknowledgements 

Authored by [Nicholas Wagner](https://www.nicholaswagner.dev)
Heavily processed and developed with ClaudeCode & Codex