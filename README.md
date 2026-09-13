# Keeper

A small macOS app for culling a Fuji shoot. Open a folder, step through each photo with a QuickLook preview, then tag it with a colour, flag it for deletion, or skip it. Each JPG and RAF with the same name are treated as one photo.

**Keeper never deletes anything.** Rejected files are moved to `<folder>/delete/` after you review a summary.

## Build

```bash
make app        # builds Keeper.app in the repo root
open Keeper.app
make test       # move-plan tests
make icon       # redraws Resources/AppIcon.icns from Resources/make-icon.swift
```

Requires Xcode (Swift 5.10+) and macOS 14+. The UI uses Space Mono if it's installed.

## Keys

| Key | Action |
|---|---|
| `←` `→` | Previous / next |
| `1` `2` `3` `4` | Tag red / yellow / green / blue (toggles) |
| `D` | Flag for delete (toggles) |
| `S` / `Space` | Skip (clears any mark) |
| `⌘↩` | Review and move |
| `⌘O` | Open folder |

## Rules

- **Tagged** photos keep the JPG and the RAF. The Finder tag is written to both files straight away.
- **Flagged** photos move both the JPG and the RAF to `delete/`.
- **Untagged** photos keep the JPG. The RAF moves to `delete/` unless you pick **JPG + RAF** on the summary screen. A RAF with no JPG is always kept.
