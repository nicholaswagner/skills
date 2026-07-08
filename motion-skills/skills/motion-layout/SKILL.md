---
name: motion-layout
description: Official Motion skill for layout animations — the layout prop, layoutId shared-element transitions, and LayoutGroup. Use when the user wants elements to smoothly animate as their size or position changes (reordering lists, expanding cards, accordions, tabs with a sliding indicator), without hand-writing FLIP or measuring the DOM manually.
license: MIT
---

# Motion Layout Animations

## When to Use This Skill

Apply when a layout change (a size or position change caused by CSS, content, or reordering — not by `animate`) should transition smoothly instead of snapping. Motion measures the element before and after the change and animates the difference using transforms, which means it can animate properties that are normally unanimatable, like `justify-content` or switching from `flex-direction: row` to `column`.

**Related skills:** For animating properties directly via `animate`, see **motion-core**. For unmounting one element while another appears (paired with `layoutId` for shared-element transitions), see **motion-animate-presence**. For why transform-based layout animation is fast, see **motion-performance**.

## The layout Prop

Add a single prop:

```jsx
<motion.div layout />
```

Whenever this element's size or position changes between renders — a sibling was added/removed, its content grew, a CSS class changed its width — Motion animates from the old geometry to the new one automatically.

- **`layout="position"`** — animate position only, skip scaling; use when a child's contents would otherwise visibly stretch/squash during the transition (e.g. text inside a resizing card).
- **`layout="size"`** — animate size only, skip repositioning.
- Give layout animations their own timing separate from other props via `transition={{ layout: { duration: 0.3 } }}`.

## layoutId — Shared Element Transitions

Two different components (even unmounting one and mounting another) that share a `layoutId` are treated by Motion as the *same* element for animation purposes:

```jsx
{selectedTab === "a" && <motion.div layoutId="underline" />}
{selectedTab === "b" && <motion.div layoutId="underline" />}
```

When the component with a given `layoutId` changes — a different tab's underline mounts, a different card expands to a detail view — Motion animates the new instance from the old instance's position/size, producing a "morphing" transition instead of a cut. If the old instance is still on-page during the new one's entrance (rather than unmounting first), they crossfade automatically. Pair with `AnimatePresence` when the old instance needs to actually leave the DOM.

## LayoutGroup

Sibling `motion` components with `layout` don't automatically know about each other's layout changes if they're rendered by different parents or update on different renders. `LayoutGroup` synchronizes them:

```jsx
<LayoutGroup>
  <motion.div layout />
  <motion.div layout />
</LayoutGroup>
```

Use this when expanding one item should cause others to visibly, smoothly reflow in the same animation frame rather than snapping independently. If multiple unrelated `layoutId` groups exist on the same page (e.g. two independent tab bars), give each `LayoutGroup` an `id` prop to namespace their `layoutId`s and prevent cross-talk.

## Performance Notes

Motion animates layout by computing a transform (translate + scale) that visually matches the old geometry, then animating that transform back to identity — it does not animate `width`/`height`/`top`/`left` directly. This keeps layout animations on the compositor and avoids triggering paint on every frame, which is why `layout` can be added liberally without the cost of naive JS-measured layout tweening.

## Best practices

- ✅ Use `layout="position"` for elements whose content shouldn't be visibly stretched (text, icons) during a resize transition.
- ✅ Use matching `layoutId` values for shared-element transitions (tab indicators, expanding cards) instead of manually measuring and animating two separate elements.
- ✅ Wrap groups of interdependent `layout` siblings in `LayoutGroup` so they reflow together.
- ✅ Namespace `LayoutGroup`s with an `id` when a page has more than one independent set of shared-`layoutId` elements.

## Do Not

- ❌ Add `layout` to elements with text/icons that shouldn't visibly distort during the transition without also considering `layout="position"`.
- ❌ Reuse the same `layoutId` for two elements that aren't meant to be visually continuous — Motion will animate between them as if they were the same object, which looks wrong for unrelated elements.
- ❌ Expect independent `motion` components with `layout` to reflow together without a shared `LayoutGroup` — without it, each animates its own transition in isolation.

### Learn More

https://motion.dev/docs/react-layout-animations
