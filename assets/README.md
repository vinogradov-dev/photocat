# assets

The face of the program: the mark (a cat head built from a stack of photo frames, an aperture for an
eye) and its lockup — the mark with the word `photocat` beside it. ADR 0052 explains why the mark is
an asset while every icon inside the window stays drawn geometry, and why it is distributed under the
same Apache-2.0 as the code.

## Sources

| File | What it is |
|---|---|
| `photocat-mark.svg` | the mark, 32×32 units, **the source of every raster below** |
| `photocat-lockup.svg` | the mark and the word side by side — native 800×220, the ink (758.4×182.3) framed with equal air on all four sides |
| `photocat-social.svg` | the same lockup on a 1280×640 plate — a link card, not a second drawing: one group maps the lockup's 800×220 onto 960×264 in the middle of the plate |

Both are the owner's drawings, kept verbatim: the paths were not redrawn, only re-wrapped. The colours
are CSS variables, so one file serves both themes:

| Variable | What it paints | Dark | Light |
|---|---|---|---|
| `photocat-mark` | the ink of the mark | `#f59e0b` | `#b45309` |
| `photocat-paper` | the plate, and the frame's inner field and the lens through the plate | `#111111` | `#f1f5f9` |
| `photocat-word` | the word of the lockup | `#e7e8ee` | `#0f172a` |
| `photocat-band` | the ground strip of the lockup | `#222327` | `#f1f5f9` |

`transparent` in place of a colour is meaningful for `photocat-paper` and `photocat-band`: the plate or
the strip disappears and the mark is left as a cut-out. The frame's inner field and the lens are a
`<mask>`, not dark shapes over the ink, so that a cut-out really has holes in it.

The dark values are the window's `DARK` palette, the light ones its `LIGHT` palette (`src/app.rs`), so
the logo, the icons of a package and the interface are the same colour. A browser follows the system
theme by itself (`@media (prefers-color-scheme: light)`); the renderers used below do not read `var()`,
which is why the script substitutes the values first.

## Rasters — generated, never hand-edited

```bash
assets/render.sh                # rewrites the PNGs in assets/
assets/render.sh /tmp/look      # a look somewhere else
```

Needs `rsvg-convert` (librsvg) or `resvg`. The PNGs are committed, because nothing renders SVG at
build time: the binary embeds exactly two files, and a compositor or a package reads the rest.

| File | Size | Ink and ground | Who reads it |
|---|---|---|---|
| `photocat-mark-48.png` | 48×48 | white on transparency, a hair of stroke (`0.25`) because a 1.2-unit line is 0.9 px at the size it is drawn | the top bar: embedded, drawn at 24 logical px (`BRAND_MARK`) and **tinted** with the accent of the theme, so one file is right in both themes |
| `photocat-icon-32.png` … `-256.png` | 32, 64, 128, 256 | amber on the plate | the window icon (the 256 px one is embedded) and `hicolor/<size>/apps` of a package — the plate keeps the mark visible on a light desktop |
| `photocat-1024.png` | 1024×1024 | amber on the plate | a store page, a press kit, a print |
| `photocat-lockup.png` | 800×220 | dark band, light word | the README in a dark theme |
| `photocat-lockup-light.png` | 800×220 | light band, dark word | the README in a light theme |
| `photocat-social.png` | 1280×640 | dark band, light word | GitHub's *Settings → General → Social preview* and a link card in Telegram, Slack, Discord, Reddit or X: the size those cards want, uploaded by hand once, because no API sets it |

The two lockups are chosen by the reader's theme with `<picture>` + `prefers-color-scheme`, so a
single README is legible on GitHub's dark and light pages. Their canvas *is* the size the README shows
them at (800 px), so nothing is downscaled and the air around the ink stays equal: 21 px left and
right, 19 px above and below. `render.sh` passes the width only — a width and a height that disagree
with the viewBox stretch the drawing, which is how the first lockup ended up cropped and off-centre.

## Changing something

- **A size**: a line in `render.sh` (`render "$mark_svg" 64 64 …`). A new size is a file, not a script
  at build time — the binary embeds one PNG and a missing asset costs the icon, not the window.
- **A colour**: the palette at the top of `render.sh` and the `<style>` block of the SVG — both, or a
  browser and the program disagree.
- **The drawing**: the owner's file. Re-export it and run `render.sh`: the wrapper only adds the
  `<style>`, the `<mask>` and the crop of the lockup. `photocat-social.svg` carries a copy of that
  geometry on purpose — an SVG cannot include another file — so a change to the mark or the word is
  made in `photocat-lockup.svg` and copied over; nothing else in it is drawn by hand.

## What the rasters do not do

At 16 px the drawing drowns, whatever the stroke: that size needs a filled silhouette (the head
filled, the aperture cut out), which is a new drawing and not a reduction. Nothing asks for 16 px yet;
the task that needs it (a Windows `.ico`, a favicon) says so in `plan/BACKLOG.md`.

## Rules

- The mark never appears *inside* the window as a widget or a background (ADR 0048 stays true: the
  interface is drawn geometry, and its screenshots do not depend on a bitmap). The one exception is
  the mark at the left of the top strip, which is chrome, not a screen.
- A raster is never edited by hand and never generated at build time.
