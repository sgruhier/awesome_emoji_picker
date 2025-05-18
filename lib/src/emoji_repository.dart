import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/emoji_data.dart';
import 'model/emoji_model.dart';

/// Represents different skin tone modifiers that can be applied to emoji.
/// Each enum value contains the Unicode code point for the specific skin tone.
enum EmojiSkinTone {
  /// Default skin tone (no modifier applied)
  normal(value: 0x00),

  /// Light skin tone modifier (Type-1-2)
  light(value: 0x1F3FB),

  /// Medium-light skin tone modifier (Type-3)
  mediumLight(value: 0x1F3FC),

  /// Medium skin tone modifier (Type-4)
  medium(value: 0x1F3FD),

  /// Medium-dark skin tone modifier (Type-5)
  mediumDark(value: 0x1F3FE),

  /// Dark skin tone modifier (Type-6)
  dark(value: 0x1F3FF);

  /// The Unicode code point value for this skin tone
  final int value;

  const EmojiSkinTone({required this.value});
}

/// Repository that manages emoji data and provides search capabilities.
///
/// The repository filters emoji based on skin tone and provides methods
/// to search and categorize emoji by group. It also manages a list of
/// recently used emoji, persisting them between app sessions.
class EmojiRepository extends ChangeNotifier {
  /// Storage key used for SharedPreferences to store recent emoji
  static const _defaultPrefsKey = 'awesome_emoji_picker_recent';

  /// Default maximum number of recent emoji to store
  static const _defaultMaxRecentItems = 24;

  /// Singleton instance
  static EmojiRepository? _instance;

  /// Factory constructor that returns the singleton instance.
  ///
  /// If the instance doesn't exist yet, it's created with default parameters.
  factory EmojiRepository({
    EmojiSkinTone skinTone = EmojiSkinTone.normal,
    String? prefsKey,
    int? maxRecentItems,
  }) {
    if (_instance != null && _instance!.skinTone != skinTone) {
      _instance!.setSkinTone(skinTone);
    }
    _instance ??= EmojiRepository._internal(
      skinTone: skinTone,
      prefsKey: prefsKey,
      maxRecentItems: maxRecentItems,
    );
    return _instance!;
  }

  /// Internal constructor for creating the singleton instance.
  EmojiRepository._internal({
    this.skinTone = EmojiSkinTone.normal,
    String? prefsKey,
    int? maxRecentItems,
  }) : _prefsKey = prefsKey ?? _defaultPrefsKey,
       _maxRecentItems = maxRecentItems ?? _defaultMaxRecentItems {
    _loadEmojis();
    // Load recent emoji from persistent storage
    loadRecentEmoji();
  }

  void _loadEmojis() {
    _emojis.clear();
    _emojis.addAll(kEmojiList.where((e) => isAllowedSkinTone(e)));

    if (skinTone != EmojiSkinTone.normal) {
      // Create a set of base emojis that have a modified version present
      final Set<String> baseEmojisWithSkinTone = _emojis.where((e) => e.char.runes.contains(skinTone.value)).map((e) {
        // Remove all skin tone modifiers AND the variation selector to get the "base" version
        final runes = e.char.runes.where((rune) => (rune < 0x1F3FB || rune > 0x1F3FF) && rune != 0xFE0F).toList();
        return String.fromCharCodes(runes);
      }).toSet();

      // Remove from _emojis the "base" emojis that have a modified version present
      _emojis.removeWhere((e) {
        // Remove all skin tone modifiers AND the variation selector to get the "base" version
        final runes = e.char.runes.where((rune) => (rune < 0x1F3FB || rune > 0x1F3FF) && rune != 0xFE0F).toList();
        final base = String.fromCharCodes(runes);

        // If it's an emoji without a skin tone modifier and a modified version exists, remove it
        return !e.char.runes.any((rune) => rune >= 0x1F3FB && rune <= 0x1F3FF) && baseEmojisWithSkinTone.contains(base);
      });
    }
  }

  /// Resets the singleton instance.
  ///
  /// This is primarily used for testing or when you need to recreate
  /// the instance with different parameters.
  static void reset() {
    _instance = null;
  }

  /// The current skin tone preference for this repository.
  EmojiSkinTone skinTone;

  /// The key used for storing recent emoji in SharedPreferences
  final String _prefsKey;

  /// Maximum number of recent emoji to store
  final int _maxRecentItems;

  /// Internal list of filtered emoji that match the skin tone criteria.
  final List<EmojiModel> _emojis = [];

  /// Internal list of recently used emoji, ordered from most to least recent.
  final List<EmojiModel> _recentEmojis = [];

  /// Returns an immutable copy of the recently used emoji list.
  ///
  /// The list is ordered from most to least recent.
  List<EmojiModel> get recentEmojis => List.unmodifiable(_recentEmojis);

  void setSkinTone(EmojiSkinTone value) {
    if (skinTone == value) return;
    skinTone = value;
    _loadEmojis();
    notifyListeners();
  }

  /// Returns the list of recently used emoji.
  ///
  /// This is a method alternative to the [recentEmojis] getter that returns
  /// the same data - an immutable copy of the recent emoji list ordered from
  /// most to least recent.
  ///
  /// @return An immutable list of recent emoji
  List<EmojiModel> getRecents() {
    return List.unmodifiable(_recentEmojis);
  }

  /// Determines if an emoji should be included based on skin tone criteria.
  ///
  /// Returns true if the emoji's skin tone matches the repository's skin tone preference.
  /// For normal skin tone, returns true for emoji without any skin tone modifier.
  /// For other skin tones, returns true only for emoji with the matching skin tone modifier.
  bool isAllowedSkinTone(EmojiModel e) {
    final code = e.char.runes;

    if (code.length > 2) {
      return false;
    }

    // Always accept emojis without a skin tone modifier
    if (!code.any((rune) => rune >= 0x1F3FB && rune <= 0x1F3FF)) {
      return true;
    }

    // For other tones, only accept those that have this modifier
    return code.contains(skinTone.value);
  }

  /// Searches for emoji matching the given query string.
  ///
  /// The search is case-insensitive and looks for partial matches in the emoji name.
  /// Returns an empty list if the query is empty or only contains whitespace.
  ///
  /// Complexity is O(n) but performance is fast in practice since the emoji list
  /// typically contains around 3,000 items.
  ///
  /// @param query The search string to match against emoji names
  /// @return A list of emoji that match the search criteria
  List<EmojiModel> search(String query) {
    if (query.trim().isEmpty) return const [];
    final q = query.toLowerCase().trim();
    return _emojis.where((e) => e.name.contains(q)).toList();
  }

  /// Groups emoji by their CLDR (Common Locale Data Repository) category.
  ///
  /// This is useful for organizing emoji into category tabs in a UI.
  /// The returned map uses the group name as keys and lists of emoji as values.
  ///
  /// @return A map with CLDR group names as keys and lists of emoji as values
  Map<String, List<EmojiModel>> byGroup() {
    final map = <String, List<EmojiModel>>{};
    for (final e in _emojis) {
      map.putIfAbsent(e.group, () => []).add(e);
    }
    return map;
  }

  /// Checks if the specified emoji is in the recent list.
  ///
  /// @param emoji The emoji to check
  /// @return true if the emoji is in the recent list, false otherwise
  bool containsInRecent(EmojiModel emoji) => _recentEmojis.any((e) => e.char == emoji.char);

  /// Adds an emoji to the recent list and persists the updated list.
  ///
  /// If the emoji is already in the list, it's moved to the front (most recent).
  /// If adding the emoji would exceed [_maxRecentItems], the least recent emoji is removed.
  /// The repository notifies listeners when the list changes.
  ///
  /// @param emoji The emoji to add to the recent list
  /// @return A future that completes when the list has been persisted
  Future<void> addToRecent(EmojiModel emoji) async {
    // Remove the emoji if it already exists
    _recentEmojis.removeWhere((e) => e.char == emoji.char);

    // Add the emoji at the start of the list
    _recentEmojis.insert(0, emoji);

    // Maintain maximum size
    if (_recentEmojis.length > _maxRecentItems) {
      _recentEmojis.removeLast();
    }

    // Notify listeners about the change
    notifyListeners();

    try {
      // Persist the updated  list
      final prefs = await SharedPreferences.getInstance();
      final encodedList = jsonEncode(_recentEmojis.map((e) => e.char).toList());
      await prefs.setString(_prefsKey, encodedList);
    } catch (e) {
      debugPrint('Failed to save recent emoji: $e');
    }
  }

  /// Loads the recent emoji list from persistent storage.
  ///
  /// Uses the repository's emoji data to reconstruct full emoji objects from
  /// the persisted character codes. If an emoji is no longer found in the
  /// repository, a fallback emoji is created.
  ///
  /// This is called automatically when creating a repository instance,
  /// but can be called again to refresh the recent emoji list if needed.
  ///
  /// @return A future that completes when the list has been loaded
  Future<void> loadRecentEmoji() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);

      if (raw != null) {
        // Decode the persisted data
        final List<dynamic> decoded = jsonDecode(raw);
        final List<String> charList = decoded.cast<String>();

        // Clear the current list and add reconstructed emoji
        _recentEmojis.clear();

        for (final char in charList) {
          try {
            // Try to find the emoji in the repository
            final emoji = search(
              char,
            ).firstWhere((e) => e.char == char, orElse: () => EmojiModel(char, 'recent', 'recent'));
            _recentEmojis.add(emoji);
          } catch (e) {
            // Skip any problematic entries
            debugPrint('Failed to reconstruct emoji for character: $char');
          }
        }

        // Notify listeners about the loaded data
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load recent emoji: $e');
    }
  }

  /// Clears all recent emoji from the store and persists the empty state.
  ///
  /// @return A future that completes when the empty list has been persisted
  Future<void> clearRecentEmojis() async {
    if (_recentEmojis.isEmpty) return;

    _recentEmojis.clear();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, '[]');
    } catch (e) {
      debugPrint('Failed to persist empty recent emoji list: $e');
    }
  }

  /// Sets the list of recent emoji, replacing any existing entries.
  ///
  /// The provided list should be ordered from most to least recent.
  /// If the list contains more than [_maxRecentItems] items, only the first
  /// [_maxRecentItems] will be kept.
  ///
  /// @param emojis The list of emoji to set as recent
  /// @return A future that completes when the list has been persisted
  Future<void> setRecentEmojis(List<EmojiModel> emojis) async {
    _recentEmojis.clear();

    // Add only up to the maximum number of items
    final itemsToAdd = emojis.length > _maxRecentItems ? emojis.sublist(0, _maxRecentItems) : emojis;
    _recentEmojis.addAll(itemsToAdd);

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList = jsonEncode(_recentEmojis.map((e) => e.char).toList());
      await prefs.setString(_prefsKey, encodedList);
    } catch (e) {
      debugPrint('Failed to save recent emoji: $e');
    }
  }
}
