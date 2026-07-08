---
name: motion-react
description: Official Motion skill for React-specific hooks — useAnimate for imperative sequencing, and motion values via useMotionValue, useTransform, useSpring, useVelocity, and useMotionValueEvent. Use when Motion needs to animate outside of JSX declarative props, e.g. animating in response to an async event, chaining several animation steps in order, or reading/writing an animatable value without re-rendering React.
license: MIT
---

# Motion React Hooks

## When to Use This Skill

Most Motion animation is declarative — `animate`, `variants`, gesture props (see **motion-core**, **motion-gestures**). Reach for the hooks in this skill when animation needs to be **imperative** (sequenced steps, awaited, triggered from a callback) or needs a **value that updates outside React's render cycle** — e.g. tracking a drag position at 60fps without triggering a re-render per frame.

**Related skills:** For declarative props these hooks complement, see **motion-core**. For scroll-specific motion values, see **motion-scroll**. For the standalone (non-React) version of `animate()`, see **motion-vanilla**.

## useAnimate — Imperative, Scoped Animation

```jsx
const [scope, animate] = useAnimate();

const exitAnimation = async () => {
  await animate("li", { opacity: 0, x: -100 });
  await animate(scope.current, { opacity: 0 });
  safeToRemove();
};

return <ul ref={scope}>{/* ... */}</ul>;
```

- **scope** is a ref — attach it to a DOM node, and every selector passed to `animate` (like `"li"`) is scoped to that subtree, so it can't accidentally match elements elsewhere on the page.
- **animate** returns a promise, enabling `async`/`await` sequencing of animation steps — the second `animate` call above only runs after the first fully completes.
- Cleans up automatically on unmount, same guarantee as declarative Motion props.
- Integrates directly with `useInView`, `usePresence`, and `AnimatePresence` for combining imperative steps with declarative lifecycle.

Use `useAnimate` instead of `animate` (see **motion-vanilla**) inside React components specifically because it gives automatic scoping and cleanup tied to the component's lifecycle — the standalone `animate()` has neither.

## Motion Values

A motion value is a container for a single animatable value that updates **without causing a React re-render** — Motion writes it straight to the DOM. This is the mechanism behind why gesture and scroll animations stay smooth even during rapid updates.

```jsx
const x = useMotionValue(0);

x.get();          // read current value
x.set(50);        // update without re-rendering
x.getVelocity();  // current velocity (numeric values only)
x.isAnimating();
x.stop();
```

- **useMotionValue(initial)** — create one manually; pass it to a `motion` component's `style` prop (`style={{ x }}`) to drive the DOM directly.
- **useTransform(value, input, output)** — derive a new motion value by mapping one motion value's range onto another (numbers, colors, or other interpolable types). Chainable — feed one derived value into another.
- **useSpring(valueOrSource, config)** — a spring-powered motion value; wrap a raw or derived motion value to smooth its updates, or use standalone as a value that eases toward whatever it's `.set()` to.
- **useVelocity(value)** — a motion value that continuously outputs the velocity of another motion value; useful for velocity-dependent effects (e.g. blur or skew proportional to drag speed).
- **useMotionValueEvent(value, event, callback)** — subscribe to a motion value's lifecycle: `"change"`, `"animationStart"`, `"animationCancel"`, `"animationComplete"`. Prefer this hook over the older `value.on(...)` pattern in React components since it manages subscription cleanup for you.

## Best practices

- ✅ Use `useAnimate` for sequences that must `await` each other, or that trigger from an event handler rather than a prop change.
- ✅ Read/write frequently-changing values (drag position, pointer tracking) through `useMotionValue` + `style`, not React state — state updates re-render on every change, motion values don't.
- ✅ Use `useMotionValueEvent` rather than manually calling `.on()`/`.destroy()` in a `useEffect` — it ties the subscription to the component lifecycle automatically.
- ✅ Chain `useTransform`/`useSpring` to build derived values (e.g. raw drag → smoothed → mapped to opacity) instead of recomputing everything in a single custom function.

## Do Not

- ❌ Store a fast-changing animatable value in `useState`/`useRef` + manual style updates when a motion value does the same job without the re-render cost.
- ❌ Use the standalone `animate()` from `motion`/`motion/mini` inside a component when `useAnimate` is available — you lose automatic scoping and unmount cleanup.
- ❌ Subscribe to motion value changes with `.on()` inside a `useEffect` without a cleanup function — use `useMotionValueEvent` instead so it doesn't leak.

### Learn More

https://motion.dev/docs/react-use-animate
https://motion.dev/docs/react-motion-value
