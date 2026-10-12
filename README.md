# Recall 📎

A native, lightweight macOS clipboard manager built with Swift and AppKit. Inspired by **CopyClip**, with first-class support for **screenshots & images**.

![macOS 12+](https://img.shields.io/badge/macOS-12%2B-blue)
![Swift 5.8+](https://img.shields.io/badge/Swift-5.8%2B-orange)
![Pure Native](https://img.shields.io/badge/UI-AppKit%20%26%20NSMenu-green)

---

## ✨ Features

- **Text & Screenshot Support**: Automatically captures copied text and screenshots (e.g. `Cmd + Ctrl + Shift + 4`).
- **Retina Image Thumbnails**: Renders square 36×36 thumbnails with rounded corners and resolution metadata (`📷 1920×1080 • 12:30 PM`).
- **Classic CopyClip Menu Bar Dropdown**: Lives directly in your macOS menu bar with zero window clutter.
- **Light Paperclip Icon**: Elegant, slim **Light** weight paperclip SF Symbol (`.light`).
- **Direct Copying**: Click any item to copy it back to your pasteboard.
- **Clean List Display**: Uncluttered clip items without number prefixes.
- **📌 Pin / Unpin Favorites**: Hold `⌥ Option` while clicking any item to pin it so it never gets pruned.
- **⚙️ Preferences Popup**: Lightweight popup settings window matching CopyClip's design:
  - `Remember: [ 100 ] clippings`
  - `Display:  [ 30 ] clippings`
- **In-Memory Storage**: Zero disk clutter; history clears automatically when you restart.
- **Capacity Management**: Configurable history depth with automatic FIFO eviction for unpinned items.
- **Native Menubar Agent**: Configured with `LSUIElement = true` (no Dock icon).

---

## 🚀 Quick Start

### Build and Launch via Script
```bash
./build_app.sh
open Recall.app
```

### Or Run via Swift CLI
```bash
swift run Recall
```

### Running Tests
```bash
swift test
```

---

## ⌨️ How to Use

1. Click the 📎 icon in your macOS top menu bar.
2. **Copy a Clip**: Click any clip to copy it to clipboard.
3. **Pin a Clip**: Hold `⌥ Option` and click the clip (the title will switch to `📌 Pin: ...`).
4. **Open Preferences**: Press `Cmd + ,` or click `Preferences…` to configure `Remember` and `Display` limits.
5. **Clear History**: Click `Clear Unpinned History` (pinned clips are preserved).
6. **Quit**: Press `Cmd + Q` or select `Quit`.
