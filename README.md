# codex-theme-controller

Native macOS SwiftUI app for managing themes in running Codex instances.

## What & Why

The app discovers running `Codex` processes and applies color themes via CDP (Chrome DevTools Protocol) — no manual PID/port lookup required.
It provides a menu bar (tray) icon and a standalone controller window.

## Features

- Scan running Codex instances (`PID`, command, `--remote-debugging-port`).
- Menu bar icon with quick actions: open window, refresh, apply to all, launch.
- Themes: `Darcula`, `Dracula`, `Nord`, `Monokai`.
- Selecting a theme immediately applies it to all running injectable Codex instances.
- Batch apply via `Apply to All`.
- Launch a new Codex instance with a specified debug port — the selected theme is applied automatically after launch.
- Last selected theme is persisted and restored on next app launch.

## Requirements

- macOS 14+
- Xcode 16+ / Swift 6+
- To apply a theme, a Codex instance must be started with `--remote-debugging-port=<port>`.

## Running

```bash
make run-app
```

`make run-app` builds the `.app` bundle and opens it via `open`, so the app behaves as a regular macOS application (Dock icon + tray icon).
Closing the window does not terminate the process — it stays active in the tray. Reopen the window from the `Open Window` menu item.
Clicking the Dock icon always brings the window to focus. To quit: use `Quit` in the tray menu or `Cmd+Q`.

## Testing

```bash
swift test
swift build
```
