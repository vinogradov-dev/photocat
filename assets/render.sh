#!/usr/bin/env bash
# Render the PNGs of `assets/` from the SVG sources (M26.21, ADR 0052).
#
# The SVG files carry their colours as CSS variables, so one drawing serves both themes. Neither
# renderer in use reads `var()`, so this script substitutes the variables with a palette and then
# rasterises. Run it after any edit of an SVG; the PNGs are committed, and nothing renders them at
# build time — the binary embeds exactly two files (the window icon and the mark of the top bar).
#
#   assets/render.sh                 # into assets/
#   assets/render.sh /tmp/out        # somewhere else (a look, not a commit)
#
# Needs `rsvg-convert` (librsvg) or `resvg`; the first one found wins. `inkscape` is not used: it
# rewrites the file it is given.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
out=${1:-$here}
mkdir -p "$out"

# The palettes are the ones the window uses (src/app.rs, DARK and LIGHT): the mark of a package,
# of a README or of a print is the same amber the interface paints.
dark_mark='#f59e0b'
dark_paper='#111111'
dark_word='#e7e8ee'
dark_band='#222327'
light_mark='#b45309'
light_paper='#f1f5f9'
light_word='#0f172a'
light_band='#f1f5f9'

mark_svg=$here/photocat-mark.svg
lockup_svg=$here/photocat-lockup.svg
social_svg=$here/photocat-social.svg
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

render() { # render <svg> <width> <height> <mark> <paper|band> <word> <file> [stroke]
    local svg=$1 w=$2 h=$3 mark=$4 ground=$5 word=$6 file=$7 stroke=${8:-0}
    # The `:root` and `@media` blocks are dropped with the rest of `<style>`: what is left is one
    # flat file a renderer can read. `--` never appears in it, so sed is safe here.
    sed -e '/<style>/,/<\/style>/d' "$svg" \
        | sed -e "s|var(--photocat-mark, [^)]*)|$mark|g" \
              -e "s|var(--photocat-paper, [^)]*)|$ground|g" \
              -e "s|var(--photocat-band, [^)]*)|$ground|g" \
              -e "s|var(--photocat-word, [^)]*)|$word|g" > "$tmp/render.svg"
    # A hair of stroke for the sizes where the drawing's own lines are under a pixel: at 24 px a
    # 1.2-unit line of a 32-unit drawing is 0.9 px, and the antialiasing washes the ink out.
    if [ "$stroke" != 0 ]; then
        sed -i -e "s|<path id=\"mark\"|<path id=\"mark\" stroke=\"$mark\" stroke-width=\"$stroke\"|" \
               -e "s|<g id=\"blades\"|<g id=\"blades\" stroke=\"$mark\" stroke-width=\"$stroke\"|" \
               "$tmp/render.svg"
    fi
    local size=(-w "$w")
    [ -n "$h" ] && size=(-w "$w" -h "$h")
    if command -v rsvg-convert >/dev/null; then
        rsvg-convert "${size[@]}" -o "$file" "$tmp/render.svg"
    elif command -v resvg >/dev/null; then
        resvg "${size[@]}" "$tmp/render.svg" "$file"
    else
        echo "no SVG renderer: install librsvg (rsvg-convert) or resvg" >&2
        exit 1
    fi
    echo "  $(basename "$file")  ${w}x${h:-auto}"
}

echo "the mark, for the program:"
# The top bar: white ink on transparency. It is drawn at `BRAND_MARK` (24 logical px) but rendered
# at twice that, so a HiDPI screen gets real pixels instead of an upscaled 24 px texture. The window
# paints it with `Image::tint`, so this one file is right in both themes and in any future one.
render "$mark_svg" 48 48 '#ffffff' transparent '' "$out/photocat-mark-48.png" 0.25
# The window icon and the packages: the mark on its plate, so the dock shows the same thing on a
# light desktop as on a dark one. hicolor wants 32/64/128/256.
for size in 32 64 128 256; do
    render "$mark_svg" "$size" "$size" "$dark_mark" "$dark_paper" '' "$out/photocat-icon-$size.png"
done
# A store page, a press kit, a print: 1024 px of the same drawing.
render "$mark_svg" 1024 1024 "$dark_mark" "$dark_paper" '' "$out/photocat-1024.png"

echo "the lockup, for the READMEs:"
# 800 px is the width the README shows it at, and the viewBox is 800 by 220 already: the file is
# rendered at its own size, so nothing is downscaled and the ink stays where it was framed — equal
# air on all four sides. The height follows the viewBox; it is never passed here, because a width and
# a height that disagree with the aspect ratio stretch the drawing.
for theme in dark light; do
    mark=$dark_mark; ground=$dark_band; word=$dark_word
    if [ "$theme" = light ]; then mark=$light_mark; ground=$light_band; word=$light_word; fi
    suffix=''
    [ "$theme" = light ] && suffix='-light'
    render "$lockup_svg" 800 '' "$mark" "$ground" "$word" "$out/photocat-lockup$suffix.png"
done

echo "the social preview, for a link card:"
# 1280 by 640 is the size GitHub asks for a repository's social preview and the size a card is drawn
# at by Telegram, Slack, Discord, Reddit and X, so nothing is downscaled on the way. The plate is the
# dark band in both themes: a card is shown beside text whose colour nobody knows, and a dark plate
# keeps the amber mark readable on a white page. Width and height are both passed, and they agree
# with the viewBox's 2:1, so the drawing is not stretched.
render "$social_svg" 1280 640 "$dark_mark" "$dark_band" "$dark_word" "$out/photocat-social.png"
