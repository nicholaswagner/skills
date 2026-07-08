---
name: motion-performance
description: Official Motion skill for performance and bundle size — LazyMotion, the m component vs motion, domAnimation/domMax feature packages, and preferring transform/opacity for smooth animation. Use when optimizing Motion for React bundle size, reducing jank, or when the user asks about the m component, LazyMotion, or Motion's impact on page weight.
license: MIT
---

# Motion Performance

## When to Use This Skill

Apply when optimizing an app using Motion for smooth 60fps animation or smaller JS bundles. Motion's two biggest performance levers are (1) animating the right CSS properties and (2) choosing the right component/loading strategy for how much of Motion's feature set actually ships to the browser.

**Related skills:** For the animation props themselves, see **motion-core**; for why layout animation stays cheap, see **motion-layout**; for the framework-agnostic mini bundle, see **motion-vanilla**.

## Prefer Transform and Opacity

Motion's `x`, `y`, `scale`, `rotate`, and `opacity` are compositor-only properties — animating them avoids triggering browser layout or paint. Prefer these over animating `width`, `height`, `top`, `left`, `margin`, or `padding` directly, even though Motion *can* animate those too:

```jsx
// ✅ compositor-only, cheap
<motion.div animate={{ x: 100, scale: 1.1 }} />

// ❌ triggers layout on every frame
<motion.div animate={{ left: 100, width: 200 }} />
```

When a layout-affecting change is actually needed (an element resizing because content changed), prefer the `layout` prop (see **motion-layout**) — Motion computes a transform-based approximation of the layout change instead of animating the layout properties frame-by-frame.

## motion vs. m — Bundle Size

- **`motion` component** — ~34kb, ships with every feature (animations, gestures, layout, drag) preloaded. Simplest to use; bundlers can't tree-shake it smaller since any instance might use any feature.
- **`m` component** — ~4.6kb for initial render, with no features preloaded. Requires pairing with `LazyMotion` to actually load functionality.

Default to `motion` for small apps or prototypes where the extra ~30kb doesn't matter. Switch to `m` + `LazyMotion` when Motion's bundle weight shows up in a bundle analysis or Lighthouse audit — typically larger apps or performance-sensitive landing pages.

## LazyMotion

```jsx
import { LazyMotion, domAnimation, m } from "motion/react";

<LazyMotion features={domAnimation}>
  <m.div animate={{ opacity: 1 }} />
</LazyMotion>;
```

Feature packages:
- **domAnimation** (+15kb) — `animate`, `variants`, `exit` via `AnimatePresence`, and hover/tap/focus gestures. Covers the large majority of use cases.
- **domMax** (+25kb) — everything in `domAnimation` plus pan/drag gestures and `layout` animations.

Load features **synchronously** (bundled into the main chunk, simplest) or **lazily** via dynamic `import()` after first render, to defer the cost past initial page load:

```jsx
const loadFeatures = () => import("./features").then((res) => res.default);
<LazyMotion features={loadFeatures}>...</LazyMotion>;
```

Set `strict` on `LazyMotion` (`<LazyMotion features={domAnimation} strict>`) to throw an error if a full `motion.*` component accidentally slips into a codebase that's supposed to be using `m` everywhere — this catches an easy-to-miss regression where one `motion.div` silently pulls the full component back into the bundle.

## Best practices

- ✅ Animate `x`/`y`/`scale`/`rotate`/`opacity` in place of `left`/`top`/`width`/`height` wherever the visual result is equivalent.
- ✅ Use `layout` (see **motion-layout**) instead of manually animating layout-triggering properties frame-by-frame.
- ✅ Switch from `motion` to `m` + `LazyMotion` once bundle size actually matters, choosing `domAnimation` unless drag or `layout` animations are needed (then `domMax`).
- ✅ Lazily load `LazyMotion` features via dynamic import when animation isn't needed for the very first paint.
- ✅ Use `strict` mode on `LazyMotion` in codebases standardized on `m` to catch accidental `motion.*` usage in code review.

## Do Not

- ❌ Animate `width`/`height`/`top`/`left` for movement or resizing when `x`/`y`/`scale` or the `layout` prop achieves the same visual result more cheaply.
- ❌ Reach for `m` + `LazyMotion` prematurely in a small app where the ~30kb difference from `motion` is immaterial — the added setup complexity isn't worth it until bundle size is an actual, measured problem.
- ❌ Mix `motion.*` and `m.*` components in a codebase meant to be using `LazyMotion` without `strict` mode — an accidental `motion.div` silently defeats the bundle-size savings.

### Learn More

https://motion.dev/docs/react-reduce-bundle-size
