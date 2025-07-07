# Awesome Emoji Picker

A modern, full-featured emoji picker for Flutter applications that runs seamlessly on **iOS, Android, macOS, Windows, Linux and Web**.

[![Pub Version](https://img.shields.io/pub/v/awesome_emoji_picker.svg)](https://pub.dev/packages/awesome_emoji_picker)
[![License: MIT with Attribution](https://img.shields.io/badge/License-MIT%20with%20Attribution-blue.svg)](LICENSE)

| iOS                                                                                                                                             | Android                                                                                                                                                 |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/sgruhier/awesome_emoji_picker/raw/main/screenshot_ios.png" alt="Awesome Emoji Picker IOS Screenshot" width="400"/> | <img src="https://github.com/sgruhier/awesome_emoji_picker/raw/main/screenshot_android.png" alt="Awesome Emoji Picker Android Screenshot" width="350"/> |

## Used By

This package was originally created for [Dragonfly](https://dfly.app), a Bluesky client for macOS, tablets, and mobile devices. Dragonfly uses this emoji picker for post composition and reactions.

## Features

- Powerful search by emoji name or keyword
- "Recently used" emoji tracking (persistent, per-platform)
- Category-based organization with intuitive navigation
- Built-in support for light and dark themes
- Responsive design that adapts to any screen size
- Cross-platform compatibility with all Flutter targets
- Skin tone support for human emoji
- Persistent skin tone preference across sessions
- Intuitive skin tone selector UI

## Flexible Widget Display

The `EmojiPicker` is a standalone widget that can be displayed anywhere in your Flutter app. You have complete control over how and where to show it:

- **Bottom Sheets**: Perfect for mobile interfaces
- **Popups/Dialogs**: Great for desktop applications
- **Inline**: Embed directly in your UI
- **Expandable Widget**: Use with Flutter 3.32's new `Expandable` widget for collapsible emoji selection
- **Custom Containers**: Wrap in any container or layout widget

The widget adapts to its container size and provides a consistent experience across all display methods.

## Installation

Add the package to your pubspec.yaml:

```bash
flutter pub add awesome_emoji_picker
```

## Usage

### Basic Implementation

```dart
import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';

// Inside your widget build method:
EmojiPicker(
  onEmojiSelected: (emoji) {
    // Handle the selected emoji
    print('Selected emoji: ${emoji.char}');

    // Example: Insert into a TextField controller
    textEditingController.text += emoji.char;
  },
)
```

### Customization

Adjust the appearance and behavior of the picker:

```dart
EmojiPicker(
  onEmojiSelected: (emoji) {
    // Handle selection
  },
  emojiSize: 32.0,  // Size of emoji characters
  cellSize: 48.0,   // Size of grid cells
  categoryBarPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding around the category bar
  categoryBarHeight: 48.0, // Height of the category bar
  autofocus: true,  // Automatically focus the search field when opened
)
```

### Internationalization

You can customize the category names and other texts to support different languages:

```dart
// Define translations for category names
final frenchTranslations = {
  'Recents': 'Récents',
  'Smileys & People': 'Émoticônes et personnes',
  'Animals & Nature': 'Animaux et nature',
  'Food & Drink': 'Nourriture et boissons',
  'Activities': 'Activités',
  'Travel & Places': 'Voyages et lieux',
  'Objects': 'Objets',
  'Symbols': 'Symboles',
  'Flags': 'Drapeaux',
};

EmojiPicker(
  onEmojiSelected: (emoji) {
    // Handle selection
  },
  // Pass translations for category names
  categoryTranslations: frenchTranslations,
  // Translate other UI elements
  searchHintText: 'Rechercher',
  searchResultsText: 'Résultats de recherche',
  skinToneLabel: 'Couleur de peau',
  // Automatically focus the search field for better UX
  autofocus: true,
)
```

This allows you to completely localize the emoji picker UI while maintaining the same functionality.

## Advanced Usage

### Search Integration

The widget includes built-in search functionality. The search is performed across emoji names and keywords.

### Recent Emoji Tracking

Recently used emoji are automatically tracked and displayed in the "Recents" category. This data persists between app sessions using `SharedPreferences`.

### Managing Recent Emoji

You can directly access and manage the recent emoji store through the `EmojiRepository` class, which is implemented as a singleton:

```dart
// Get the repository singleton instance
final repository = EmojiRepository();

// Create or get the repository with custom configuration
// Since this is a singleton, these parameters will only be applied
// when the instance is first created
final customRepository = EmojiRepository(
  // Custom skin tone selection
  skinTone: EmojiSkinTone.light,
  // Custom storage key for managing multiple separate sets of recent emoji
  prefsKey: 'my_custom_emoji_store',
  // Custom maximum number of recent emoji to store (default is 24)
  maxRecentItems: 50,
);

// For testing or when you need to reset the singleton
EmojiRepository.reset();

// Get the list of recent emoji (two equivalent ways)
final recentEmojis = repository.recentEmojis;  // Using property
final recents = repository.getRecents();       // Using method

// Add an emoji to recents
await repository.addToRecent(emoji);

// Clear all recent emoji
await repository.clearRecentEmojis();

// Set a completely new list of recent emoji
await repository.setRecentEmojis(myCustomEmojiList);

// Repository extends ChangeNotifier, so you can listen for changes
repository.addListener(() {
  // Update UI when recent emoji change
  setState(() {});
});
```

## Updating Emoji Data

Unicode regularly adds new emoji. You can regenerate the emoji list with:

```bash
cd tool
node import_emoji.js
cd ..
dart run tool/generate_emoji_data.dart
```

This downloads the latest `emoji.json` (© 2024 Amio) and converts it to a compile-time Dart list.

## Development

### Unit Testing

The package includes comprehensive unit tests for the `EmojiRepository` class, focusing on:

- Core functionality: emoji search, filtering, categorization, and skinTone handling
- Recent emoji management: adding, clearing, and setting recent emoji
- Persistence: storing and retrieving recent emoji using SharedPreferences
- Skin tone support: ensuring different skin tones work correctly

Run the tests with:

```bash
flutter test
```

### LLM Contribution

The documentation comments throughout the codebase and approximately 25% of the code were created with the assistance of a Large Language Model (LLM). Of course, I was the pilot, but the LLM was just used as an assistant :). Never trust an LLM, but use it as a tool to help you write code.

## License

### MIT License with Attribution Requirement

Copyright © 2025 Sébastien Gruhier (asyncdev.com) and Inès Gruhier (odubu.design)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software, including the rights to use, copy, modify, merge, publish, and/or distribute copies of the Software, subject to the following conditions:

1. **Attribution Requirement**: Any use, modification, or distribution of the Software must include clear and visible attribution to the original authors:

   - [Sébastien Gruhier](https://asyncdev.com) for development
   - [Inès Gruhier](https://odubu.design) for design

2. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Icon Attribution

The icons used in this package are sourced from:

- **[Heroicons](https://heroicons.com/)** - Beautiful hand-crafted SVG icons by the makers of Tailwind CSS
- **[Lucide](https://lucide.dev/)** - Beautiful & consistent icon toolkit made by the community

These icon libraries are used under their respective open-source licenses.
