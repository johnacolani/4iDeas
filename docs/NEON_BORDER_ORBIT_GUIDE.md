# Neon Border Orbit Guide (Junior-Friendly)

This guide explains how the neon white dot orbit effect was added to the `My Own Design System` card in the portfolio page.

## Where this is implemented

- Main file: `lib/screens/portfolio_screen.dart`
- Widget: `_DesignSystemHighlight`
- Painter: `_NeonBorderOrbitPainter`

---

## Goal

Create a border-only animation:

- Keep the card content and background unchanged.
- Keep the existing strong static border.
- Add a small white "neon" dot that moves around the rounded border.
- Add a subtle trailing glow behind the moving dot.

---

## Architecture

### 1) Make the card widget stateful

`_DesignSystemHighlight` was changed from `StatelessWidget` to `StatefulWidget`.

Why: animation needs a lifecycle (`initState`, `dispose`) and a ticker.

```dart
class _DesignSystemHighlightState extends State<_DesignSystemHighlight>
    with SingleTickerProviderStateMixin
```

---

### 2) Add an animation controller

We use an `AnimationController` to loop values from `0.0 -> 1.0`.

```dart
_orbitController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 4200),
)..repeat();
```

- `4200ms` controls speed of one full border orbit.
- `repeat()` keeps it continuous.

Always dispose:

```dart
@override
void dispose() {
  _orbitController.dispose();
  super.dispose();
}
```

---

### 3) Overlay a `CustomPaint` on top of the card

The card is wrapped in a `Stack`:

- base child = your normal card UI (text, icon, link).
- overlay = `CustomPaint` with `IgnorePointer` so it never blocks taps.

```dart
Positioned.fill(
  child: IgnorePointer(
    child: CustomPaint(
      painter: _NeonBorderOrbitPainter(
        progress: _orbitController.value,
        borderRadius: 20,
      ),
    ),
  ),
),
```

---

### 4) Draw moving point along rounded-rect border path

Inside `_NeonBorderOrbitPainter`:

1. Build a rounded rectangle path matching the card border.
2. Read path length with `PathMetric`.
3. Convert animation progress to distance on the path.
4. Draw glow trail + bright head dot.

Key concept:

```dart
final head = metric.length * progress;
```

This maps 0..1 animation progress to actual border path distance.

---

## Why `IgnorePointer` is important

Without `IgnorePointer`, the overlay could intercept clicks and break:

- card tap (`onTap`)
- link interaction

So we let visuals render but pass input through.

---

## Performance notes

- This is a single small `CustomPaint` on one card.
- Repaint happens each frame of the animation.
- Keep glow and trail modest (avoid very large blur radii on many cards).

If needed, optimize by:

- reducing trail segments
- increasing animation duration (fewer visual changes per second)

---

## Tuning cheatsheet

In `_DesignSystemHighlightState`:

- Speed: `duration: Duration(milliseconds: ...)`
  - lower = faster
  - higher = slower

In `_NeonBorderOrbitPainter`:

- Dot size: head `drawCircle(..., radius, ...)`
- Trail length: loop count (`for (int i = ... )`)
- Trail spacing: offset step (`i * 7.5`)
- Glow intensity: alpha and blur sigma in `MaskFilter.blur`

---

## Common mistakes to avoid

- Forgetting `dispose()` on animation controller.
- Not using `IgnorePointer` on overlay.
- Using a path radius different from card radius (dot appears off-border).
- Making blur too strong and unintentionally affecting readability.

---

## Summary

We used:

- `StatefulWidget` + `AnimationController` for motion
- `Stack` + `CustomPaint` overlay for visuals
- `PathMetric` to move a white neon dot around the border path

Result: premium border animation with minimal impact on layout and interaction.
