# Prototype understanding

Reading of the hand-crafted prototype on `main` (commit `83620d1`, "Handdrawn lines, assets, 120 tick, animation"). This is what the code does today. It is the base for a later core-mechanic note, not that note itself.

The window title is **Litterally Pen Game**. The play is a single polyline on a dot grid. It starts as one dot that is both ends of the line. Players take turns growing either end into a neighboring empty dot. The player who faces no legal growth loses.

## How to run it

Dependencies, unpinned, in `requirements.txt`: `pygame`, `pygame-menu`.

On this machine `python` is Inkscape's interpreter and has no pip. The interpreter that can run the game is Python 3.13 via the `py` launcher. From `prototype/`:

```text
py -3.13 -m pip install -r requirements.txt
py -3.13 main.py
```

The process must be started with `prototype/` as the working directory. Imports are `src...`, and images load from relative paths `assets/grid.jpg` and `assets/stains/s1.png` … `s15.png`. Every dot loads a stain at construction, and `Game` loads `grid.jpg` at startup, so a missing file crashes before play. `grid.jpg` is never drawn. The notebook under the dots is drawn in code.

`pygame` 2.6.1 and `pygame-menu` 4.5.2 were installed into the user site for Python 3.13 while checking this prototype. Launching `main.py` opens a 600×800 window titled "Litterally Pen Game" and goes straight to the board.

There is a second entry, `main()` in `main.py`, left commented out. It calls `Board(width=3, height=3, start_anchor=Point(0, 0))` and `display_as_text()`. The current `Board` constructor requires a `pygame.Surface`, so that text path does not run as written. `display_as_text()` also prints `○` / `●`, which raises `UnicodeEncodeError` on a cp1251 Windows console.

## What the window shows

`Game.mainloop` fills the window white, draws one status line, draws the board, and ticks at 120 FPS. The pygame-menu screens are built and then never drawn: the `mainmenu.draw` / `action_phase.draw` block in `menus.py` is commented out. Play and Quit never appear.

Status line, top left, in Fantasque Sans M Nerd Font Propo (on this machine that resolved to the italic cut; a machine without the family gets a SysFont fallback):

- `Shuri's turn` while moves exist. The name is the current player.
- `You lost Shuri, no connections left` when the current player has no move. The loop does not stop.

The board is a wobbly closed polygon with internal horizontal and vertical lines in pacific blue `(28, 169, 201)`, meant to look like a torn notebook page. Margins are random in 25–55 px and frozen for that board. A red bounds rectangle exists as `draw_game_bounds` and is not called.

Default field from `Game`: **4 columns × 4 rows** (`FIELD_X`, `FIELD_Y`). For a 600×800 surface the dots land on a 112.5 px lattice inset by (150, 300), with radius 43.75. Coordinates are `(x, y)` with `x` to the right and `y` downward, stored as `nodes[y][x]`.

Captured from the real `draw()` path (one animation frame, no hover):

| Frame | What it shows |
| --- | --- |
| [frames/01-opening.png](frames/01-opening.png) | Fresh 4×4. Anchor is a black ring. Legal growths are red rings. Banner is Shuri's turn. |
| [frames/02-first-move.png](frames/02-first-move.png) | After the opening segment. Both dots and the scribble are the mover's green. Steve to play. |
| [frames/03-walls.png](frames/03-walls.png) | Every non-anchor dot forced to a wall. Anchor is trapped, so the banner is the loss line on the first turn. |
| [frames/04-both-ends.png](frames/04-both-ends.png) | Four players have each grown an end. Two white inner rings mark the live ends. Red rings are the remaining targets. |

Visual language:

- **Anchor before any segment:** black inner ring. It is both head and tail, so the head drawing wins and the tail ring is not drawn yet.
- **Live ends after play starts:** white inner ring on the head and on the tail.
- **Occupied dot:** filled circle in the color of the last segment that touched it. Growing an end recolors the old endpoint too, because the new `Connection` is appended to both dots and the dot paints `connections[-1]`.
- **Segment:** five overlapping polylines, 10 steps each, jitter of ±5 px, width 2, cached so the scribble does not crawl. Color stays with the player who drew that segment.
- **Legal target:** red ring whose radius breathes by 1–3 px. The breath is one shared frame counter on `Node`, consumed once per target per frame, so neighboring targets sit on different phases. Hover (cursor within radius + 20% ) fills the ring with the current player's color.
- **Wall:** a random stain `assets/stains/s1.png`–`s15.png`, scaled by `NODE_RADIUS / 100`. Stains are ink blots and crayon scribbles. A wall is never a target and is never the anchor.

Players wired in `Game.__init__`, in turn order:

| Name | Color | RGB |
| --- | --- | --- |
| Shuri | dark green | `(0, 100, 0)` |
| Steve | orange | `(255, 165, 0)` |
| Chen | burgundy | `(128, 0, 0)` |
| Pylyp | dark blue | `(0, 0, 128)` |

`Board` itself, if constructed with no player list, uses Player 1 in cyan and Player 2 in yellow. The window path passes the four names above.

## Controls

| Input | Effect |
| --- | --- |
| Click a red target | Grow the matching end and pass the turn. Mouse-up calls the same picker and ignores the result. |
| Space | `flush()`: new anchor, new walls, new paper wobble, same window size. Player cycle continues, shifted one seat (the player who was about to move does not open the new board). |
| 0 | `random_simulation()`: auto-play until no moves remain. If the head has any move it always grows the head, and only otherwise grows the tail. |
| Close the window | `exit()`. |

Hover does not commit a move. Only mouse-down on a dot returned by `pick_next_by_mouse` does.

## Rules as implemented

### Board setup

- Grid `width` by `height`. The window uses 4×4.
- One **anchor**, random unless `start_anchor` is passed. That dot starts `connected`, `is_head`, and `is_tail`. Head and tail pointers both reference it. The connection list is empty.
- Each other dot is a **wall** with probability `wall_density` (default `0.05`). The anchor is never a wall. On 4×4 the expected wall count is under 1, so many deals have a clean grid.
- `current_player` is the first player of the cycle. `PlayerVisual.turn` and `.lost` are never set.

### A legal growth

`Node.can_connect` allows a step from a connected dot to another dot when all of these hold:

- The target is not a wall.
- The source is already connected and the target is not.
- Both coordinates are ≥ 0. There is no matching upper-bound check inside `can_connect`.
- Chebyshev distance is exactly 1: a king-move, orthogonal or diagonal. The same cell is rejected.

The eight successful cases are labeled `TOP`, `BOTTOM`, `LEFT`, `RIGHT`, `TOP_LEFT`, `TOP_RIGHT`, `BOTTOM_LEFT`, `BOTTOM_RIGHT` in `prototype/src/const/symbols.py`. The label is the direction from the source toward the target, with `y` increasing downward (`TOP` means the target has a smaller `y`).

`Board.possible_connections` only asks the eight surrounding coordinates, and it drops a diagonal when it would cross an existing opposite diagonal. For a step from `(x, y)` to `(x±1, y±1)`, the two side dots are `(x, y±1)` and `(x±1, y)`. The step is removed when those two side dots are both connected **and** a segment already joins them. Orthogonal steps are not removed by this test. Occupying both side dots without a segment between them does not block the diagonal. That matches "do not cross an inked line", not "do not pass between two occupied dots".

Confirmed on a 3×3: after segments `(0,0)—(1,1)` and the head sitting on `(1,0)`, the head's options were only `(2,0)` and `(2,1)`. The crossing step to `(0,1)` was absent.

`available_moves` is the head's possible steps followed by the tail's, with duplicates dropped when start and end both match (`Connectivity.__eq__` ignores `from_head` / `from_tail`).

### Playing a turn

`connect_head` / `connect_tail`:

1. `Node.connect` marks both dots connected and stores one `Connection` on both, tagged with the current player.
2. The old end clears `is_head` or `is_tail`, the target becomes that end.
3. The player cycle advances.

The opening click always takes `connect_head`, because the anchor reports `from_head` and `from_tail` together and the click handler tests `from_head` first. After that move the anchor remains the tail and the new dot is the head. Later turns may grow either end.

A failed `connect` prints `Can't connect ...` and does not advance the player. The click path only offers steps that already passed `can_connect`, so that branch is defensive.

### End of the game

At the start of each frame, an empty `available_moves()` list means the player who would have to move loses. No score, no restart prompt. Space and `0` still work.

## Code map

```text
prototype/main.py                     pygame_main() -> Game.mainloop(); text main() commented out
prototype/src/logic/ui/menus.py       window, dormant menus, input, win/loss banner
prototype/src/logic/core/board.py     grid, ends, legal moves, crossing, draw, flush, auto-play
prototype/src/logic/core/objects.py   Node and Connection, connect rules, dot and scribble drawing
prototype/src/logic/core/utils.py     Point, Connectivity, NodeVisual, flatten, a second PlayerVisual
prototype/src/const/colors.py         GameColors
prototype/src/const/symbols.py        dot and direction glyphs
prototype/assets/stains/s1.png–s15.png   wall blots, all loaded
prototype/assets/grid.jpg             loaded, never blitted
```

`PlayerVisual` is declared twice, once in `board.py` and once in `utils.py`. The window constructs the `utils` version. `Board`'s default pair constructs the `board.py` version. Fields match, so either object works as a player.

## Behaviors to keep out of the mechanic note

These are in the running prototype. They read as accidents of the draft, and a mechanic write-up should call them out if it keeps them.

- **Shared neighbor always grows the head.** When one empty dot is adjacent to both ends, `available_moves` lists the head step first and `pick_next_by_mouse` returns the first hit. A click cannot grow the tail into that dot. Verified: head `(1,2)`, tail `(1,1)`, click on `(0,2)` returned the head's `LEFT` step.
- **Auto-play is head-greedy.** `0` does not sample the full legal set.
- **Space shifts the seating.** `flush` passes the live `itertools.cycle` into the new board, and the new board immediately pulls one `next`. With Shuri to move, the new board opened on Steve, then Chen, Pylyp, Shuri.
- **Negative neighbor indexes.** `possible_connections` keeps any neighbor with `x < width` and `y < height`, including negatives. Python then indexes the row from the end. On 4×4 the wrapped dot is farther than one king-move, so `can_connect` rejects it. On 2×2 the wrap duplicates real neighbors (8 raw steps instead of 3 unique ones). `available_moves` dedupes them; `random_simulation` uses the raw list and would be biased.
- **Dot color is the last touch, segment color is the drawer.** Easy to misread in a screenshot.
- **Head and tail rings look the same** once both have segments. The black ring exists only for the untouched anchor.
- **Loss does not end the loop**, and `PlayerVisual.lost` stays false.
- **`get_hovered_node` is wrong if called.** `Node.hovered` is a property, and `get_hovered_node` calls it as `node.hovered(mouse_pos)`. That raises `TypeError`. Nothing in the loop calls it. The property reads `pygame.mouse.get_pos()` itself.
- **Text dump prints the last segment's direction on an occupied dot**, not the dot glyph, because `display_as_text` prints `node.connections[-1]` when the list is non-empty.

## Dormant or unused

- Main menu and "Action Phase" menu, including a commented name field. `buld_main_menu` is the spelling in the source. `is_ap` is only flipped by menu callbacks that never run.
- `player_controller = None`.
- `draw_game_bounds`, the `grid.jpg` blit, chalk-white paper fill, wall cutout polygons.
- `BoardSymbol.Node.H_GREEN` and `H_RED`.
- `Connection` and `Node` subclass `pygame.sprite.Sprite` and are never added to a group. Drawing is manual.
- Commented move-list debug in the loop refers to `avaialable_moves`, which is not a method.

## Layout of a turn in code

```text
MOUSEBUTTONDOWN
  -> Board.pick_next_by_mouse
       -> available_moves (head list, then tail list)
       -> first end-dot whose screen center is within NODE_RADIUS + HOVER_HIT_RADIUS
  -> from_head: connect_head
     from_tail: connect_tail
  -> Node.connect
  -> current_player = next(players)
draw
  paper, then segments, then dots, then future-target rings
```

That loop, plus the four frames in `idea/frames/`, is the whole prototype a later mechanic note can stand on.
