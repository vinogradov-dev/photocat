<picture>
  <source media="(prefers-color-scheme: light)" srcset="assets/photocat-lockup-light.png">
  <img alt="photocat" src="assets/photocat-lockup.png" width="800">
</picture>

# photocat

A **photocatalog** for a family media archive, in Rust: a photo catalogue that indexes folders,
finds exact duplicates and near-duplicates, tags photos by content, reads the text on them (OCR)
and clusters faces — all locally; plus a date-based showcase. Originals are never modified.

*Русская версия: [README.ru.md](README.ru.md). The project page: [ruchej-dev.github.io/photocat](https://ruchej-dev.github.io/photocat/).*

What changed and when: [CHANGELOG.md](CHANGELOG.md). The mark and the window icon live in
[`assets/`](assets/) (ADR 0052).

## Screenshots

![The archive after indexing](docs/screenshots/en/main-grid.jpg)
*The archive after indexing: the month grid, the file card and the filters.*

![The full-screen viewer](docs/screenshots/en/viewer-faces.jpg)
*The full-screen viewer: face boxes, the tools row and the series of the day.*

![People](docs/screenshots/en/people.jpg)
*A named face group. Every screen is in [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md), in English and in
Russian.*

## Build

```bash
cargo build --release      # ~3 minutes from scratch
# binary: target/release/photocat
```

## Usage

```bash
# 1. Index a folder (reads files, writes the DB and previews to ~/.cache/photocat)
./target/release/photocat index ~/Pictures

# 2. Statistics
./target/release/photocat stats

# 3. Duplicates and series (threshold — Hamming distance over the 64-bit dHash)
./target/release/photocat dupes --max-dist 6
./target/release/photocat dupes --max-dist 4 --csv /tmp/dupes.csv
./target/release/photocat dupes --max-dist 6 --plan /tmp/dupes-plan.csv   # plan: what to keep

# 4. Albums: a tree and a file order — DB rows only, nothing changes on disk
./target/release/photocat albums new --name "Summer house 2024"
./target/release/photocat albums new --name "May" --parent 1
./target/release/photocat albums add --id 2 ~/Photos/IMG_0001.jpg ~/Photos/IMG_0002.jpg
./target/release/photocat albums list --tree
./target/release/photocat albums show --id 2 --tree

# 4b. Export an album as real copies: structure and order as in the album
./target/release/photocat export --album 1 --out /mnt/disk/export            # plan tree
./target/release/photocat export --album 1 --out /mnt/disk/export --apply    # copies
./target/release/photocat export --album 1 --out /mnt/disk/export --name '{n}_{date}_{orig}'

# 5. Showcase (by default a plan only: nothing is changed or renamed)
./target/release/photocat organize --out ~/Photo-showcase
./target/release/photocat organize --out ~/Photo-showcase --by month     # YYYY/YYYY-MM
./target/release/photocat organize --out ~/Photo-showcase --by event     # day + GPS place
./target/release/photocat organize --out ~/Photo-showcase --apply        # hardlink
./target/release/photocat organize --out /mnt/disk --apply --copy        # copies
./target/release/photocat organize --out ~/Photo-showcase --apply --rename # names from dates
./target/release/photocat organize --out ~/Photo-showcase --exclude-dup  # skip files marked extra
./target/release/photocat organize --out ~/Photo-showcase --name '{date}_{camera}_{orig}'

# 6. CLIP: semantic tags and search (the model is downloaded once, then everything is local)
./target/release/photocat models download --id clip-vit-b32-multilingual --yes  # network, consent
./target/release/photocat embed                        # 2229 files ≈ 177 s on CPU (two frames)
./target/release/photocat embed --refresh              # recompute vectors after the input changed
./target/release/photocat search "cake" --top 20
./target/release/photocat clusters --k 30              # → plan/M3-clusters.md

# 7. Text on documents and screenshots (needs tesseract with rus+eng packs)
./target/release/photocat ocr --dry-run
./target/release/photocat ocr
./target/release/photocat search "receipt" --text

# 8. People: detection, groups, names (model 182.4 MiB — in Settings, with consent)
./target/release/photocat faces --dry-run
./target/release/photocat faces
./target/release/photocat faces --list
./target/release/photocat faces label --id 5 --name Lisa
./target/release/photocat faces split --id 123

# 9. Integrity and backup (read-only; exit code 0 — identical, 1 — differences)
./target/release/photocat verify ~/Photos ~/backup/Photos
./target/release/photocat manifest ~/Photos --out ~/Photos.sha256
./target/release/photocat verify --manifest ~/Photos.sha256 ~/backup/Photos
# Once the interval expires (30 days by default) the GUI shows a "Time to check the archive"
# banner; the interval and the date live on the Integrity screen. The check never starts itself.

# 10. GUI
./target/release/photocat gui
./target/release/photocat gui --db /path/to/photocat.db
```

## Scheduled check (systemd, optional)

The app installs no timers and starts nothing on its own: the GUI only reminds. If a check has to
run without a human, the OS does it through the same CLI path (exit code 1 — differences found):

```ini
# ~/.config/systemd/user/photocat-verify.service
[Unit]
Description=photocat: verify photo archive against its manifest

[Service]
Type=oneshot
ExecStart=%h/bin/photocat verify --manifest %h/Photos.sha256 %h/Photos
```

```ini
# ~/.config/systemd/user/photocat-verify.timer
[Unit]
Description=Weekly photocat archive check

[Timer]
OnCalendar=weekly
Persistent=true
Unit=photocat-verify.service

[Install]
WantedBy=timers.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now photocat-verify.timer
```

## What is there

| Capability | Status |
|---|---|
| Indexing: sha256, dHash, EXIF (date, GPS, camera), dimensions, previews | ✅ |
| Date: EXIF → file name (`IMG_20240517_144243`) → mtime, with the source shown | ✅ |
| Duplicates: exact (sha256) + similar (Hamming over dHash), union-find clusters | ✅ |
| Dupes report in the console and CSV, size of the "extra" copies | ✅ |
| Advice per group: sharpness (Laplacian), resolution, size — in words; exact copies — "no difference" | ✅ |
| "Keep / extra" decision in the DB, "marked M, frees X" summary, CSV plan, no deletion | ✅ |
| Date showcase: plan/dry-run, hardlink/copy/symlink, name collision handling | ✅ |
| GUI in the PhotoPrism spirit: sidebar navigation with counts, top search bar, month groups, filter chips, file inspector, calendar, duplicate groups, tile size | ✅ |
| Full screen: double click, instant preview, slideshow, zoom, full OCR text | ✅ |
| Video: cover frame, built-in player (H.264/HEVC, AAC, sound), ffplay and the system player as fallbacks | ✅ |
| Incremental indexing: unchanged files are skipped (repeat over 2230 files — 0.02 s) | ✅ |
| Several folders, built-in folder picker, dropping a folder from the index only | ✅ |
| Console progress line | ✅ |
| CLIP embeddings (ONNX, CPU), semantic search for "cake", "sea", "document" in Russian | ✅ |
| Model catalogue: CLIP 512 (ru/en), SigLIP 768 (en); dimensions are a property of the model | ✅ |
| CLIP tags (14 hints: beach, document, food, furniture, interior, city and more) in the card and the filter | ✅ |
| Manual tags, "Compute tags" from ready vectors; several people on one photo | ✅ |
| CLIP clusters: 30 groups × 12 examples in `plan/M3-clusters.md` | ✅ |
| People: SCRFD + ArcFace, groups, manual names, "not him" for false merges | ✅ |
| OCR of documents/screenshots (tesseract), text search with highlights | ✅ |
| Video previews via ffmpeg, dHash and duration, video in duplicates and CLIP | ✅ |
| Settings: model, thresholds, paths to ffmpeg/ffprobe/tesseract with probing; `doctor` | ✅ |
| "Best frame of a series": advice by sharpness/resolution/size | ✅ |
| Comparing two archive copies (`verify`, size → sha256) and a `sha256sum` manifest (`manifest`) | ✅ |
| Check reminder by interval (`settings`, GUI banner) with no auto-start | ✅ |
| App trash and moving to the OS trash after confirmation; used space and cache cleanup | ✅ |
| Albums: a tree with sub-albums and a file order, DB data only; CLI and the "Albums" view | ✅ |
| Interface language: English (main) and Russian, chosen in Settings → Interface | ✅ mechanism; screen-by-screen coverage in `plan/I18N.md` |

## Storage

* DB: `~/.cache/photocat/photocat.db` (SQLite, WAL). The index is rebuilt by indexing; originals are
  never modified. Dupes decisions (`decision`) survive while the file keeps the same `sha256`.
* Previews: `~/.cache/photocat/thumbs/<2 chars>/<sha256>.jpg`, 320 px on the long side.
* CLIP model: `~/.cache/photocat/models/clip-vit-b32/`, 218 MiB; SigLIP — 203.5 MiB, 768 features.
  sha256 is verified on download; models are never mixed. The only network call is the weights
  download the owner asks for (the Settings button or `models download`); nothing else goes out.
* Nothing is deleted or renamed without explicit flags.

## Measurements on a real archive

* 2230 files (21.2 GiB): indexing **60.2 s** on 16 threads, DB 1.3 MB, previews 29 MB.
* 103 duplicate/series groups, 238 files, 214 MiB of "extra"; sharpness computed for every file in
  those groups.
* 2.3 M dHash comparisons — **0.03 s** (in memory, no DB).
* CLIP embeddings for 1971 photos: **66.9 s** on CPU (34 ms/photo), vectors 3.85 MiB, DB 11 MB.
  Semantic search over 20 k vectors — **48–51 ms**; a repeated `embed` — 0.025 s (skipped by sha256).

## License

photocat is licensed under the **Apache License 2.0** — see [LICENSE](LICENSE) for the full text
and [NOTICE](NOTICE) for the attribution notice. The copyright holder is
Alexander Grigoryevich Vinogradov.

Third-party models, crates and programs keep their own licenses: the CLIP and face weights are
downloaded by the owner and are not distributed with the source code; `ffmpeg`, `ffprobe` and
`tesseract` are external programs the app only calls, and the weights are fetched by the binary itself
(`ureq` + `rustls`, ADR 0047).

## Keywords

What this project is, in the words people search for: photocatalog, photocatalogue, photo catalog,
photo catalogue, photo organizer, photo archive manager, photo library, deduplication, similar
images, semantic search, CLIP, OCR, face clustering, local-first, offline, no cloud, privacy, Rust,
SQLite, egui.
