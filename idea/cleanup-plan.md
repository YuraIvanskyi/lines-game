# Cleanup plan

Status: **pending**. Written 2026-10-28 after a review of `idea/`, the board, CI and the code. Nothing here has been done yet.

The docs describe the original planning pass. The app has moved past them. The board's statuses are mostly right, but the specs behind them no longer match what was built.

## Contradictions between docs and code

| # | Where | What is wrong |
| --- | --- | --- |
| 1 | `decisions.md` L3, `plan.md`, `port-patterns.md`, tickets 003, 008, 009, 014, 015 | Say the field is 8×8. Code, `classic_test.dart` and `pubspec.yaml` use 6×6 (commit "Grid 6x6"). No decision records the change. |
| 2 | `plan.md` Phase 3, `decisions.md` P8, LG-012 | "Cold start to a game in two taps", with a secondary Players path. PLAY is now one tap. Player count and names live in GAME MODE and persist. |
| 3 | `decisions.md` P3 | First hot-seat screen offers 2, 3 or 4 players. That screen no longer exists. |
| 4 | LG-019 | Asks to prefill the last names and count. `GameSetup` already does. Ticket is `backlog`. Only the results list is still open. |
| 5 | LG-013 | Says "English only" and "skip on first launch". The app is English and Ukrainian and has no first-launch flow. |
| 6 | `art-direction.md` | Excludes glossy panels and lists a smaller token set. The shipped kit is glossy arcade buttons. Tokens in code but not in the note: `mute`, `blueDeep`, `greenDeep`, the pink set. |
| 7 | `BOARD.md` | Header says "Active phase 6", but LG-017 is `backlog`, not `ready`, against `tickets/README.md`. Its real blocker, no Android SDK, is not recorded as `blocked`. |
| 8 | `ios-device.md`, `BOARD.md`, `plan.md` | Tickets with an "On the iPhone" section should stay `blocked (iPhone check)` until the owner confirms. The phone was deferred on 2026-10-13, yet LG-002, 009, 010, 011, 012, 013 and 016 are `done`. Phase gates 0, 2, 3 and 5 name the phone, so those phases never closed. |
| 9 | `plan.md` end, `tech-proposal.md` Gate, LG-001, `idea/README.md` | "Active phase starts as none until the proposal is accepted". It was accepted in practice, and nothing says so. |
| 10 | `ios-device.md` | Says to click through with `flutter run -d chrome`. The `launch-web` and `verify-web` skills say that is the wrong tool. |

## Structural mess

- **Two iOS CI configs.** `.github/workflows/ios.yml` and `codemagic.yaml` do the same job. L8 names only GitHub Actions.
- **Stub files.** `app/README.md` is the Flutter template. There is no root README. `lines-icon.jpg` and `lines-logo.jpg` sit loose at the root, referenced by nothing.
- **Dangling references.** `idea/classic-mode.md`, `monetization.md` (LG-020) and `online.md` (LG-021) are named but do not exist. `idea/README.md` and `decisions.md` say `classic-mode.md` would override `decisions.md`.
- **Naming drift.** "ENDS" (app title), `lines_game` (repo, package), `lines-game` (CI repo name), "Litterally Pen Game" (prototype).
- **Untracked work.** No tickets for settings, language, info and legal pages, sound toggle, restart, GAME MODE, `web-verify` tooling, or the skills.
- **Proposed rows never settled.** P1 to P8 in `decisions.md` are all implemented but still "Proposed".

## Steps

1. **Decide 6×6 or 8×8** (owner's call). Add a locked row L10 and update every 8×8 mention in docs and tickets, or revert the grid.
2. **Promote P1 to P8 to Locked** in `decisions.md`, with P3 and P8 rewritten for the current flow (one tap, GAME MODE, persisted setup).
3. **Add tickets for the shipped work**, marked `done`:
   - LG-022 Settings and language
   - LG-023 Info and legal
   - LG-024 Game mode
   - LG-025 Web verify tooling

   Edit LG-012, 013 and 019 to match reality, and cut the done half of LG-019.
4. **Fix the board.** Correct the active-phase line. Mark the "On the iPhone" tickets `blocked (iPhone check)`, or record a decision that web verification stands in for the phone until a build is installed. Set LG-017 to `blocked` with the missing Android SDK as the reason.
5. **Refresh `art-direction.md`** to the arcade kit and the full token list, or declare `ink_theme.dart` the source of truth.
6. **Pick one CI.** Keep the GitHub workflow and delete `codemagic.yaml`, or record why Codemagic won. Update L8 and LG-001 to match.
7. **Tidy the root and docs.**
   - Replace `app/README.md` with a few real lines (run, test, verify-web).
   - Add a short root `README.md` pointing at `idea/`.
   - Move or reference the loose root images.
   - Point `ios-device.md` at the launch-web and verify-web skills.
   - Drop the `classic-mode.md` override rule.
   - Record that the tech proposal is accepted.
8. **Decide the product name** (ENDS vs lines_game). Put it in `decisions.md` and rename only what is cheap.

Steps 2 to 8 are one docs-only commit (`idea/`, READMEs, CI). Step 1 blocks the rest of the doc edits that touch the grid size.
