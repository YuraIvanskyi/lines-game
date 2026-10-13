# Art direction — default theme

The shipping skin is **Pop**. It follows the chunky-cartoon look that younger arcade games are using now: Stumble Guys and Brawl Stars for saturated toy colors, Toca-style rounded shapes, and the 2026 casual pattern of one huge primary button, thick dark outlines, and a hard offset shadow so a control looks pressable. Glossy candy panels (as in current hidden-object and sticker-sort games) stay out; this pass is flat shapes a phone can draw without a texture set.

The earlier warm paper palette, and the prototype notebook, can return later as a second theme. They are not this skin.

Menu type sits on the same shapes as the buttons. The title is white with an `ink` offset. The mode name is a `sun` pill. Supporting copy sits on a `paper` card with an `ink` outline. Secondary actions are compact pills: `paper` or a player ink, never plain text on the sky.

A turn should read in about a second: the pass line is immediate, the stroke finishes in 280 ms, and the new targets appear when that stroke ends. On an iPhone 16 Pro the board sits in the safe area of a 402×874 pt portrait screen. With 16 pt of padding, an 8×8 cell is about 46 pt and the hit radius is `0.48` of the cell, about a 44 pt thumb target.

## Tokens

| Token | Value |
| --- | --- |
| `skyTop` | `#6B4DFF` |
| `skyBottom` | `#FF6BB5` |
| `sun` | `#FFE14A` |
| `paper` | `#FFF6E4` board card |
| `ink` | `#24143A` outlines and type on buttons |
| `cloud` | `#FFFFFF` title and turn line on the sky |
| `quiet` | `#E7DCFF` |
| `wall` | `#3A2770` |
| `target` | `#FF2D78` |
| `anchor` | `#24143A` |
| player inks | `#FF4D8D`, `#3DDC97`, `#FFC83D`, `#5B8CFF` |

Sizes are fractions of the cell.

| Token | Value | Role |
| --- | --- | --- |
| `quietRadius` | 0.08 | Empty dot that cannot be played. Fill plus an `ink` outline. |
| `wallExtent` | 0.62 | Blocked cell, rounded square, `ink` outline. |
| `wallRadius` | 0.14 | Corner of that square. |
| `dotRadius` | 0.16 | Occupied dot. Fill stays with the player who entered it. |
| `strokeWidth` | 0.14 | Ink segment, round caps. |
| `markWidth` | 0.07 | End marker stroke, color `ink`. |
| `headRadius` | 0.28 | Head is a circle. |
| `tailExtent` | 0.50 | Tail is a rounded square. |
| `tailRadius` | 0.08 | Corner of the tail. |
| `targetWidth` | 0.055 | Legal-dot stroke, color `target`. |
| `targetRadiusMin` / `Max` | 0.20 / 0.26 | Pulse of a legal dot. |
| `pendingRadius` | 0.32 | The dot waiting for an end choice. |
| `hitReach` | 0.48 | Tap distance from a cell center. |

When the line has not started, head and tail share the anchor: the square is drawn, then the circle on top of it.

## Motion

| Token | Duration | Curve |
| --- | --- | --- |
| `draw` | 280 ms | `easeOutCubic` |
| `pulse` | 900 ms, reverse and repeat | `easeInOut` |
| `end` | 180 ms | `easeOutBack`, scale 0.86 → 1 |
| `pass` | 200 ms | `easeOutCubic`, headline scale 0.96 → 1 |
| `loss` | 320 ms | `easeOutBack`, headline scale 0.92 → 1 |

Legal rings stay hidden while a stroke is drawing, then pulse. The next player can still tap during those 280 ms.

## Sound and haptics

Short cues, no music. A missing file is silence. The game still plays.

| Event | Sound | Haptic |
| --- | --- | --- |
| Growth | soft rise, ~90 ms | light impact |
| Illegal tap | low tick, ~70 ms | heavy impact |
| Turn pass | short high tick, ~50 ms | selection click |
| Loss | falling tone, ~220 ms | medium impact |

An illegal tap never uses the growth haptic.
