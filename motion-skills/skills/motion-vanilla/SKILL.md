---
name: motion-vanilla
description: Official Motion skill for the framework-agnostic standalone API — the animate(), hover(), press(), and scroll() functions from the "motion" and "motion/mini" packages for plain JavaScript, Vue, Svelte, or any non-React project. Use when the user wants Motion's animation engine outside of React, or asks about the mini/hybrid bundle size trade-off.
license: MIT
---

# Motion Vanilla / Standalone API

## When to Use This Skill

Motion isn't React-only — it ships a standalone, framework-agnostic API for plain JavaScript, Vue, Svelte, Astro, or any DOM-based project. Use this skill instead of **motion-core**/**motion-react** when the project isn't React, or when the user explicitly wants the imperative `animate()` function rather than declarative JSX props.

**Related skills:** For the React-specific imperative equivalent (`useAnimate`), see **motion-react** — prefer that inside React components since it adds automatic scoping/cleanup this standalone API doesn't have.

## Two Bundles

```javascript
// Hybrid (~18kb) — full feature set
import { animate } from "motion";

// Mini (~2.3kb) — hardware-accelerated native browser APIs only
import { animate } from "motion/mini";
```

- **motion/mini** animates HTML/SVG styles using native browser Web Animations API for minimal bundle size and maximum performance; use it when animating simple style properties on already-selected elements.
- **motion** (hybrid) adds independent transforms, CSS variables, SVG path animation, animation sequences/timelines, color interpolation, and JS object animation — reach for it when the mini feature set isn't enough.

## animate()

```javascript
const box = document.getElementById("box");
animate(box, { opacity: 0 }, { duration: 0.5 });
animate("div.card", { opacity: 0 }, { duration: 0.5 }); // CSS selector, animates all matches
```

Accepts a single element, a CSS selector (all matches animate together), or an array of elements. Options mirror the React `transition` prop:

- **type** — `"tween"`, `"spring"`, or `"inertia"`.
- **duration** (default `0.3`), **delay**, **ease** (`"linear"`, `"easeIn"`, `"easeOut"`, etc.).
- **repeat** (number or `Infinity`), **repeatType** (`"loop"`, `"reverse"`, `"mirror"`).

## Timeline Sequences (Hybrid Only)

A sequence is an array of `[target, values, options?]` tuples, played in order by default:

```javascript
const sequence = [
  ["ul", { opacity: 1 }],
  ["li", { x: [-100, 0] }, { delay: 0.1 }],
];
animate(sequence);
```

Use the **at** option to control timing explicitly:
- Absolute time: `{ at: 1 }` (1 second from sequence start).
- Relative to previous step: `{ at: "+0.5" }` (0.5s after the previous step ends), `{ at: "<" }` (start at the same time as the previous step).
- Labels: mark a point with a string in the sequence, then reference it with `at` elsewhere for readable, reusable choreography.

## Playback Controls

Both `animate()` calls return controls for manual playback:

```javascript
const controls = animate(box, { x: 100 });
controls.pause();
controls.play();
controls.stop();
controls.complete();
controls.speed = 2;
controls.time; // current playback time
```

## Gesture Shorthands

The standalone API also exposes `hover()` and `press()` functions mirroring `whileHover`/`whileTap` for non-React DOM code, plus `scroll()` mirroring `useScroll`/scroll-linked animation for plain JavaScript. Reach for these instead of hand-rolled `addEventListener` + `animate()` combinations — they handle the enter/exit state transitions Motion's React gesture props handle declaratively.

## Best practices

- ✅ Default to `motion/mini` unless a feature it lacks (sequences, SVG paths, CSS variables, JS object animation) is actually needed — it's roughly 8x smaller.
- ✅ Use sequence `at` labels for multi-step choreography instead of manually calculating delays for each step.
- ✅ Use `hover()`/`press()`/`scroll()` instead of manual event listeners driving `animate()` calls.
- ✅ In a React app, prefer **motion-react**'s `useAnimate` over this standalone API for anything living inside a component — it adds scoping and automatic cleanup this API doesn't provide on its own.

## Do Not

- ❌ Import the full `motion` hybrid bundle when only simple style animation on already-selected elements is needed — `motion/mini` covers that case at a fraction of the size.
- ❌ Manually track and clean up `animate()` calls tied to a React component's lifecycle — that's what `useAnimate` (see **motion-react**) is for.
- ❌ Hardcode absolute timings for every step in a sequence when relative (`"+0.5"`, `"<"`) or label-based positioning would survive edits to earlier steps without re-tuning every subsequent delay.

### Learn More

https://motion.dev/docs/animate
