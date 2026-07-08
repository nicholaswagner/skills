---
name: motion-gestures
description: Official Motion skill for gesture-driven animation — whileHover, whileTap, whileFocus, whileDrag, whileInView, and the drag prop with constraints/elastic/momentum. Use when the user wants hover effects, tap/press feedback, draggable elements, focus states, or scroll-triggered entrance animations in Motion for React.
license: MIT
---

# Motion Gestures

## When to Use This Skill

Apply when a Motion component should react to user interaction — hovering, tapping, dragging, keyboard focus — or come into view while scrolling. All gesture props follow the same pattern: they define a temporary animation target that applies only while the gesture is active, then animate back to `animate` (or the next active gesture) when it ends.

**Related skills:** For the base `animate`/`variants` API these gestures build on, see **motion-core**. For scroll-linked (not just scroll-triggered) values like parallax, see **motion-scroll**. For unmount animations, see **motion-animate-presence**.

## The while* Props

```jsx
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  whileFocus={{ outline: "2px solid blue" }}
/>
```

- **whileHover** — pointer enters/leaves the element. Also exposes `onHoverStart`/`onHoverEnd` callbacks for side effects beyond animation.
- **whileTap** — a press-and-release gesture starting and ending on the same component; fires a `tap` event. Keyboard-accessible: pressing Enter on a focused element triggers it too, so it doubles as press feedback for buttons and links without extra ARIA work.
- **whileFocus** — driven by CSS `:focus-visible` semantics, so it shows for keyboard focus but not for a mouse click that doesn't need a visible ring — respects the same accessibility intent as native `:focus-visible`.
- **whileDrag** — active only while `drag` is engaged (see below).
- **whileInView** — active while the element intersects the viewport (see Viewport-Triggered below).

These props take priority over `animate` while active, and Motion automatically reconciles multiple simultaneously-active gestures (e.g. hovering while focused).

## Drag

Add `drag` to make an element draggable; it defaults to both axes unless restricted:

```jsx
<motion.div
  drag
  dragConstraints={{ left: 0, right: 300, top: 0, bottom: 0 }}
  dragElastic={0.2}
  dragMomentum={true}
  whileDrag={{ scale: 1.1 }}
/>
```

- **drag** — `true`, `"x"`, or `"y"` to restrict to one axis.
- **dragConstraints** — an object of pixel bounds, or a ref to a container element so the drag target can't leave its bounds.
- **dragElastic** — `0` (rigid) to `1` (very stretchy) resistance when dragging past constraints; `false` disables it.
- **dragMomentum** — whether releasing the drag continues the motion with inertia (default `true`).
- **onDragStart** / **onDrag** / **onDragEnd** — callbacks for reacting to drag state, e.g. persisting a final position.
- **Pan** — a related but distinct gesture (pointer down + 3px+ movement) with no dedicated `while*` prop; use `onPan`/`onPanStart`/`onPanEnd` when tracking movement without making the element draggable.

## Viewport-Triggered (whileInView)

```jsx
<motion.div
  initial={{ opacity: 0, y: 50 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, amount: 0.5 }}
/>
```

- **viewport.once** — animate in only the first time the element enters view; without it the animation reverses back out as the element leaves, then replays on re-entry.
- **viewport.amount** — fraction (`0`–`1`) or `"some"`/`"all"` of the element that must be visible to trigger.
- **viewport.margin** — expands or shrinks the trigger area, same syntax as CSS `margin` (e.g. `"-100px"` to trigger later).

Use `whileInView` for one-shot or repeatable **entrance** animations. For animations that track scroll position continuously (parallax, progress bars), use `useScroll`/`useTransform` instead — see **motion-scroll**.

## Best practices

- ✅ Use `whileTap` rather than a custom `onClick`-triggered animation for press feedback — it's already keyboard-accessible.
- ✅ Pass a ref to `dragConstraints` (rather than hardcoded pixel bounds) when the draggable area's size can change (responsive layouts, dynamic content).
- ✅ Use `viewport={{ once: true }}` for entrance animations that shouldn't replay every time the user scrolls past — replaying on every scroll is usually distracting, not delightful.
- ✅ Combine gesture props freely — Motion resolves precedence between hover/tap/focus/drag automatically.

## Do Not

- ❌ Forget `dragConstraints` on a drag-enabled element that lives inside a fixed layout — without it, the element can be dragged anywhere in the viewport, including over other UI.
- ❌ Use `whileInView` without `once: true` for content that should only ever animate in once; the default replays the animation every time the element re-enters the viewport, which can look broken for state that shouldn't reset (e.g. a counter).
- ❌ Reach for manual `onMouseEnter`/`onMouseLeave` state + `animate` when `whileHover` does the same thing with less code and no state.

### Learn More

https://motion.dev/docs/react-gestures
