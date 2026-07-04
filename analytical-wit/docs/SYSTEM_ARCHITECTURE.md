
# SYSTEM_ARCHITECTURE.md
## Voice System Architecture — dara-analytical-wit

This document explains how the files in this repository work together to
produce a stable “Analytical Wit” persona (Dara Ó Briain–inspired
conversational reasoning voice).

The goal is to make the voice:

- consistent across long conversations
- resistant to drift across models
- pleasant during reasoning
- unobtrusive during operational tasks (code/tools/procedures)

---

# High-Level Flow

At runtime, the system should behave like this:

SKILL (entrypoint + router + core behavior)  
→ MODE SELECTION (runtime controller)  
→ OPTIONAL VOICE CALIBRATION (boot + style references)  
→ OPTIONAL DRIFT CHECK  
→ RESPONSE COMPOSITION (voice definition + tools + pacing)  
→ OPTIONAL VALIDATION (tests / regression)

---

# Components and Responsibilities

## 1) Initialization

### `BOOT_SEQUENCE.md`
Purpose:
- provides stronger voice calibration when the task needs it
- sets the default “thinking aloud” posture
- includes a small set of Voice Anchors to lock cadence

Output:
- a consistent starting tone before any user content arrives

---

## 2) Core Skill Router

### `SKILL.md`
Purpose:
- defines core behavior, reasoning loop, and rhetorical intent
- references all supporting documents
- acts as the “table of contents” for the voice system
- serves as the standard skill entrypoint

Key sections should include:
- Voice Anchors (brief)
- Overview + Core Voice
- Thinking Loop
- Runtime Voice Control (points to `docs/VOICE_RUNTIME.md`)
- Drift Prevention (points to `docs/VOICE_DRIFT_MONITOR.md`)
- Skill Package Components (links the rest of the repo)

Loader note:
- loaders discover the skill from standard `name` and `description` metadata
- the `SKILL.md` body explicitly routes optional references on demand
- tests and human documentation are not inference context

---

## 3) Mode Selection

### `docs/VOICE_RUNTIME.md`
Purpose:
- chooses **Analytical Wit (AW)** vs **Neutral Operator (NO)** based on task

Rules of thumb:
- AW for explanation, reasoning, brainstorming, creative dialogue
- NO for code, tools, procedures, sensitive topics, “just the answer”

Output:
- prevents the agent from “performing the character” during operational work

---

## 4) Drift Prevention

### `docs/VOICE_DRIFT_MONITOR.md`
Purpose:
- internal pre-response self-check when AW is active
- detects and repairs common drift modes:
  - snark / sarcasm toward user
  - debate mode
  - overconfidence
  - forced jokes
  - overly academic lecturing

Output:
- ensures the voice stays kind, idea-focused, and useful

---

## 5) Voice Definition Layer

These files define what the voice *is* and how it should sound:

### `docs/CHARACTER_SPEC.md`
- worldview, personality traits, conversational goals
- strengths and intentional “human” weaknesses

### `docs/STYLE_GUIDE.md`
- preferred phrasing, tonal constraints, do/don’t language patterns

### `docs/VOICE_GRAMMAR.md`
- linguistic fingerprints (sentence length, punctuation habits, cadence)

### `docs/RESPONSE_PACING.md`
- beat-based pacing (thinking in beats, not paragraphs)
- length targets by context

### `docs/VOICE_EVOLUTION.md`
- how tone adapts over time as familiarity increases
- sensitivity adjustments by topic

---

## 6) Reasoning + Humor Tooling Layer

These files provide reusable reasoning mechanisms:

### `COMEDY_ENGINE.md`
- procedural generator for analytical humor
- converts a claim into a reasoning chain with a gentle implication

### `SPEECH_AND_PATTERNS.md`
- rhetorical patterns and cadence notes (structures, templates)

### `docs/INTELLECTUAL_MISDIRECTION_LOOP.md`
- layered logic that produces “two laughs” (or two realizations)

### `ESCALATION_PATTERNS.md`
- three-step escalation (claim → extension → implication)

Output:
- makes wit emerge from logic reliably (especially on smaller local models)

---

## 7) Anchoring + Practice Data Layer

These files stabilize the voice with examples and exercises:

### `examples/VOICE_SEED_PROMPTS.md`
- few-shot priming exchanges
- fastest way to lock voice on small models

### `examples/REASONING_CORPUS.md`
- short anchor snippets demonstrating the style

### `examples/LOGIC_PLAYGROUND.md`
- prompts that encourage the model to practice analytical reasoning

Output:
- reduces “generic assistant” drift
- improves cadence mimicry

---

## 8) Safety and Guardrails

### `docs/ANTI_PATTERNS.md`
- what the voice must never do (insults, hostile sarcasm, etc.)

### `docs/REASONING_GUARDRAILS.md`
- tone protections while reasoning (curiosity over judgment, no debate mode)

Output:
- preserves the “friendly skeptic” feel and avoids punching down

---

## 9) Validation and Testing

### `tests/VOICE_TESTS.md`
- manual prompts + expected behavioral outcomes
- drift detection and quick evaluation

(Recommended next)
- `tests/VOICE_REGRESSION_TESTS.md`
  - deterministic test suite you can run after changes

Output:
- confidence that changes didn’t break the voice

---

# Typical Execution Sequence

A typical interaction should follow this decision path:

1. Boot: apply `BOOT_SEQUENCE.md`
2. Read user prompt
3. Select mode using `VOICE_RUNTIME.md` (AW vs NO)
4. If AW:
   - run `VOICE_DRIFT_MONITOR.md` self-check
   - apply voice definition (spec/style/grammar/pacing)
   - choose 1 reasoning tool (escalation OR misdirection OR comedy engine)
   - respond in beats
5. If NO:
   - produce direct answer with steps/checklists
6. Optionally validate with `VOICE_TESTS.md` during development

---

# How to Extend This System Safely

When adding new docs/tools, keep roles clear:

- docs/ = policies + definitions + constraints
- root files = core behavior + reusable reasoning tools
- examples/ = few-shot anchors + practice data
- tests/ = evaluation prompts and regression suites

Recommended extension pattern:

1. Add new file
2. Reference it from `SKILL.md`
3. Add 1–2 test prompts in `tests/`
4. Add 1–2 anchors/examples in `examples/` if needed

---

# Summary Diagram

BOOT_SEQUENCE  
  ↓  
SKILL (router)  
  ↓  
VOICE_RUNTIME (AW vs NO)  
  ↓  
(If AW) VOICE_DRIFT_MONITOR  
  ↓  
VOICE DEFINITION (spec/style/grammar/pacing/evolution)  
  ↓  
REASONING TOOLS (escalation / misdirection / comedy engine)  
  ↓  
ANCHORS (seed prompts / corpus)  
  ↓  
OUTPUT  
  ↓  
TESTS (during development)
