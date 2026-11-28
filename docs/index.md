---
title: photocat — a photocatalog for a family photo archive
description: A local-first photocatalog in Rust — indexing, duplicates, semantic search, OCR, faces. Originals untouched.
show_downloads: false
---

# photocat — a photocatalog for a family photo archive

A local-first **photocatalog** written in Rust: a photo catalogue that indexes a folder of photos and
videos, finds exact duplicates and near-duplicates, tags photos by their content, reads the text on
them (OCR) and clusters faces — all on your own machine, with no cloud and no telemetry. A date-based
showcase lays the archive out by year, month and day. **Originals are never modified.**

*[Русская версия](index.ru.html) · [Source code on GitHub](https://github.com/ruchej-dev/photocat) ·
[All screenshots](https://github.com/ruchej-dev/photocat/blob/main/docs/SCREENSHOTS.md)*

[![The archive after indexing](screenshots/en/main-grid.jpg)](https://github.com/ruchej-dev/photocat/blob/main/docs/SCREENSHOTS.md)

## What it does

- **Indexing** of a folder tree: sha256, a perceptual hash (dHash), EXIF date/GPS/camera, 320 px
  previews kept in the cache; re-indexing skips a file whose path, size and mtime are unchanged.
- **Duplicates**: exact copies by sha256 and near-duplicates by Hamming distance over the dHash, with
  a CSV and a plan of what to keep — advice, never automatic deletion.
- **Semantic search** with CLIP: find a photo by a description of what is on it, plus 14 general tags.
- **OCR** of documents and screenshots through `tesseract`, with highlights in the results.
- **People**: SCRFD detection + ArcFace embeddings, face groups, names, "not him" for a false merge,
  and an automatic match that waits in a quarantine for your confirmation.
- **Albums** as a tree with a file order, and an export that writes real copies in that order.
- **Integrity**: comparing two copies of the archive (size → sha256) and a `sha256sum` manifest.
- **Rust and egui only** — one native binary, no Electron, no webview, no browser engine.

## Build and run

```bash
cargo build --release                       # ~3 minutes from scratch
./target/release/photocat index ~/Pictures  # reads files, writes the DB and previews to the cache
./target/release/photocat stats
./target/release/photocat gui               # the window
```

The database and the previews live in `~/.cache/photocat/`. The only network call the program ever
makes is the model weights download that you ask for by pressing a button.

## Documents

- [Architecture](https://github.com/ruchej-dev/photocat/blob/main/docs/ARCHITECTURE.md) — the module
  map, the database schema, the invariants.
- [Interface](https://github.com/ruchej-dev/photocat/blob/main/docs/UI.md) — the layout rules and every
  screen.
- [Decisions](https://github.com/ruchej-dev/photocat/blob/main/docs/DECISIONS.md) — the ADR log: why
  every dependency and every threshold is there.
- [Screenshots](https://github.com/ruchej-dev/photocat/blob/main/docs/SCREENSHOTS.md) — every screen,
  in English and in Russian.
- [Changelog](https://github.com/ruchej-dev/photocat/blob/main/CHANGELOG.md) — what changed and when.
- [README](https://github.com/ruchej-dev/photocat#readme) — the whole command line.

## License

Apache License 2.0 — [LICENSE](https://github.com/ruchej-dev/photocat/blob/main/LICENSE),
[NOTICE](https://github.com/ruchej-dev/photocat/blob/main/NOTICE).
