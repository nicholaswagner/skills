---
name: motion-scroll
description: Official Motion skill for scroll-linked animation — useScroll, useTransform, offset syntax, and combining with useSpring for smoothed scroll-driven values. Use when the user wants a progress bar, parallax effect, scroll-driven reveal, sticky/pinned visual effect, or anything whose animation value tracks scroll position continuously rather than triggering once.
license: MIT
---

# Motion Scroll Animations

## When to Use This Skill

Reach for this when an animation should **track scroll position continuously** (parallax, a progress bar that fills as you scroll, a value that scrubs back and forth with scroll direction) rather than firing once when an element enters view. For one-shot or replayable entrance animations, `whileInView` (see **motion-gestures**) is simpler and is not what this skill covers.

**Related skills:** For entrance-triggered (not continuous) animation use **motion-gestures**. For the underlying motion-value primitives (`useMotionValue`, `useSpring`, `useMotionValueEvent`) use **motion-react**.

## useScroll

Returns four motion values tracking scroll progress — these update without triggering React re-renders, so they're cheap to read every frame:

```jsx
const { scrollX, scrollY, scrollXProgress, scrollYProgress } = useScroll();
```

- **scrollX / scrollY** — raw pixel scroll offset.
- **scrollXProgress / scrollYProgress** — normalized `0`–`1` progress, the more common choice for driving animation values.
- By default tracks the whole page. Pass `{ container: ref }` to track a specific scrollable element instead of the window, or `{ target: ref }` to track a specific element's progress through the viewport (for scroll-linked effects tied to one element rather than the whole page).

## useTransform — Mapping Scroll to Values

`useTransform` maps a motion value's range onto a new output range, producing a new motion value:

```jsx
const { scrollYProgress } = useScroll();
const scale = useTransform(scrollYProgress, [0, 1], [1, 1.5]);
const color = useTransform(scrollYProgress, [0, 0.5, 1], ["#f00", "#0f0", "#00f"]);

<motion.div style={{ scale }} />;
```

This works for numbers, colors, and other interpolable value types, and can map more than two points (as in the color example) for multi-stage effects. Feed the resulting motion value into `style` — not `animate` — since it's continuously driven, not a one-time target.

## Element-Scoped Offsets

When tracking one element's progress through the viewport (via `useScroll({ target: ref })`), the `offset` option defines when progress `0` and `1` occur, as a pair of `"<target edge> <container edge>"` strings:

```jsx
useScroll({
  target: ref,
  offset: ["start end", "end start"],
});
```

This example means: progress is `0` when the target's start hits the container's end (element just entering from the bottom), and `1` when the target's end hits the container's start (element fully scrolled past the top) — i.e. progress tracks the entire time the element is anywhere in the viewport.

## Smoothing with useSpring

Raw scroll progress can feel jittery on trackpads/notches. Wrap it in `useSpring` to smooth it into a springy, lagging follow of the real scroll position:

```jsx
const { scrollYProgress } = useScroll();
const smoothProgress = useSpring(scrollYProgress, {
  stiffness: 100,
  damping: 30,
  restDelta: 0.001,
});
```

Feed `smoothProgress` (not the raw value) into `useTransform` when the effect should feel eased rather than 1:1 with the scrollbar.

## Best practices

- ✅ Use `useScroll` + `useTransform` for effects that scrub with scroll (parallax, progress bars); use `whileInView` for effects that just need to trigger once or on each entry.
- ✅ Feed transformed motion values into the `style` prop, not `animate` — they update every scroll frame outside React's render cycle.
- ✅ Scope `useScroll` to a `target` or `container` ref instead of the whole window whenever the effect is about one specific element or scroll region, not the page as a whole.
- ✅ Add `useSpring` on top of raw scroll progress when the animation should feel smoothed/eased rather than perfectly synced to the scrollbar.

## Do Not

- ❌ Pass a raw scroll motion value straight into `animate` — `animate` expects one-time targets, not continuously-updating values; use `style` instead.
- ❌ Recompute `useTransform` mappings inside a scroll or render loop — define the mapping once; it's already a live, reactive motion value.
- ❌ Use `useScroll`/`useTransform` for a simple "animate in on scroll" effect when `whileInView` (see **motion-gestures**) is simpler and sufficient.

### Learn More

https://motion.dev/docs/react-scroll-animations
