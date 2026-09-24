<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Resources/AppIcon.png">
  <img src="Resources/AppIcon-light.png" width="128" alt="Keeper icon">
</picture>

# Keeper

A simple macOS app for processing photos from my Fuji camera.

Open a folder, scroll through each photo with a QuickLook preview; tag favourite photos with a colour that appears in Finder; and flag photos for deletion. Photos can also be rotated and compared side-by-side.

Each JPEG (JPG) and RAW (RAF) with the same name are treated as one photo. For photos flagged for deletion, both the JPG and RAF are moved to a `delete/` folder. For photos that are untagged, the RAF is moved to `delete/` but the JPG is kept; tagging a photo keeps both the JPG and RAF.

**Keeper never deletes anything.** "Deleted" files are simply moved to `<folder>/delete/` after you review.

## Build

```bash
make app        # builds Keeper.app in the repo root
open Keeper.app
open Keeper.app --args --open ~/Pictures/shoot   # open a folder on launch
make test       # move-plan tests
make icon       # redraws Resources/AppIcon.icns from Resources/make-icon.swift
```

Requires Xcode (Swift 5.10+) and macOS 14+. The UI uses Space Mono if it's installed.

## Keys

| Key             | Action                                                   |
| --------------- | -------------------------------------------------------- |
| `←` `→`         | Previous / next                                          |
| `1` `2` `3` `4` | Tag red / yellow / green / blue (toggles)                |
| `D`             | Flag for delete (toggles)                                |
| `S` / `Space`   | Skip (clears any mark)                                   |
| `R` / `⇧R`      | Rotate the JPG clockwise / anticlockwise                 |
| `C`             | Compare: pin this photo on the left, browse on the right |
| `X`             | Swap the pinned and current photos                       |
| `⌘↩`            | Review and move                                          |
| `⌘O`            | Open folder                                              |
| `H`             | Help                                                     |

## Rules

- **Tagged** photos keep the JPG and the RAF. The Finder tag is written to both files straight away.
- **Flagged** photos move both the JPG and the RAF to `delete/`.
- **Rotate** rewrites only the JPG's orientation flag. The image data is untouched (lossless) and the RAF is never modified.
- **Compare**: tag, delete, skip and rotate apply to the photo on the right.
- **Untagged** photos keep the JPG. The RAF moves to `delete/` unless you pick **JPG + RAF** on the summary screen. A RAF with no JPG is always kept.
