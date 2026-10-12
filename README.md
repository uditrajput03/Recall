# Recall

A lightweight macOS menu bar clipboard manager inspired by CopyClip, with support for text and screenshots.

## Features

- **Text & Screenshots**: Automatically captures copied text and screenshots.
- **Image Thumbnails**: Displays proportional thumbnails with image dimensions and timestamps.
- **Pinning**: Hold `Option` and click any clip to pin it so it won't be pruned.
- **Clear Unpinned**: Clear unpinned history while keeping pinned items.
- **Configurable Capacity**: Set limits for remembered items and display count in Preferences (`Cmd + ,`).
- **In-Memory**: History is stored in memory and resets when the app quits.
- **Menu Bar Only**: Runs as a background agent without a Dock icon (`LSUIElement`).

## Installation

Download the latest `.dmg` or `.zip` from [Releases](https://github.com/uditrajput03/Recall/releases).

### macOS Gatekeeper

If macOS blocks the app with *"Apple cannot check it for malicious software"*, remove the quarantine attribute:

```bash
xattr -cr /Applications/Recall.app
```

Alternatively, right-click (or `Control`-click) `Recall.app` in Finder and select **Open**.

## Building from Source

Requires macOS 12+ and Swift 5.8+ (Xcode 14+).

### Build App Bundle
```bash
./build_app.sh
open Recall.app
```

To package `.zip` and `.dmg` release artifacts:
```bash
./build_app.sh 1.0.0 --package
```

### Run via Swift CLI
```bash
swift run Recall
```

### Run Tests
```bash
swift test
```

## Usage

- Click the menu bar icon to view clippings.
- **Copy**: Click an item to copy it back to your clipboard and move it to the top.
- **Pin / Unpin**: Hold `Option` and click an item.
- **Preferences**: Press `Cmd + ,` or select **Preferences…**.
- **Clear**: Click **Clear** to remove unpinned clips.
- **Quit**: Press `Cmd + Q` or select **Quit**.
