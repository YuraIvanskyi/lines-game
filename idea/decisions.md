# Decisions

Locked rows are in force. Proposed rows are the defaults Phase 1 will implement unless `idea/classic-mode.md` overrides them first. Prototype behavior that is a harness bug is listed so it is not copied by accident.

## Locked

| ID | Decision |
| --- | --- |
| L1 | Two or more players alternate. A turn grows the single polyline from one of its two ends. The player who faces no legal growth loses. |
| L2 | Classic mode uses the prototype's play rules: king-move adjacency (8 directions), walls, no crossing an already drawn opposite diagonal, one anchor that starts as both ends, no wrap. |
| L3 | Classic field is **8×8**. The Pygame window was 4×4. Size is the intentional change. Wall chance stays 0.05. The anchor is never a wall. |
| L4 | First ship is offline hot-seat. Online is a later transport over the same match log. |
| L5 | iOS is the first finished build. The test device is the owner's **iPhone 16 Pro** (portrait layout 402×874 pt, Dynamic Island, USB-C). Android is the same project, later. |
| L6 | Monetization, if it ships, sells presentation: boards, inks, dots, flourishes. It does not sell rules, moves, or the classic field. |
| L7 | Stack is the one in [tech-proposal.md](tech-proposal.md), once that file is accepted. |
| L8 | There is no Mac. Dart tests run on this Windows machine. iOS compiles on a GitHub-hosted macOS runner for `YuraIvanskyi/lines-game`, which uploads an unsigned build. The owner installs that build on the 16 Pro from Windows with Sideloadly and a free Apple ID, over USB-C. A paid developer account and TestFlight can replace Sideloadly later. |
| L9 | The phone app follows [port-patterns.md](port-patterns.md). Classic behavior is ported. `Node`, `Connection`, sprite drawing, direction-string moves, and `itertools.cycle` are not. |

## Proposed

| ID | Prototype behavior | Classic default to build |
| --- | --- | --- |
| P1 | If a dot is adjacent to both ends, the click always grows the head. The tail move is unreachable. | The player chooses the end. The dot highlights both ends, and a second tap (or an end marker) commits one of them. |
| P2 | Anchor, walls, and paper wobble use unseeded `random`. | The deal stores a seed. Replaying seed + moves rebuilds the same walls, anchor, and line. |
| P3 | The window hardcodes four named players. `Board` alone defaults to two. | Rules accept two or more. The first hot-seat screen offers 2, 3, or 4, and defaults to 2. |
| P4 | Space starts a new deal and skips the player who was about to move. | Rematch rotates who starts. Nobody is skipped. |
| P5 | After the first move, head and tail are the same white ring. | The two ends are visually distinct for the whole game. |
| P6 | A dot's fill becomes the color of whoever last touched it, so earlier dots change color as the line grows. | A segment keeps the drawing player's ink. A dot does not recolor when the line grows onward. |
| P7 | The loss banner appears and the frame loop keeps running. | Game over is a stopped state: who lost, rematch, home. |
| P8 | — | Portrait, one thumb, pass the phone. Cold start to a classic game in two taps. |

## Harness behavior that classic does not keep

- `0` auto-play always extends the head when the head has any move.
- Negative neighbor indexes on a 2×2 grid duplicate legal dots via Python wrap. Bounds are `0 .. size-1`.
- Text `main()` and the undrawn pygame-menu screens.
- Stain images and the wobbling notebook are a prototype skin. They may return later as a cosmetic theme. They are not required for classic rules.
