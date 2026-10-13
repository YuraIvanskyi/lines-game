# iPhone checks

The test device is the owner's **iPhone 16 Pro**. Portrait layout is 402×874 points, with a Dynamic Island at the top, a home indicator at the bottom, and USB-C. Dart tests run on the Windows workspace. There is no Mac, so nothing here can compile or simulate iOS locally.

## How a build gets onto the phone

1. **Compile.** GitHub Actions on a `macos-latest` runner for `YuraIvanskyi/lines-game` builds an unsigned `.ipa` and stores it as a workflow artifact. The workflow is manual plus the Phase 0 branch, not every push. macOS minutes are the scarce part, and on a private repo they are billed at a higher rate.
2. **Install.** On Windows, [Sideloadly](https://sideloadly.io/) re-signs that artifact with the owner's free Apple ID and copies it to the 16 Pro over USB-C. The Apple ID and password stay on that PC. They are not written into the repo, the idea notes, or Actions secrets.
3. **First launch.** The phone needs Developer Mode (Settings → Privacy & Security), and the app must be trusted under Settings → General → VPN & Device Management.

A free Apple ID signature lasts about seven days and allows a few sideloaded apps. When the app stops opening, run the workflow again and reinstall. A paid Apple Developer account plus TestFlight removes the weekly expiry and the cable. That upgrade is optional until a ticket asks for other testers or the App Store.

The iOS version string is copied from the phone the first time this install succeeds. It is not guessed here.

On 2026-10-13 the owner deferred this install. Tickets keep their phone sections, and the board does not wait on them. Chrome covers the flow until a build is installed.

## Who checks what

| Check | Where |
| --- | --- |
| Rules, move log, widget tests that do not need a finger | Windows, `dart test` / `flutter test` |
| Click through a game before an iOS artifact exists | Chrome on this PC (`flutter run -d chrome` in `app/`). Visual Studio is not installed, so the Windows desktop build is not available. |
| Portrait lock, safe area, 8×8 hit targets | iPhone |
| A full hot-seat game, pass-the-phone, sound, haptics | iPhone |
| Kill and reopen mid-game | iPhone |

When a ticket has an **On the iPhone** section, the board stays `blocked` with reason `iPhone check` once the code and automated tests are in. It becomes `done` when the owner confirms that section. A phase whose exit names the phone stays open until those checks are confirmed.

## What to try on the phone

**Phase 0.** The placeholder opens in portrait. Nothing sits under the status bar or the home indicator.

**Phase 2.** Play a 2-player classic game to a loss. Targets are easy to hit with a thumb. Head and tail stay distinct. Rematch starts a new deal.

**Phase 3.** From a cold launch, Play then a first move is two taps. The turn cue is readable at arm's length when the phone is handed over. The next player can move without an extra confirm.

**Phase 5.** A growth is audible and haptic. An illegal tap does not feel like a success. A turn still reads in about a second.

**Phase 7.** Force-quit mid-game, reopen, and the same line is there. Discard drops it. A finished game does not accept more growth.
