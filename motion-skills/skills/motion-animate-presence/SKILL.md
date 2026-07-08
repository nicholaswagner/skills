---
name: motion-animate-presence
description: Official Motion skill for AnimatePresence — animating components out when they're removed from the React tree (exit animations, mode, popLayout, onExitComplete). Use whenever a Motion for React component needs to animate on unmount, e.g. closing a modal, dismissing a toast, removing a list item, or switching pages/routes.
license: MIT
---

# Motion AnimatePresence

## When to Use This Skill

React removes a component's DOM node the instant it stops being rendered — there's no built-in moment to animate it out first. `AnimatePresence` solves this by detecting when a direct child is about to unmount, keeping it mounted just long enough to run its `exit` animation, then removing it.

**Related skills:** For the `exit` prop's animation values, see **motion-core**. For crossfading between two elements as one leaves and another enters at the same position, see **motion-layout** (`layoutId`).

## Basic Usage

```jsx
<AnimatePresence>
  {isVisible && (
    <motion.div
      key="modal"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
    />
  )}
</AnimatePresence>
```

Requirements for this to work:
- The animated child needs a **stable, unique `key`** — using array indices as keys breaks exit detection when items reorder, since React can't tell which item actually left.
- `AnimatePresence` needs to be a **stable ancestor** — mounting it conditionally alongside its child (e.g. `{isVisible && <AnimatePresence>...}`) removes the wrapper at the same time as the child, defeating the point. Keep `AnimatePresence` always rendered and let the child inside it mount/unmount.

## mode

Controls how simultaneous enter/exit animations are sequenced when one item replaces another:

- **`"sync"`** (default) — entering and exiting elements animate at the same time.
- **`"wait"`** — the exiting element finishes first, then the entering one starts; only one child is ever visible mid-transition. Use for full-bleed transitions (e.g. swapping an entire page or a large card) where overlap would look messy.
- **`"popLayout"`** — the exiting element is removed from layout flow immediately (via absolute positioning) so surrounding siblings reflow right away instead of waiting for the exit animation to finish. Use for lists where removing one item should let the rest slide up immediately.

## Other Props

- **initial** (default `true`) — set `initial={false}` so children present on first render **don't** play their mount animation; only later additions/removals animate. Use this for content that's already there when the page loads.
- **onExitComplete** — callback fired once all currently-exiting children have finished. Useful for cleanup or triggering the next step in a transition sequence.
- **custom** — forwarded to exiting children so their variants can read dynamic data via `usePresenceData()` even after the triggering state has already changed (the exiting component's props are otherwise frozen at the moment of removal).
- **propagate** (default `false`) — when `true`, nested `AnimatePresence` children also exit-animate when the *outer* `AnimatePresence` removes this whole subtree, not just when their own conditional changes.

## popLayout Gotchas

- Custom components used inside `popLayout` must use `forwardRef` so Motion can attach the positioning it needs during the exit.
- A parent with a CSS `transform` interferes with the absolute positioning `popLayout` relies on — prefer solving parent positioning with `position: relative` on the parent rather than `transform`.

## Best practices

- ✅ Give every child inside `AnimatePresence` a stable, content-derived `key` (e.g. an id), never an array index.
- ✅ Keep `AnimatePresence` permanently mounted in the tree; conditionally render the *children*, not the wrapper.
- ✅ Use `mode="wait"` for full-element swaps (pages, modals) and `mode="popLayout"` for lists/grids where siblings should reflow immediately.
- ✅ Use `initial={false}` for content already present on first paint so it doesn't animate in on load.

## Do Not

- ❌ Conditionally mount `AnimatePresence` itself around its child — this removes both at once and skips the exit animation entirely.
- ❌ Use array indices as `key` for lists whose order can change — reordering will misattribute exit animations to the wrong element.
- ❌ Expect `exit` to work on a `motion` component that isn't a **direct child** of `AnimatePresence` (or isn't reached through a stable path to one) — deeply nested conditional rendering that removes an intermediate wrapper also skips detection.

### Learn More

https://motion.dev/docs/react-animate-presence
