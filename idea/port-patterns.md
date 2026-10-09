# Port patterns

The Pygame prototype is the reference for **what classic mode does**. It is not the reference for **how the phone app is built**. Phase 1 and Phase 2 copy the behavior in [prototype-understanding.md](prototype-understanding.md) and [decisions.md](decisions.md), and they use the shapes in this note. A straight translation of `Node`, `Connection`, and `Board` would keep the draft's mix of rules, sprites, and frame tricks, and every later mode would have to pull them apart again.

An 8×8 match is at most 64 cells and about 64 segments. Rules work is cheap. What gets expensive, and what resists new modes, is a board made of fat objects that draw themselves.

## Leave these in the prototype

| Prototype trick | Where | What to do instead |
| --- | --- | --- |
| Cells and segments are `pygame.sprite.Sprite`s that own a surface, a stain image, and `draw` | `Node`, `Connection` | Rules never see Flutter, images, or offsets. |
| Every cell loads `assets/stains/sN.png` at init, walls or not | `Node.__init__` | The theme decodes an atlas once. A wall cell picks a frame from the seed. |
| Direction strings (`TOP_LEFT`, …) are the move | `can_connect` | A move is an end plus a cell index. A direction is derived when a stroke is animated. |
| `itertools.cycle` is the player list | `Board.players`, `flush` | An ordered list and an integer cursor. Rematch is a new deal with the cursor advanced. |
| Head, tail, connected, and anchor are booleans on the cell | `Node` | `head` and `tail` are two cell indexes on the match. Occupied and wall are bits. The opening anchor is the cell where those indexes are equal. |
| Legal search walks a Python list and uses negative indexes | `possible_connections` | Neighbors are computed with bounds checks. No wrap. |
| Crossing scans every segment | `_crossing` | Each segment is one integer key in a set. The opposite diagonal is one lookup. |
| `can_connect` fills in a mutable result | `objects.py` | `legalMoves` returns a new list. `apply` returns a new match or the same match when the move is rejected. No printing. |
| `Connectivity` equality ignores which end | `utils.py` | A shared target is two moves. The UI asks the player which end (P1). |
| One `itertools.cycle` on the `Node` class drives every pulse | `node_animation_frame` | One animation controller for the current stroke and the current targets. |
| The loop redraws the whole scene at 120 Hz, and hit-testing calls `pygame.mouse.get_pos` during paint | `Game.mainloop`, `Node.hovered` | The board is idle until a tap or a short tween. Hit rectangles are rebuilt when the size changes, not when the clock ticks. |
| Deal RNG, paper wobble, and stroke jitter share `random` | `Board`, `Connection` | The seed feeds only the anchor and the walls. Jitter belongs to the skin and must not change the deal. |
| `PlayerVisual` exists twice | `board.py`, `utils.py` | One player value: id, display name. Color is a theme concern. |
| `flush` constructs a new board by handing the live cycle back in | `Board.flush` | Rematch is an explicit function of the finished match. |

## Match

A classic match is a value:

- `width`, `height` (8 and 8 for classic)
- `seed`
- `walls` and `occupied`, each a bit grid
- `head`, `tail`, cell indexes
- `segments`, an immutable list of segment keys in play order, with the player who drew each one
- `players`, a list, and `turn`, an index into it
- `terminal`, empty or the id of the player who lost

A cell index is `y * width + x`. Coordinates stay in range by construction.

**Bit grid.** Classic is exactly 64 cells, so each mask fits in one integer. Modes may use another size, so the type is a little grid of bits: one integer when `width * height <= 64`, more words after that. Callers test and set bits. They do not allocate a `Node` per cell.

**Segment key.** Pack the two endpoints in ascending order into one integer (`lo << 16 | hi` is enough headroom past 8×8). The segment list preserves draw order and owner. The set of keys answers "does this edge exist?" without a scan. A diagonal from `a` to `b` is blocked when the key of the opposite corners is in that set. Orthogonal steps do not consult it.

**Growth.** `legalMoves(match)` returns at most 16 moves, each `{ end: head or tail, cell }`. When head and tail are the same cell, each neighbor is still one move; the end tag may be head. When the ends differ, a cell next to both is two moves.

`apply(match, move)` returns a new match. The next segment list is the old list plus one entry. Occupied bits and the chosen end index change. The turn cursor advances. An illegal move returns the same match. The opening growth moves `head` and leaves `tail` on the anchor.

Replaying the log from the seed rebuilds this value. The bit grids and the key set are a cache of that replay, not the saved form.

## UI

The table paints a snapshot. It does not own the rules.

- Layout: from the 16 Pro's portrait band (inside the safe area of a 402×874 pt screen), compute 64 centers and 64 hit radii once per constraint change.
- Paint: a `CustomPainter` behind a repaint boundary. `shouldRepaint` is false when the snapshot generation and the tween position are unchanged.
- Committed ink is a cached path per segment. A tween builds only the newest stroke, then that path joins the cache.
- Legal moves are cached next to the snapshot. Paint and hit-testing read the cache. They do not call `legalMoves` per frame.
- Wall pictures come from the theme, chosen by seed and cell, decoded once per theme.
- A tap maps a local offset to a cell through the cached centers, then to a move. Ambiguous cells ask for an end. The widget does not reimplement king-moves or crossing.

There is no standing 120 Hz loop. An `AnimationController` runs for a growth, a target pulse, and the turn cue, then stops.

## Modes, online, skins

A mode supplies size, wall chance, and a rule object whose jobs are neighbors, blocks, and the loss check. Classic is the first object. A new mode is a new object and a mode record, not a subclass of a cell and not a copy of the painter.

Skins replace colors, paths, atlases, and durations. They do not take the seed's random stream and they do not import the rules package's types into Flutter beyond the snapshot the painter is given.

Online later appends the same moves. It does not send sprites, paths, or bit grids.
