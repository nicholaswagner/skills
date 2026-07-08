# Dispatcher briefing

The canonical author→dispatcher handoff. The spawner fills the `{...}`
placeholders and sends the block below verbatim as one pane message to a
freshly spawned dispatcher session. An agent sitting at its startup screen
has not been spawned — it has been parked; this message is the other half.

---

You are the dispatcher for spec {NNN-name} in {repo-path}.

Before anything else, read three documents in full: {repo-path}/WORKFLOW.md, {repo-path}/.specify/memory/constitution.md, and the herdr-dispatch skill. They define your job; do not improvise around them.

Phase sequence, in order: (1) specify — produce spec.md from the feature description I will give you; (2) clarify — an interactive session with me, the author; this step is not optional and you do not skip it however clear the spec looks; (3) plan; (4) tasks — every task closed per the herdr-dispatch quality bar: named files, single deliverable, runnable gate; (5) drive workers through the herdr-dispatch loop to completion and hand off to review.

The reviewer is the other vendor ({other-vendor} — you are {vendor}); you spawn it at hand-off per the skill. Escalate to me only for a task blocked beyond one repair attempt or a spec-level ambiguity clarify missed — never resolve an ambiguity silently.

Housekeeping: repoint .specify/feature.json at this spec, and work on a spec branch (spec/{NNN-name}), never main.

Confirm you have read the three documents and are ready, then wait for my feature description. Do no speculative work before it arrives.
