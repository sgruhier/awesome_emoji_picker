import 'dart:convert';

import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Make sure this is the very first line in main
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmojiRepository Persistence', () {
    const testPrefsKey = 'test_emoji_recent';
    late EmojiRepository repository;

    setUp(() async {
      // Reset the singleton instance before each test
      EmojiRepository.reset();

      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('loads recent emoji from SharedPreferences', () async {
      // Set up mock SharedPreferences with some emoji data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(testPrefsKey, jsonEncode(['😀', '😂', '🎉']));

      // Create repository - it should load the emoji from preferences
      repository = EmojiRepository(prefsKey: testPrefsKey);

      // Force any async operations to complete
      await Future.delayed(Duration.zero);

      expect(repository.recentEmojis.length, equals(3));
      expect(repository.recentEmojis.map((e) => e.char).toList(), equals(['😀', '😂', '🎉']));
    });

    test('persists added emoji to SharedPreferences', () async {
      // Create repository
      repository = EmojiRepository(prefsKey: testPrefsKey);

      // Add an emoji
      final emoji = EmojiModel('🎁', 'wrapped gift', 'Activities');
      await repository.addToRecent(emoji);

      // Check that it was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(testPrefsKey);

      expect(savedData, isNotNull);

      final List<dynamic> decoded = jsonDecode(savedData!);
      expect(decoded, contains('🎁'));
    });

    test('persists cleared emoji list to SharedPreferences', () async {
      // Set up mock SharedPreferences with some emoji data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(testPrefsKey, jsonEncode(['😀', '😂', '🎉']));

      // Create repository
      repository = EmojiRepository(prefsKey: testPrefsKey);

      // Force any async operations to complete
      await Future.delayed(Duration.zero);

      // Clear the list
      await repository.clearRecentEmojis();

      // Check that it was saved to SharedPreferences
      final savedData = prefs.getString(testPrefsKey);
      expect(savedData, equals('[]'));
    });

    test('persists set emoji list to SharedPreferences', () async {
      // Create repository
      repository = EmojiRepository(prefsKey: testPrefsKey);

      // Set a new list
      final newList = [EmojiModel('🎮', 'video game', 'Activities'), EmojiModel('🎯', 'direct hit', 'Activities')];

      await repository.setRecentEmojis(newList);

      // Check that it was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(testPrefsKey);

      expect(savedData, isNotNull);

      final List<dynamic> decoded = jsonDecode(savedData!);
      expect(decoded.length, equals(2));
      expect(decoded, contains('🎮'));
      expect(decoded, contains('🎯'));
    });

    test('different prefsKey values store data separately', () async {
      // Create two repositories with different keys
      // Reset before creating first repository
      EmojiRepository.reset();
      final repo1 = EmojiRepository(prefsKey: 'repo1_key');

      // Reset before creating second repository
      EmojiRepository.reset();
      final repo2 = EmojiRepository(prefsKey: 'repo2_key');

      // Add different emoji to each
      await repo1.addToRecent(EmojiModel('😀', 'grinning face', 'Smileys & People'));
      await repo2.addToRecent(EmojiModel('🎮', 'video game', 'Activities'));

      // Check that data was saved separately
      final prefs = await SharedPreferences.getInstance();
      final saved1 = prefs.getString('repo1_key');
      final saved2 = prefs.getString('repo2_key');

      expect(saved1, isNotNull);
      expect(saved2, isNotNull);
      expect(saved1, isNot(equals(saved2)));

      final decoded1 = jsonDecode(saved1!);
      final decoded2 = jsonDecode(saved2!);

      expect(decoded1, contains('😀'));
      expect(decoded1, isNot(contains('🎮')));
      expect(decoded2, contains('🎮'));
      expect(decoded2, isNot(contains('😀')));
    });

    test('handles invalid data in SharedPreferences gracefully', () async {
      // Set up mock SharedPreferences with invalid data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(testPrefsKey, 'not valid json');

      // Temporarily capture logs to avoid printing the expected error
      final originalPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        // We expect an error like "Failed to load recent emoji: FormatException"
        // But we don't need to verify its exact content
      };

      try {
        // Create repository - it should handle the invalid data gracefully
        repository = EmojiRepository(prefsKey: testPrefsKey);

        // Force any async operations to complete
        await Future.delayed(Duration.zero);

        // Should start with empty list instead of crashing
        expect(repository.recentEmojis, isEmpty);
      } finally {
        // Restore original print function
        debugPrint = originalPrint;
      }
    });
  });
}
