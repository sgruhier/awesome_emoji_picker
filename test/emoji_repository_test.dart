import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Make sure this is the very first line in main
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmojiRepository', () {
    late EmojiRepository repository;

    setUp(() async {
      // Reset the singleton instance before each test
      EmojiRepository.reset();

      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      // Create a fresh repository for each test
      repository = EmojiRepository(
        prefsKey: 'test_emoji_recent',
        maxRecentItems: 5,
      );
    });

    test('initializes with empty recent emoji list', () {
      expect(repository.recentEmojis, isEmpty);
    });

    test('initializes with correct skin tone', () {
      // Reset between each repository creation to avoid singleton issues
      EmojiRepository.reset();
      final normalRepo = EmojiRepository(skinTone: EmojiSkinTone.normal);

      EmojiRepository.reset();
      final lightRepo = EmojiRepository(skinTone: EmojiSkinTone.light);

      EmojiRepository.reset();
      final darkRepo = EmojiRepository(skinTone: EmojiSkinTone.dark);

      expect(normalRepo.skinTone, equals(EmojiSkinTone.normal));
      expect(lightRepo.skinTone, equals(EmojiSkinTone.light));
      expect(darkRepo.skinTone, equals(EmojiSkinTone.dark));
    });

    test('accepts custom prefsKey and maxRecentItems', () {
      EmojiRepository.reset();
      final customRepo = EmojiRepository(prefsKey: 'custom_key', maxRecentItems: 10);

      expect(customRepo.recentEmojis, isEmpty);
      // We can't directly test private fields, but we can test the behavior
    });

    test('addToRecent adds emoji to the recent list', () async {
      final emoji = EmojiModel('😀', 'grinning face', 'Smileys & People');

      await repository.addToRecent(emoji);

      expect(repository.recentEmojis.length, equals(1));
      expect(repository.recentEmojis.first.char, equals('😀'));
    });

    test('addToRecent notifies listeners', () async {
      final emoji = EmojiModel('😀', 'grinning face', 'Smileys & People');

      int notificationCount = 0;
      repository.addListener(() {
        notificationCount++;
      });

      await repository.addToRecent(emoji);

      expect(notificationCount, equals(1));
    });

    test('addToRecent moves existing emoji to front of list', () async {
      final emoji1 = EmojiModel('😀', 'grinning face', 'Smileys & People');
      final emoji2 = EmojiModel('😂', 'face with tears of joy', 'Smileys & People');

      await repository.addToRecent(emoji1);
      await repository.addToRecent(emoji2);
      await repository.addToRecent(emoji1); // Add emoji1 again

      expect(repository.recentEmojis.length, equals(2));
      expect(repository.recentEmojis.first.char, equals('😀')); // emoji1 should be first
    });

    test('addToRecent respects maxRecentItems limit', () async {
      // Repository has maxRecentItems = 5
      final emojis = [
        EmojiModel('😀', 'grinning face', 'Smileys & People'),
        EmojiModel('😂', 'face with tears of joy', 'Smileys & People'),
        EmojiModel('😍', 'smiling face with heart-eyes', 'Smileys & People'),
        EmojiModel('🤔', 'thinking face', 'Smileys & People'),
        EmojiModel('😊', 'smiling face with smiling eyes', 'Smileys & People'),
        EmojiModel('🙂', 'slightly smiling face', 'Smileys & People'),
      ];

      // Add 6 emoji to a repository with maxRecentItems = 5
      for (final emoji in emojis) {
        await repository.addToRecent(emoji);
      }

      expect(repository.recentEmojis.length, equals(5));
      expect(repository.recentEmojis.first.char, equals('🙂')); // Last added should be first
      expect(repository.recentEmojis.map((e) => e.char).contains('😀'), isFalse); // First added should be removed
    });

    test('clearRecentEmojis removes all recent emoji', () async {
      // Add a few emoji
      await repository.addToRecent(EmojiModel('😀', 'grinning face', 'Smileys & People'));
      await repository.addToRecent(EmojiModel('😂', 'face with tears of joy', 'Smileys & People'));

      expect(repository.recentEmojis.length, equals(2));

      // Clear the list
      await repository.clearRecentEmojis();

      expect(repository.recentEmojis, isEmpty);
    });

    test('clearRecentEmojis notifies listeners', () async {
      // Add a few emoji
      await repository.addToRecent(EmojiModel('😀', 'grinning face', 'Smileys & People'));

      int notificationCount = 0;
      repository.addListener(() {
        notificationCount++;
      });

      // Clear the list
      await repository.clearRecentEmojis();

      expect(notificationCount, equals(1));
    });

    test('setRecentEmojis replaces the entire list', () async {
      // Initial state
      await repository.addToRecent(EmojiModel('😀', 'grinning face', 'Smileys & People'));

      // New list
      final newList = [
        EmojiModel('🎉', 'party popper', 'Activities'),
        EmojiModel('🎂', 'birthday cake', 'Food & Drink'),
        EmojiModel('🎁', 'wrapped gift', 'Activities'),
      ];

      await repository.setRecentEmojis(newList);

      expect(repository.recentEmojis.length, equals(3));
      expect(repository.recentEmojis.map((e) => e.char), equals(['🎉', '🎂', '🎁']));
    });

    test('setRecentEmojis respects maxRecentItems', () async {
      // Repository has maxRecentItems = 5
      final newList = List.generate(10, (i) => EmojiModel('E$i', 'emoji $i', 'test'));

      await repository.setRecentEmojis(newList);

      expect(repository.recentEmojis.length, equals(5));
    });

    test('setRecentEmojis notifies listeners', () async {
      int notificationCount = 0;
      repository.addListener(() {
        notificationCount++;
      });

      await repository.setRecentEmojis([EmojiModel('😀', 'grinning face', 'Smileys & People')]);

      expect(notificationCount, equals(1));
    });

    test('search returns emoji matching the query', () {
      final results = repository.search('grinning');

      expect(results.isNotEmpty, isTrue);
      expect(results.every((emoji) => emoji.name.contains('grinning')), isTrue);
    });

    test('search returns empty list for empty query', () {
      expect(repository.search(''), isEmpty);
      expect(repository.search('   '), isEmpty);
    });

    test('search is case-insensitive', () {
      final lowerResults = repository.search('grinning');
      final upperResults = repository.search('GRINNING');

      expect(lowerResults.length, equals(upperResults.length));
    });

    test('isAllowedSkinTone correctly filters emoji', () {
      final normalRepo = EmojiRepository(skinTone: EmojiSkinTone.normal);

      // An emoji without skin tone should be allowed in normal mode
      final normalEmoji = EmojiModel('😀', 'grinning face', 'Smileys & People');
      expect(normalRepo.isAllowedSkinTone(normalEmoji), isTrue);

      // For non-normal repositories, we can't easily test without creating actual
      // emoji with skin tone modifiers, which would be complex in a test
    });

    test('byGroup groups emoji by their category', () {
      final groups = repository.byGroup();

      expect(groups.isNotEmpty, isTrue);
      expect(groups.keys.contains('Smileys & People'), isTrue);

      // Check that emojis are grouped correctly
      for (final group in groups.keys) {
        for (final emoji in groups[group]!) {
          expect(emoji.group, equals(group));
        }
      }
    });

    test('getRecents returns the same data as recentEmojis getter', () async {
      // Add some emoji to the recents
      final emoji1 = EmojiModel('😀', 'grinning face', 'Smileys & People');
      final emoji2 = EmojiModel('🎮', 'video game', 'Activities');

      await repository.addToRecent(emoji1);
      await repository.addToRecent(emoji2);

      // Check that getRecents returns the same data as recentEmojis
      expect(repository.getRecents(), equals(repository.recentEmojis));

      // Verify the actual content
      expect(repository.getRecents().length, equals(2));
      expect(repository.getRecents().first.char, equals('🎮')); // Last added should be first
      expect(repository.getRecents().last.char, equals('😀'));
    });
  });
}
