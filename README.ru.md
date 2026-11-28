<picture>
  <source media="(prefers-color-scheme: light)" srcset="assets/photocat-lockup-light.png">
  <img alt="photocat" src="assets/photocat-lockup.png" width="800">
</picture>

# photocat

**Фотокаталог** семейного медиаархива на Rust — каталогизатор фотографий и видео: индексация, поиск
дублей и похожих снимков, смысловые теги, OCR и лица — всё локально; раскладка по датам. Оригиналы
не меняются.

*English version: [README.md](README.md).*

Что менялось и когда: [CHANGELOG.ru.md](CHANGELOG.ru.md). Знак и иконка окна лежат в
[`assets/`](assets/) (ADR 0052).

## Снимки экранов

![Архив после индексации](docs/screenshots/ru/main-grid.jpg)
*Архив после индексации: сетка по месяцам, карточка снимка и фильтры.*

![Полный экран](docs/screenshots/ru/viewer-faces.jpg)
*Полный экран: рамки лиц, строка инструментов и серия дня.*

![Лица](docs/screenshots/ru/people.jpg)
*Названная группа лиц. Все экраны — в [docs/SCREENSHOTS.ru.md](docs/SCREENSHOTS.ru.md), на английском
и на русском.*

## Сборка

```bash
cargo build --release      # первый раз ~3 минуты
# бинарник: target/release/photocat
```

## Использование

```bash
# 1. Индексация каталога (читает файлы, пишет БД и превью в ~/.cache/photocat)
./target/release/photocat index ~/Documents/nasty/mail_media/Фотографии с телефона

# 2. Статистика
./target/release/photocat stats

# 3. Дубли и серии (порог — расстояние Хэмминга по 64-битному dHash)
./target/release/photocat dupes --max-dist 6
./target/release/photocat dupes --max-dist 4 --csv /tmp/dupes.csv
./target/release/photocat dupes --max-dist 6 --plan /tmp/dupes-plan.csv   # план: что оставить

# 4. Альбомы: дерево и порядок файлов — только строки БД, на диске ничего не меняется
./target/release/photocat albums new --name "Дача 2024"
./target/release/photocat albums new --name "Май" --parent 1
./target/release/photocat albums add --id 2 ~/Фото/IMG_0001.jpg ~/Фото/IMG_0002.jpg
./target/release/photocat albums list --tree
./target/release/photocat albums show --id 2 --tree

# 4b. Выгрузка альбома настоящими копиями: структура и порядок как в альбоме
./target/release/photocat export --album 1 --out /mnt/disk/выгрузка            # план-дерево
./target/release/photocat export --album 1 --out /mnt/disk/выгрузка --apply    # копии
./target/release/photocat export --album 1 --out /mnt/disk/выгрузка --name '{n}_{date}_{orig}'

# 5. Витрина (по умолчанию только план, ничего не меняет и не переименовывает)
./target/release/photocat organize --out ~/Фото-витрина
./target/release/photocat organize --out ~/Фото-витрина --by month     # ГГГГ/ГГГГ-ММ
./target/release/photocat organize --out ~/Фото-витрина --by event     # день + место по GPS
./target/release/photocat organize --out ~/Фото-витрина --apply          # hardlink
./target/release/photocat organize --out /mnt/disk --apply --copy        # копии
./target/release/photocat organize --out ~/Фото-витрина --apply --rename # имена из даты
./target/release/photocat organize --out ~/Фото-витрина --exclude-dup    # без помеченных лишними
./target/release/photocat organize --out ~/Фото-витрина --name '{date}_{camera}_{orig}'

# 6. CLIP: смысловые теги и поиск (модель скачивается один раз, дальше всё локально)
./target/release/photocat models download --id clip-vit-b32-multilingual --yes  # сеть, по согласию
./target/release/photocat embed                        # 2229 файлов ≈ 177 с на CPU (два кадра)
./target/release/photocat embed --refresh              # пересчитать векторы после смены входа
./target/release/photocat search "торт" --top 20
./target/release/photocat clusters --k 30              # → plan/M3-clusters.md

# 7. Текст на документах и скриншотах (нужен tesseract с языками rus+eng)
./target/release/photocat ocr --dry-run
./target/release/photocat ocr
./target/release/photocat search "справка" --text

# 8. Лица: детекция, группы, имена (модель 182.4 МиБ — в «Настройках» с согласием)
./target/release/photocat faces --dry-run
./target/release/photocat faces
./target/release/photocat faces --list
./target/release/photocat faces label --id 5 --name Лиза
./target/release/photocat faces split --id 123

# 9. Целостность и бэкап (только чтение, код 0 — совпало, 1 — есть расхождения)
./target/release/photocat verify ~/Фото ~/backup/Фото
./target/release/photocat manifest ~/Фото --out ~/Фото.sha256
./target/release/photocat verify --manifest ~/Фото.sha256 ~/backup/Фото
# В GUI при сроке (по умолчанию 30 дней) появляется баннер «Пора проверить архив»;
# срок и интервал — на экране «Целостность». Сам проход не запускается.

# 10. GUI
./target/release/photocat gui
./target/release/photocat gui --db /путь/к/фотокат.db
```

## Проверка по расписанию (systemd, необязательно)

Приложение не ставит таймеров и ничего не запускает само: GUI лишь напоминает. Если нужна
проверка без человека, её делает ОС тем же CLI-путём, что и вручную (код 1 — есть расхождения):

```ini
# ~/.config/systemd/user/photocat-verify.service
[Unit]
Description=photocat: verify photo archive against its manifest

[Service]
Type=oneshot
ExecStart=%h/bin/photocat verify --manifest %h/Фото.sha256 %h/Фото
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

## Что уже есть

| Возможность | Статус |
|---|---|
| Индексация: sha256, dHash, EXIF (дата, GPS, камера), размеры, превью | ✅ |
| Дата: EXIF → имя файла (`IMG_20240517_144243`) → mtime, с пометкой источника | ✅ |
| Дубли: точные (sha256) + похожие (Hamming по dHash), кластеры через union-find | ✅ |
| Отчёт dupes в консоль и CSV, объём «лишнего» | ✅ |
| Совет по группе: резкость (лапласиан), разрешение, размер — словами; точные копии — «разницы нет» | ✅ |
| Решение «оставить / лишний» в БД, сводка «помечено лишними M, освободится X», план CSV без удаления | ✅ |
| Раскладка по датам: план/dry-run, hardlink/copy/symlink, дедуп коллизий имён | ✅ |
| GUI в духе PhotoPrism: боковая навигация со счётчиками, поиск в верхней панели, группы по месяцам, чипы фильтра, инспектор файла, календарь, группы дублей, размер плиток | ✅ |
| Полный экран: двойной клик, мгновенное превью, слайд-шоу, масштаб, весь OCR-текст | ✅ |
| Видео: кадр-обложка, встроенный плеер (H.264/HEVC, AAC, звук), ffplay и системный плеер как запасной путь | ✅ |
| Инкрементальная индексация: неизменённые файлы пропускаются (повтор 2230 файлов — 0.02 с) | ✅ |
| Несколько каталогов, встроенный выбор папки, удаление каталога только из индекса | ✅ |
| Консольная строка прогресса | ✅ |
| CLIP-эмбеддинги (ONNX, CPU), смысловой поиск «торт», «море», «документ» на русском | ✅ |
| Каталог моделей: CLIP 512 (рус/англ), SigLIP 768 (англ); размерность — свойство модели | ✅ |
| Теги CLIP (14 подсказок: пляж, документ, еда, мебель, интерьер, город и др.) в карточке и фильтре | ✅ |
| Свои теги вручную, «Посчитать теги» по готовым векторам; лица вместе на одном снимке | ✅ |
| Кластеры CLIP: 30 групп × 12 примеров в `plan/M3-clusters.md` | ✅ |
| Лица: SCRFD + ArcFace, группы, подписи вручную, «не он» для ложных склеек | ✅ |
| OCR документов/скриншотов (tesseract), поиск по тексту с подсветкой | ✅ |
| Превью видео через ffmpeg, dHash и длительность, видео в дублях и CLIP | ✅ |
| Настройки: модель, пороги, пути к ffmpeg/ffprobe/tesseract с проверкой; `doctor` | ✅ |
| «Лучший кадр из серии»: совет по резкости/разрешению/размеру | ✅ |
| Сверка двух копий архива (`verify`, размер → sha256) и слепок `sha256sum` (`manifest`) | ✅ |
| Напоминание о проверке по сроку (интервал в `settings`, баннер в GUI) без автозапуска | ✅ |
| Корзина приложения и очистка в системную корзину ОС по подтверждению; занятое место и очистка кэша | ✅ |
| Альбомы: дерево с подальбомами и порядком файлов, только данные в БД; CLI и вид «Альбомы» | ✅ |
| Язык интерфейса: английский (основной) и русский — выбор в «Настройки → Интерфейс» | ✅ механизм; охват экранов — в `plan/I18N.md` |

## Хранение

* БД: `~/.cache/photocat/photocat.db` (SQLite, WAL). Индекс пересоздаётся индексацией, оригиналы не изменяются; решения по дублям (`decision`) сохраняются, пока у файла тот же `sha256`.
* Превью: `~/.cache/photocat/thumbs/<2 симв.>/<sha256>.jpg`, 320 px по длинной стороне.
* Модель CLIP: `~/.cache/photocat/models/clip-vit-b32/`, 218 МиБ; SigLIP — 203.5 МиБ,
  768 признаков. sha256 проверяется при загрузке; модели не смешиваются.
  В сеть уходит только загрузка весов, которую владелец заказывает сам (кнопка в «Настройках» или
  `models download`); больше ничего наружу не отправляется.
* Ничего не удаляется и не переименовывается без явных флагов.

## Замеры на реальном архиве

* 2230 файлов (21.2 ГиБ): индексация **60.2 с** на 16 потоках, БД 1.3 МБ, превью 29 МБ.
* 103 группы дублей/серий, 238 файлов, «лишнего» 214 МиБ; резкость посчитана у всех файлов групп.
* 2.3 млн сравнений dHash — **0.03 с** (в памяти, без БД).
* CLIP-эмбеддинги 1971 фото: **66.9 с** на CPU (34 мс/фото), векторы 3.85 МиБ, БД 11 МБ.
  Смысловой поиск по 20 тыс. векторов — **48–51 мс**; повторный `embed` — 0.025 с (пропуск по sha256).

## Лицензия

photocat распространяется по лицензии **Apache License 2.0** — полный текст в [LICENSE](LICENSE),
уведомление об авторстве в [NOTICE](NOTICE). Правообладатель — Александр Григорьевич Виноградов.

Сторонние модели, крейты и программы остаются под своими лицензиями: веса CLIP и лиц скачивает
владелец, с исходным кодом они не поставляются; `ffmpeg`, `ffprobe` и `tesseract` — внешние
программы, которые приложение только вызывает, а веса моделей качает сам бинарник (`ureq` + `rustls`,
ADR 0047).

## Ключевые слова

Что это, словами, по которым такой проект ищут: фотокаталог, фотокаталог снимков, каталогизатор
фотографий, каталог фото, photocatalog, photo catalogue, поиск дублей фотографий, похожие снимки,
смысловой поиск по фото, OCR фотографий, распознавание лиц на фото, локальный фотокаталог без
облака, Rust, SQLite, egui.
