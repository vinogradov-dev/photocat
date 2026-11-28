---
title: photocat — фотокаталог семейного фотоархива
description: Локальный фотокаталог на Rust — индексация, дубли, смысловой поиск, OCR, лица. Оригиналы не меняются.
show_downloads: false
---

# photocat — фотокаталог семейного фотоархива

**Фотокаталог** на Rust — каталогизатор фотографий и видео: индексирует папки, находит точные дубли
и похожие снимки, расставляет смысловые теги, распознаёт текст на снимках (OCR) и группирует лица.
Всё на вашей машине: без облака и без телеметрии. Раскладка по датам раскладывает архив по годам,
месяцам и дням. **Оригиналы не меняются никогда.**

*[English version](index.html) · [Исходный код на GitHub](https://github.com/ruchej-dev/photocat) ·
[Все экраны](https://github.com/ruchej-dev/photocat/blob/main/docs/SCREENSHOTS.ru.md)*

[![Архив после индексации](screenshots/ru/main-grid.jpg)](https://github.com/ruchej-dev/photocat/blob/main/docs/SCREENSHOTS.ru.md)

## Что он умеет

- **Индексация** дерева папок: sha256, перцептивный хеш (dHash), дата/координаты/камера из EXIF,
  превью 320 px в кэше; повторная индексация пропускает файл, у которого не изменились путь, размер и
  время.
- **Дубли**: точные копии по sha256 и похожие снимки по расстоянию Хэмминга на dHash, с CSV и планом
  «что оставить» — это совет, а не автоматическое удаление.
- **Смысловой поиск** по CLIP: найти снимок по описанию того, что на нём, плюс 14 общих тегов.
- **OCR** документов и скриншотов через `tesseract`, с подсветкой найденного в результатах.
- **Лица**: детектор SCRFD и эмбеддинги ArcFace, группы лиц, имена, «не он» для ложной склейки и
  автоматическое сопоставление, которое ждёт подтверждения в карантине.
- **Альбомы** деревом с порядком файлов и экспорт, который пишет настоящие копии в этом порядке.
- **Сверка**: сравнение двух копий архива (размер → sha256) и слепок `sha256sum`.
- **Только Rust и egui** — один нативный бинарник, без Electron, без webview, без движка браузера.

## Сборка и запуск

```bash
cargo build --release                       # первый раз ~3 минуты
./target/release/photocat index ~/Pictures  # читает файлы, пишет БД и превью в кэш
./target/release/photocat stats
./target/release/photocat gui               # окно
```

База и превью лежат в `~/.cache/photocat/`. Единственный выход в сеть, который делает программа, —
загрузка весов моделей, которую вы заказываете кнопкой сами.

## Документы

- [Архитектура](https://github.com/ruchej-dev/photocat/blob/main/docs/ARCHITECTURE.ru.md) — карта
  модулей, схема базы, инварианты.
- [Интерфейс](https://github.com/ruchej-dev/photocat/blob/main/docs/UI.ru.md) — правила раскладки и
  все экраны.
- [Решения](https://github.com/ruchej-dev/photocat/blob/main/docs/DECISIONS.ru.md) — журнал ADR: зачем
  каждая зависимость и каждый порог.
- [Снимки экранов](https://github.com/ruchej-dev/photocat/blob/main/docs/SCREENSHOTS.ru.md) — все
  экраны на английском и на русском.
- [Журнал изменений](https://github.com/ruchej-dev/photocat/blob/main/CHANGELOG.ru.md) — что менялось
  и когда.
- [README](https://github.com/ruchej-dev/photocat/blob/main/README.ru.md) — вся командная строка.

## Лицензия

Apache License 2.0 — [LICENSE](https://github.com/ruchej-dev/photocat/blob/main/LICENSE),
[NOTICE](https://github.com/ruchej-dev/photocat/blob/main/NOTICE).
