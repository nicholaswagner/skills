# Dara O'Brien Skill Overview

## What this skill does
This skill defines a two-mode assistant persona inspired by Dara O'Brien's analytical style: `AW` (Analytical Wit) for conversational reasoning, and `NO` (Neutral Operator) for technical/procedural clarity. It is designed so humor comes from logic, not punchlines, with guardrails that keep tone respectful and idea-focused.

## How it works
1. `SKILL.md` acts as the standard entrypoint, router, and behavior contract.
2. `BOOT_SEQUENCE.md` provides stronger voice calibration when needed.
3. `docs/VOICE_RUNTIME.md` resolves ambiguous `AW` vs `NO` decisions.
4. In `AW`, `docs/VOICE_CHECKLIST.md` and `docs/VOICE_DRIFT_MONITOR.md` run internal quality checks.
5. Voice is shaped by definition docs (`CHARACTER_SPEC`, `STYLE_GUIDE`, `VOICE_GRAMMAR`, `RESPONSE_PACING`, `VOICE_EVOLUTION`).
6. Exactly one primary reasoning tool is selected (`ESCALATION_PATTERNS`, `COMEDY_ENGINE`, `SPEECH_AND_PATTERNS`, `LOGICAL_TRAP_PATTERNS`, `RHETORICAL_PATTERNS_LIBRARY`, or `INTELLECTUAL_MISDIRECTION_LOOP`).
7. Safety docs (`REASONING_GUARDRAILS`, `ANTI_PATTERNS`) constrain tone and behavior.
8. Examples anchor style; tests validate routing and voice stability.

## File-by-File Summary

### Root
| File | Summary |
|---|---|
| `LICENSE` | MIT license for the skill package. |
| `OVERVIEW.md` | This high-level overview and per-file index. |
| `README.md` | Primary introduction, architecture map, and runtime flow diagram. |

### Root-level files
| File | Summary |
|---|---|
| `BOOT_SEQUENCE.md` | Startup initialization for tone, cadence, and internal reasoning loop. |
| `COMEDY_ENGINE.md` | 7-step procedural method for generating logic-led analytical humor. |
| `ESCALATION_PATTERNS.md` | Three-step claim-to-implication escalation template with variants. |
| `SKILL.md` | Core skill contract, load order, mode guidance, and behavior rules. |
| `SPEECH_AND_PATTERNS.md` | Cadence model plus reusable joke/reasoning pattern library. |

### docs/
| File | Summary |
|---|---|
| `docs/ANTI_PATTERNS.md` | Explicit "never do this" behaviors (insults, snark, over-joking, etc.). |
| `docs/CHARACTER_SPEC.md` | Persona archetype, traits, goals, strengths, and intentional weaknesses. |
| `docs/INTELLECTUAL_MISDIRECTION_LOOP.md` | Advanced layered reasoning technique for delayed, deeper implication reveals. |
| `docs/LOGICAL_TRAP_PATTERNS.md` | Ten contradiction-exposing reasoning trap templates with failure modes. |
| `docs/REASONING_GUARDRAILS.md` | Tone and conduct safeguards: curiosity-first, non-combative reasoning. |
| `docs/RESPONSE_PACING.md` | Beat-based pacing rules so output feels spoken and conversational. |
| `docs/RHETORICAL_PATTERNS_LIBRARY.md` | Reusable rhetorical structures to increase variety and reduce repetition. |
| `docs/SKILL_DRAFT.md` | Earlier draft version of the analytical-wit skill specification. |
| `docs/STYLE_GUIDE.md` | Surface writing style standards and do/don't phrasing guidance. |
| `docs/SYSTEM_ARCHITECTURE.md` | End-to-end architecture and responsibility breakdown for all layers. |
| `docs/VOICE_CHECKLIST.md` | Short pre-response checklist: mode, tone, target, structure, safety. |
| `docs/VOICE_DRIFT_MONITOR.md` | Internal drift detection and repair actions for AW responses. |
| `docs/VOICE_EVOLUTION.md` | Rules for how familiarity/tone can adapt across conversation phases. |
| `docs/VOICE_GRAMMAR.md` | Linguistic fingerprints: sentence rhythm, transitions, punctuation habits. |
| `docs/VOICE_RUNTIME.md` | Runtime mode controller for `AW` vs `NO`, including overrides/hybrid. |
| `docs/VOICE_TUNING.md` | Troubleshooting guide for drift across model/temperature/runtime changes. |

### examples/
| File | Summary |
|---|---|
| `examples/LOGIC_PLAYGROUND.md` | Practice exercises for strengthening analytical reasoning patterns. |
| `examples/REASONING_CORPUS.md` | Curated reasoning snippets used as cadence and style anchors. |
| `examples/VOICE_EDGE_CASES.md` | Boundary examples for sensitive, technical, and tricky tone scenarios. |
| `examples/VOICE_SEED_PROMPTS.md` | Seed dialogues and anchors for rapid voice priming/calibration. |

### tests/
| File | Summary |
|---|---|
| `tests/MODE_SELECTION_TESTS.md` | Prompt suite to validate AW/NO routing and hybrid constraints. |
| `tests/VOICE_REGRESSION_TESTS.md` | Regression prompts and scoring rubric to detect drift after changes. |
| `tests/VOICE_TESTS.md` | Placeholder test file marked as missing/incomplete. |
