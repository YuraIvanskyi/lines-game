---
name: launch-web
description: Launch the Flutter app in the user's own browser so they can look at and play it. Use when the user asks to "run the app", "launch the browser app" or "open it for me". For checking a change yourself (headless, screenshots), use verify-web instead.
---

# launch-web

Serve the app on a fixed local port and open it in the user's default browser. The server keeps running in the background with hot reload, so the page stays usable after the command returns.

## Why not `flutter run -d chrome`

Started from a background shell it opens Chrome, then prints `Application finished` and exits within seconds (no stdin, and closing the window ends the session). The `web-server` device has no window of its own and does not exit, so use that.

## Steps

1. If a server from earlier in the session is still up, reuse it: `curl -s -o /dev/null -w "%{http_code}" http://localhost:8123/` returning `200` means skip to step 4.
2. Start the server with Bash `run_in_background: true`:
   `cd app && flutter run -d web-server --web-port 8123 --web-hostname localhost`
3. Wait until it answers (first build takes about 30 to 60 s):
   `for i in $(seq 1 50); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8123/)" = 200 ] && echo ready && break; sleep 3; done`
4. Open it for the user (PowerShell): `Start-Process "http://localhost:8123"`
5. Tell the user the URL, and that it is a debug build: the first load compiles in the browser and takes a few seconds.

## While it runs

- After editing `app/lib`, hot restart picks changes up, but the process is backgrounded with no stdin, so you cannot press `r`. Stop it (TaskStop on the background task) and repeat from step 2, or tell the user to refresh only after a restart.
- To stop: TaskStop on the background task. Do not leave it running at the end of a session without telling the user.
- Settings persist in the browser's local storage for `localhost:8123`; use a private window for first-run behaviour.
- Mobile layout: the app is portrait-only, so tell the user to narrow the window or use browser device emulation (F12, then Ctrl+Shift+M).
