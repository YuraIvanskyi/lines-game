# Plan

Classic hot-seat on an iPhone, played offline, with an 8×8 field and the prototype's line rules. The build is one Flutter app ([tech-proposal.md](tech-proposal.md)). Android, cosmetics, extra modes, and online play are later phases of that same app.

The Pygame project is the reference for rules. It is not the UI to port.

## Player path the phases are aiming at

1. Open the app and tap Play. Two players, classic 8×8, no account.
2. Optional: set 3 or 4 players and names before the deal.
3. See whose turn it is, see the two ends, see the dots that can grow.
4. Tap a dot. If both ends can reach it, pick the end. The ink draws, then the phone is passed.
5. When someone has no growth, the game stops, names them, and offers rematch or home.

A shorter board, extra rule twists, and a shop are future modes and skins. They are not slipped into classic to make games faster.

## Phases

Work is sequential. A phase opens when the previous phase's exit is true. Tickets inside an open phase can proceed as soon as their own dependencies on the board are done.

| Phase | Name | Exit |
| --- | --- | --- |
| 0 | Phone shell | The placeholder runs on the owner's iPhone 16 Pro, installed from a GitHub Actions artifact via Sideloadly. `packages/rules` tests pass on the Windows machine. The prototype still launches separately. |
| 1 | Classic rules | Dart tests cover an 8×8 deal, legal growth, crossing, walls, turn order, chosen end, loss, and log replay. No phone required. |
| 2 | Table | On the iPhone, a full hot-seat classic game can be tapped through to game over and a rematch. |
| 3 | Pickup | On the iPhone, cold start reaches that table in two taps. Player count, names, a single how-to, and the pass-the-phone beat are in the flow. |
| 4 | Mode seam | Classic is a mode record (8×8, wall chance 0.05, this rule set). Starting a game asks for a mode id. Only classic is listed. |
| 5 | Feel | On the iPhone, ink, ends, targets, pass, and game over move, sound, and haptic like a finished toy. Colors come from theme tokens. |
| 6 | Android | The same classic flow completes on an Android emulator or device. |
| 7 | On-device memory | On the iPhone, force-quit restores an unfinished match. Local names and results survive a restart. |
| 8 | Cosmetics spike | A second skin can be selected locally. Nothing is purchased. A short note records what would be sold and what would not. |
| 9 | Online note | A ticket describes how a remote opponent would append to the same log. No network code. |

## Phase 0 — Phone shell

Prove the accepted stack boots on the owner's iPhone 16 Pro ([ios-device.md](ios-device.md)). Leave the prototype where it is. Dart tests stay on Windows. GitHub Actions compiles the unsigned iOS build. Sideloadly installs it.

Tickets: LG-001, LG-002.

Not in this phase: rules, art, Android polish, accounts.

## Phase 1 — Classic rules

`packages/rules` owns the match. A match value plus a move returns a new match. Deals take an explicit seed. The move log is enough to rebuild the board (L2, L3, P1–P4, P7). The shape of that value is [port-patterns.md](port-patterns.md) (L9): bit grids, cell indexes, segment keys. It is not a translation of the Pygame classes.

Tickets: LG-003 through LG-008.

Not in this phase: pixels, fonts, haptics, the four prototype names as hardcoded players.

## Phase 2 — Table

The iPhone shows one match and accepts taps. Head and tail look different (P5). Segment ink stays put (P6). Game over stops play (P7). The painter follows [port-patterns.md](port-patterns.md): it draws a snapshot, caches hit targets and committed ink, and does not run a 120 Hz scene loop. Automated tests can run without the phone. The phase closes when the phone play in [ios-device.md](ios-device.md) is confirmed.

Tickets: LG-009, LG-010, LG-011.

Not in this phase: home screen, tutorial copy, final art.

## Phase 3 — Pickup

The shell around the table. Two taps from launch to a 2-player classic game (P3, P8). Three and four players are a deliberate choice, not the default.

Tickets: LG-012, LG-013.

Not in this phase: stats, accounts, more modes.

## Phase 4 — Mode seam

Extract the classic numbers into a mode definition before the art pass hardcodes them. The rules package can be given a mode. The home screen has one entry.

Tickets: LG-014.

Not in this phase: a second playable mode.

## Phase 5 — Feel

Motion, sound, and haptics on the flow that already exists, judged on the iPhone. Target: a stranger can see a legal move without reading, and a turn reads in about a second. Theme tokens are the only colors the board uses, so Phase 8 can swap them.

Tickets: LG-015, LG-016.

Not in this phase: a store, ads, or replacing rules to shorten the 8×8 game.

## Phase 6 — Android

Same Dart, Android build. Fix shell issues only (back gesture, safe area, haptics). Rules bugs found here get rules-package fixes, not an Android fork.

Tickets: LG-017.

## Phase 7 — On-device memory

Persist the current log and the last names on the iPhone. Force-quit resumes or discards explicitly. A local result list is enough. No server.

Tickets: LG-018, LG-019.

## Phase 8 — Cosmetics spike

Explore monetization by building the hook, not the cash register. One alternate skin, selected in settings, stored locally. Write down the sellable surface: skins, ink sets, flourishes. Classic rules stay free and complete offline (L6).

Tickets: LG-020.

Not in this phase: StoreKit, Play Billing, ads, accounts, prices.

## Phase 9 — Online note

Record the contract a future transport must meet: clients submit a growth, the rules package accepts or rejects it, the canonical log is the match. Hot-seat remains the reference implementation.

Tickets: LG-021.

Not in this phase: backend, matchmaking, accounts.

## How an agent takes work

1. Confirm [tech-proposal.md](tech-proposal.md) is accepted. If it is not, do not create `app/` or `packages/`.
2. Open [tickets/BOARD.md](tickets/BOARD.md). Work the active phase only.
3. Take the lowest-id ticket in that phase whose dependencies are `done`.
4. Read [decisions.md](decisions.md) and the ticket. Implement that ticket. Leave neighboring tickets alone.
5. Update the board status. A ticket with an **On the iPhone** section stays `blocked` (`iPhone check`) until the owner confirms it, then `done`.

The active phase starts as **none**. It becomes **0** when the tech proposal is accepted. Phone checks are listed in [ios-device.md](ios-device.md).
