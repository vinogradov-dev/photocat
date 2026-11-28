# Changelog

*Русская версия: [CHANGELOG.ru.md](CHANGELOG.ru.md).*

All notable changes to photocat. The format follows [Keep a Changelog](https://keepachangelog.com/1.1.0/),
the versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**How this file is kept** (`AGENTS.md` §6). Every commit that changes what the owner sees, what a
command does or what appears on disk adds one line under `## [Unreleased]` in the same commit — a
short phrase, not a story — and updates `CHANGELOG.ru.md` with the same line. The milestone in
brackets (`[M26.14]`) points at the entry in `plan/STATUS.md`, where the numbers, the measurements and
the acceptance live: the changelog is the history a person reads, the status log is the record a
maintainer needs. A release takes the `[Unreleased]` section, gives it a version and a date, bumps
`version` in `Cargo.toml` and starts a new empty `[Unreleased]`.

## [Unreleased]

### Added

- This changelog, and the rule that keeps it — `AGENTS.md` §6, `plan/I18N.md` [M26.15].
- The People page keeps its thresholds behind one “Tuning” switch that shows the values and counts
  what the matching sliders would propose before a pass runs [M26.16].
- Automatic face matches wait in a quarantine until the owner confirms them: “Quarantine · N” in the
  group list, “Confirm all”, and `faces --quarantine` / `confirm` / `reject` [M26.17].
- The mark: the cat-aperture logo and its lockup in `assets/`, and the window carries the icon — the
  256 px mark on its plate, embedded in the binary, with 32/64/128 px files for packaging [M26.19].
- The mark and the lockup as SVG with the colours in CSS variables (`photocat-mark`,
  `photocat-paper`, `photocat-word`, `photocat-band`), rendered into every PNG by `assets/render.sh`,
  and the README picks the lockup that matches the reader's theme [M26.21].
- The lockup is the owner's new layout: the app's own mark beside the word, 800×220 — the size the
  README shows it at — with the ink framed by equal air and no cropping [M26.22].
- Screenshots of every screen, in English and Russian, and the gallery in `docs/SCREENSHOTS.md`
  and `docs/SCREENSHOTS.ru.md`.
- The social preview, 1280×640: the lockup on its plate as `assets/photocat-social.svg`, rendered by
  `assets/render.sh` into the PNG that GitHub's *Settings → General → Social preview* takes — the
  card a link to the repository unfolds into in Telegram, Slack, Discord, Reddit and X.

### Changed

- The top bar carries the logo itself, painted in the accent of the theme — `#b45309` on the
  light palette — instead of the drawn photo-library glyph [M26.20].
- An automatic match no longer joins a named group by itself: the step proposes a face, and a
  confirmation or a refusal is the owner's decision [M26.17].
- The duplicate settings left the left panel for the page that owns the groups: the threshold,
  “Find groups”, the summary and the plan stand above the cards [M26.18].
- The READMEs and the crate metadata name the project the way people search for it: a photocatalog,
  a photo catalogue, a photo organizer, with the search words in a section of their own.

### Fixed

- The “keep” target of a duplicate follows its word in both languages, so “оставить” stays on
  one line, and the digits at the right of a list row no longer run under it [M26.20].
- The Trash screen's header counts the files in the trash instead of showing “0 files, 0 B”.
- The duplicates header and the status bar count groups with the right plural: “1 group”
  instead of “1 groups”.

### Removed

- “Detach the auto-matched” and the `auto` mark: nothing joins a group by itself any more [M26.17].

## [0.1.0] — the first line of development, 2026-11-22 … 2026-11-27 (not released yet)

### Added

- Folder indexing: `walkdir` traversal in parallel, `sha256`, a 64-bit dHash, the EXIF date, GPS and
  camera, and a 320 px preview in the cache — nothing is written into the archive folder [M1].
- Videos are indexed with a cover frame, a dHash, a duration and a resolution through `ffmpeg` and
  `ffprobe`; both are optional and every other feature works without them [M4].
- Exact and near duplicates: `sha256` for the exact, dHash with a Hamming threshold (6 of 64 by
  default) for the similar, the "keep" / "spare" decisions in the DB and a CSV plan to review [M2, M5].
- The date showcase: a dry-run plan by default and, only with `--apply`, hardlinks, copies or symlinks
  laid out by date [M3].
- Albums as a tree with a dense file order, in the DB only, and an export of an album as numbered
  copies on disk (`{n}_{orig}`, dry run first) [M19, M20].
- A native egui window: the preview grid with month headings, the calendar, duplicates, albums,
  people, the trash, integrity and the settings dialog [M13, M16, M17, M22].
- Multiple selection of tiles with `Shift`-click and a floating selection bar [M18].
- A full-screen viewer with zoom, panning, flipping and the series of the day [M13c, M13d, M22.7].
- A built-in video player — H.264, HEVC Main, AAC, MJPEG and PCM sound, three threads, no external
  program; a codec outside the scope is refused with the reason and an external player is offered
  only by an explicit press [M14, M26.12].
- CLIP tags and semantic search, local after one consented download: a model catalogue (two CLIP
  ViT-B/32, SigLIP base 224, SigLIP 2 base 224 multilingual), a tag dictionary per model in the DB,
  a percentile threshold per tag and an explicit "not sure" state [M7, M12, M15, M15.4, M15.6].
- A labelled check (`eval`) of the tags: a reproducible sample, `labels.csv`, contact sheets and the
  top-1 / top-3 and confident-tag accuracy [M15.7].
- Text recognition with `tesseract` (optional) and a search by the recognized text [M8].
- People: SCRFD and ArcFace detection and embeddings, face groups, names that pin a group, splitting a
  face off, splitting the picked strangers at once, and the automatic match of a free face to an
  already named person under a closeness and a lead over the next person [M6, M26.10, M26.11].
- Integrity: comparing two copies of the archive, a `sha256sum` manifest, checking a folder against
  it, a GUI screen and a reminder that never starts the check by itself [M9, M10].
- Similar-shot search that stays fast above 20 thousand photos [M11].
- The app trash: a file is marked in the DB and stays untouched on disk; "Empty the trash" moves it
  to the OS trash after a confirmation, and a tile can be restored with one round target [M22.27].
- The interface speaks English and Russian: the English source goes through `i18n::t`, the Russian
  text lives in the `PAIRS` table, the language is chosen in Settings and detected from the system
  locale on the first launch; CLI reports follow the same setting [M21, M23].
- Two themes — dark, light and "follow the system" — from one token palette, with the contrast held
  by a test; the light accent is `#b45309` [M22.1, M22.11].
- The calendar in four layers: years, months, weeks and days, each with the photos of the period
  under its tiles [M22.5, M25.10, M25.11, M25.12].
- A Windows build: an MSVC cross-build from Linux, the VC++ runtime and DirectML in the folder, and a
  folder picker with drive buttons for a Windows disk [M24.4].
- "Find the programs": one press looks for `ffmpeg`, `ffprobe` and `tesseract` in `PATH` and the
  standard places of the system, writes only a program that starts and says what each one is for
  [M26.3].
- A warning mark for a limited feature with an OS-specific install command to copy — nothing is
  installed and no browser is opened [M26.2].
- Catalogs: several roots, each switchable off without losing its rows, each choosing which expensive
  passes run over it (faces, CLIP tags, text) and a confirmed "forget" of derived rows only
  [M26.1, M26.9]. The working catalog is one pill with its menu [M26.7].
- "Compact" for the database file: SQLite's `VACUUM` behind Settings → Storage, with the file's size
  and free share before the press [M26.8].

### Changed

- Every screen rebuilt after the owner's mock-ups (`docs/references/mockups/`, `plan/M22-ui-spec.md`):
  one card frame, one accent button per screen, an icon on every action button, mono numbers [M22.x].
- The People screen: the group list moved into the right panel with the best face of each group as its
  icon [M22.26], and its settings — the model, the licence, the consent and the download, the three
  thresholds and the two passes — left the settings dialog for the screen [M26.5] and then the left
  panel for the top of its own page [M26.14].
- The left panel became the map of the application: the summary moved into the status bar [M25.5], the
  tag threshold is pinned above the cloud [M25.6], the years are a cloud of chips [M25.2] and "No
  date" / "No preview" are filters of their own [M25.4]. The tag filter accumulates over several tags
  [M25.1].
- "Text on photos" left the left panel for Settings → Text on photos, with the `tesseract` path and
  its version [M25.13].
- The settings dialog keeps one size in every section: no row widens the pane, the body scrolls, the
  scroll offset belongs to the section [M26.13].
- A layout that survives a narrow window: the ribbon is measured before it is drawn and wraps, below
  670 px the whole left panel scrolls, every dialog clamps to the window and scrolls its body [M26.6].
- The model weights are downloaded by the binary itself over HTTPS (`ureq` + `rustls`), with consent
  and a `sha256` check, so a machine with nothing installed can fetch a model [M24.1, M24.2].

### Fixed

- The dHash is computed on the EXIF-oriented frame, so two false duplicate groups of portrait shots
  are gone (103 → 101 groups on the corpus) [M22.2].
- The OCR heuristic proposed 203 candidates instead of 357 while no CLIP model had ever been picked:
  the tag branch looked the dictionary up by an empty model id [M23.6].
- The Windows top strip grew to 42 px after a background pass had shown its progress row; it is
  32 logical px at every scale now [M26.4].
- The settings dialog widened from 794 to 966 px in "Tags", where the dictionary's action row asked
  for 716 px inside a 520 px column [M26.13].
- The tile preview fills its 4:3 frame with a centring crop instead of a letterbox, and the long file
  name is cut to the room the size leaves, so the right panel keeps its 280 px and the grid no longer
  jumps when a photo is selected [M22.15, M22.25].

### Removed

- `scripts/fetch-model.sh`: the model download is the binary's business, and an application that runs
  on Windows ships no shell script [M24.1].
