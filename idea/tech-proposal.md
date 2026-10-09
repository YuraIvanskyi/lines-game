# Tech proposal

**One Flutter app, with the match rules in a pure Dart package.** iOS and Android are two builds of that app. iOS is the first build that must feel finished. The Pygame prototype stays as the rule reference until the Dart package covers classic mode.

This is a store app with a board in the middle, not a realtime action game that happens to have menus. Hot-seat, setup, how-to, rematch, later themes, and later a lobby are all product UI. The board is an 8×8 lattice, a polyline, and a handful of tweens. Flutter covers both, and the rules can be tested without a phone.

## What is shared

| Piece | Where | Notes |
| --- | --- | --- |
| Classic rules, future mode rules | `packages/rules` | No Flutter imports. Seeded deals, legal moves, apply move, loss, move log. |
| Screens, board view, animation, sound triggers | `app/` | Widgets and a board painter. Reads an immutable match snapshot. Sends intents (`Start`, `Grow`, `ChooseEnd`, `Rematch`). |
| Cosmetic tokens | `app/` theme objects | Paper, ink, dot, motion timings. Classic rules never read them. |
| iOS and Android shells | Flutter's platform folders | Safe area, status bar, haptics, later store billing. |

A finished match is reproducible from a mode id, a seed, the player list, and the move list. Replaying that log in `packages/rules` rebuilds the board. Hot-seat uses it now. Online play, when it exists, is another writer of the same log. The phone does not grow a second rules implementation.

Proposed tree, created only when Phase 0 starts:

```text
app/                  Flutter application (iOS target first, Android folder comes along)
packages/rules/       Dart package, unit-tested
idea/                 this planning folder
prototype/            Pygame draft (main.py, src/, assets/)
```

## Where the platforms may differ

Allowed per platform: launch screens, safe areas, haptic vocabularies, store listing, and the billing SDK behind a theme-catalog interface.

Not allowed per platform: board size, crossing, walls, turn order, win/loss, or a separate move format. A mode ships once, for both builds.

## Feel, without a second engine

The first board is a Flutter widget: layout, gesture, and short animations (ink draw, target pulse, pass-the-phone). Authored motion, if a screen needs it, comes in as Rive. Flame is an add-on inside the same app only if a later mode needs a real game loop. It is not the foundation.

Portrait. One thumb. Pass the phone between turns. Cold start to a classic game in two taps, with names and player count available but not required.

iOS is checked on the owner's iPhone 16 Pro ([ios-device.md](ios-device.md)). This project has no Mac. The Windows workspace runs the Dart tests. A GitHub-hosted macOS runner compiles an unsigned iOS build, and Sideloadly on Windows installs it onto the phone.

## Options set aside

| Path | Why it is not the default |
| --- | --- |
| SwiftUI / SpriteKit, then a Kotlin port | Best iOS-only fit. Android becomes a second rules codebase. Modes and cosmetics would be built twice. Take this only if a shared UI toolkit is rejected outright. |
| Godot 4 | Strong 2D game export to both stores, one project. Weaker for the setup, shop, and account screens this product grows into. Fallback if an early iOS build cannot sell the ink. |
| Unity | Right for heavy VFX, ads mediation, and realtime modes. Heavy for an 8×8 turn game and slower to iterate with agents. |
| React Native | One product UI, a poorer fit for a custom board and ink. |
| Mobile web / PWA | Fast to show, wrong App Store target, weak offline and haptics. |

Godot stays the documented fallback. Switching to it means stopping before Phase 1 and rewriting this proposal. It does not mean keeping a Flutter UI and a Godot board.

## Later capabilities this leaves room for

- **More modes.** A mode is data plus optional rule hooks in `packages/rules` (size, wall chance, extra constraints). Classic is the first row, 8×8, not a pile of constants in the widget.
- **Cosmetics.** Skins swap tokens. They do not swap rules. No billing SDK until a Phase 8 ticket says so.
- **Online.** Transport is undecided on purpose. The protocol is the move log plus the seed. No accounts and no backend in the hot-seat phases.

## Gate

Phase 0 starts when this proposal is accepted, or when it is replaced. Until then every ticket stays in `backlog`. Accepting Godot, Unity, or a native split replaces this file before any `app/` directory is created.
