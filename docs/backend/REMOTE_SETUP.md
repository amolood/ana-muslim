# Remote-Only Setup (No Flutter Assets)

This app now supports running data/fonts/tones remotely.

## 1) Upload backend script

Upload:
- `/Users/molood/I'mMuslim/docs/backend/remote_islamic_api.php`

Recommended server structure:

```text
remote_islamic_api.php
data/
  azkar.json
  asma_allah.json
  hadith/
    bukhari/
      books.json
      hadiths.json
    muslim/
      books.json
      hadiths.json
  reciters/
    ahmed_mohamed_taher_islamway_links.json
    mohamed_osman_links.json
fonts/
  KFGQPC_Uthmanic_Script.ttf
sounds/
  qibla_success_soft.mp3
  qibla_success_bell.mp3
```

## 2) Use dart-define values

Run:

```bash
flutter run \
  --dart-define=REMOTE_ISLAMIC_API_URL=https://your-domain.com/remote_islamic_api.php \
  --dart-define=QPC_FONT_URL=https://your-domain.com/fonts/KFGQPC_Uthmanic_Script.ttf \
  --dart-define=QIBLA_TONE_SOFT_URL=https://your-domain.com/sounds/qibla_success_soft.mp3 \
  --dart-define=QIBLA_TONE_BELL_URL=https://your-domain.com/sounds/qibla_success_bell.mp3
```

Release:

```bash
flutter build apk --release \
  --dart-define=REMOTE_ISLAMIC_API_URL=https://your-domain.com/remote_islamic_api.php \
  --dart-define=QPC_FONT_URL=https://your-domain.com/fonts/KFGQPC_Uthmanic_Script.ttf \
  --dart-define=QIBLA_TONE_SOFT_URL=https://your-domain.com/sounds/qibla_success_soft.mp3 \
  --dart-define=QIBLA_TONE_BELL_URL=https://your-domain.com/sounds/qibla_success_bell.mp3
```

## 3) API quick checks

- `https://your-domain.com/remote_islamic_api.php?action=reciters`
- `https://your-domain.com/remote_islamic_api.php?action=azkar`
- `https://your-domain.com/remote_islamic_api.php?action=asma`
- `https://your-domain.com/remote_islamic_api.php?action=hadith_books&collection=bukhari`
- `https://your-domain.com/remote_islamic_api.php?action=hadith_book&collection=muslim&book=1`
- `https://your-domain.com/remote_islamic_api.php?action=hadith_all&collection=muslim`

Use `&refresh=1` to bypass server cache.
