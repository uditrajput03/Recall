# Recall

A lightweight macOS menu bar clipboard manager inspired by CopyClip, with support for text and screenshots.

## Features

- **Text & Screenshots**: Captures copied text and screenshots automatically.
- **Image Previews**: Shows resolution metadata and thumbnails for copied images.
- **Pinning**: Hold `Option` and click any clip to pin it so it isn't pruned when history fills up.
- **Configurable Limits**: Set how many items to remember and display in Preferences (`Cmd + ,`).
- **In-Memory History**: Clips are stored only in memory and reset when the app quits.
- **Menu Bar Only**: Runs in the background without cluttering the Dock (`LSUIElement`).

## Installation

Download the latest `.dmg` or `.zip` from the [Releases](https://github.com/uditrajput03/Recall/releases) page, or build from source.

## Building from Source

Requires macOS 12+ and Swift 5.8+ (Xcode 14+).

### Build App Bundle
```bash
./build_app.sh
open Recall.app
```

To build and package release artifacts (`.dmg` and `.zip`):
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

- Click the menu bar icon to view recent clippings.
- **Copy**: Click any clipping to copy it back to your pasteboard (moves it to the top).
- **Pin / Unpin**: Hold `Option` while clicking an item.
- **Preferences**: Press `Cmd + ,` or select **Preferences…**.
- **Clear History**: Click **Clear Unpinned History** (pinned clippings remain saved).
- **Quit**: Select **Quit** or press `Cmd + Q`.
