---
name: launch-web
description: Launch the Flutter app in the user's own browser so they can look at and play it. Use when the user asks to "run the app", "launch the browser app" or "open it for me". For checking a change yourself (headless, screenshots), use verify-web instead.
---

# launch-web

Serve the app on a fixed local port and open it in the user's default browser. The server keeps running in the background with hot reload, so the page stays usable after the command returns.

## Why not `flutter run -d chrome`

Started from a background shell it opens Chrome, then prints `Application finished` and exits within seconds (no stdin, and closing the window ends the session). The `web-server` device has no window of its own and does not exit, so use that.

## Steps

1. Drop any old server first. Never reuse one: a server left over from an earlier session or turn can serve stale code, and a `200` from the port does not tell you which build it is. Never start on another port to dodge it either, since that leaves stale servers piling up. In PowerShell, find the listener on the port, confirm it is this app's Flutter dev server (not some other program), then stop it:
   ```powershell
   $listener = Get-NetTCPConnection -LocalPort 8123 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
   if ($listener) {
     $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($listener.OwningProcess)"
     if ($proc.CommandLine -match 'run -d web-server') { Stop-Process -Id $proc.ProcessId -Force; "stopped old server $($proc.ProcessId)" }
     else { "port 8123 is held by $($proc.Name), not a Flutter dev server: stop here and ask the user" }
   }
   ```
   Also stop a server of this skill's own from earlier in the session (TaskStop on its background task) so its wrapper does not linger. If the stop is refused by a permission check, do not look for a way around it: tell the user and let them decide.
2. Check the port is now free: `curl -s -o /dev/null -w "%{http_code}" http://localhost:8123/` must print `000`. Anything else means something still holds it, so go back to step 1.
3. Start the server with Bash `run_in_background: true`:
   `cd app && flutter run -d web-server --web-port 8123 --web-hostname localhost`
4. Wait until it answers (first build takes about 30 to 60 s). Port 8123 was free in step 2, so a `200` now is this server:
   `for i in $(seq 1 50); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8123/)" = 200 ] && echo ready && break; sleep 3; done`
   If the background task reports it exited (for example `Failed to bind`), the server did not start: read its output file and fix that, don't open the browser.
5. Open it for the user (PowerShell): `Start-Process "http://localhost:8123"`
6. Tell the user the URL, and that it is a debug build: the first load compiles in the browser and takes a few seconds.

## While it runs

- After editing `app/lib`, hot restart picks changes up, but the process is backgrounded with no stdin, so you cannot press `r`. Repeat from step 1, which drops the running server and starts a fresh one, or tell the user to refresh only after a restart.
- To stop: TaskStop on the background task. Do not leave it running at the end of a session without telling the user.
- Settings persist in the browser's local storage for `localhost:8123`; use a private window for first-run behaviour.
- Mobile layout: the app is portrait-only, so tell the user to narrow the window or use browser device emulation (F12, then Ctrl+Shift+M).
