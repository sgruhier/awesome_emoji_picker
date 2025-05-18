# emoji_picker_plus

A cross‑platform Flutter emoji picker that runs on **iOS, Android, macOS, Windows, Linux and Web**.

* Search by name or keyword
* “Frequently used” section (LRU, per platform)
* Optional skin‑tone selector
* Built‑in light/dark theming
* Asset fallback for platforms without native color‑emoji fonts

## Getting started

```bash
flutter pub add emoji_picker_plus
```

Then:

```dart
EmojiPicker(
  onEmojiSelected: (emoji) { controller.insert(emoji.char); },
)
```

### Generate fresh emoji data

Unicode keeps adding new emoji. Regenerate the list with:

```bash
dart run tool/generate_emoji_data.dart
```

This downloads the latest `emoji.json` (© 2024 Amio) and converts it to a compile‑time Dart list.

## License

MIT © 2025 Your Name
