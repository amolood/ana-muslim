# Custom Reciters API

1. Upload `custom_reciters_api.php` to your server.
2. Create this folder beside it: `data/`
3. Put your reciter JSON files in `data/` (same format you used before: `number`, `direct_link`).
4. Edit the `reciters` config array inside `custom_reciters_api.php`.
5. Test endpoint:
   - `https://your-domain.com/custom_reciters_api.php`
   - `https://your-domain.com/custom_reciters_api.php?refresh=1`

## Flutter usage

Run/build your app with:

```bash
flutter run --dart-define=CUSTOM_RECITERS_API_URL=https://your-domain.com/custom_reciters_api.php
```

For release:

```bash
flutter build apk --release --dart-define=CUSTOM_RECITERS_API_URL=https://your-domain.com/custom_reciters_api.php
```

If the define is empty, the app loads only `mp3quran.net` reciters.
