import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup SharedPreferences for testing
  SharedPreferences.setMockInitialValues({});

  group('EmojiSkinTone', () {
    test('has correct Unicode values', () {
      expect(EmojiSkinTone.normal.value, equals(0x00));
      expect(EmojiSkinTone.light.value, equals(0x1F3FB));
      expect(EmojiSkinTone.mediumLight.value, equals(0x1F3FC));
      expect(EmojiSkinTone.medium.value, equals(0x1F3FD));
      expect(EmojiSkinTone.mediumDark.value, equals(0x1F3FE));
      expect(EmojiSkinTone.dark.value, equals(0x1F3FF));
    });
  });

  group('EmojiRepository with Skin Tones', () {
    test('creates repositories with different skin tones', () {
      // Reset before creating each repository to avoid singleton issues
      EmojiRepository.reset();
      final normalRepo = EmojiRepository(skinTone: EmojiSkinTone.normal);

      EmojiRepository.reset();
      final lightRepo = EmojiRepository(skinTone: EmojiSkinTone.light);

      EmojiRepository.reset();
      final mediumRepo = EmojiRepository(skinTone: EmojiSkinTone.medium);

      EmojiRepository.reset();
      final darkRepo = EmojiRepository(skinTone: EmojiSkinTone.dark);

      expect(normalRepo.skinTone, equals(EmojiSkinTone.normal));
      expect(lightRepo.skinTone, equals(EmojiSkinTone.light));
      expect(mediumRepo.skinTone, equals(EmojiSkinTone.medium));
      expect(darkRepo.skinTone, equals(EmojiSkinTone.dark));
    });

    test('isAllowedSkinTone works with regular emoji', () {
      EmojiRepository.reset();
      final normalRepo = EmojiRepository(skinTone: EmojiSkinTone.normal);

      // Create emoji without skin tone modifiers
      final emoji1 = EmojiModel('😀', 'grinning face', 'Smileys & People');
      final emoji2 = EmojiModel('🎮', 'video game', 'Activities');

      // Normal repository should allow regular emoji
      expect(normalRepo.isAllowedSkinTone(emoji1), isTrue);
      expect(normalRepo.isAllowedSkinTone(emoji2), isTrue);
    });

    test('search works with different skin tones', () {
      // Reset before creating each repository
      EmojiRepository.reset();
      final normalRepo = EmojiRepository(skinTone: EmojiSkinTone.normal);

      EmojiRepository.reset();
      final lightRepo = EmojiRepository(skinTone: EmojiSkinTone.light);

      EmojiRepository.reset();
      final mediumRepo = EmojiRepository(skinTone: EmojiSkinTone.medium);

      // The emoji list will be different based on skin tone
      final normalEmojis = normalRepo.search('hand');
      final lightEmojis = lightRepo.search('hand');
      final mediumEmojis = mediumRepo.search('hand');

      // We can't make specific assertions about the content
      // since we don't know the exact emoji list, but we can check
      // that different skin tones yield different results
      expect(normalEmojis.length, isNot(equals(0)), reason: 'Should find some hand emoji');

      // Some emoji might appear in multiple repositories due to how the repository works,
      // but we should have distinct characters in each repo's results
      if (lightEmojis.isNotEmpty && mediumEmojis.isNotEmpty) {
        // Compare character sets - at least some emoji should be different
        final lightChars = lightEmojis.map((e) => e.char).toSet();
        final mediumChars = mediumEmojis.map((e) => e.char).toSet();

        expect(
          lightChars,
          isNot(equals(mediumChars)),
          reason: 'Different skin tone repositories should have at least some different emoji',
        );

        // Note: There may be some overlap due to emoji that don't support skin tones
        // so we don't check that the intersection is empty
      }
    });

    test('byGroup returns categories for specific skin tone', () {
      EmojiRepository.reset();
      final normalRepo = EmojiRepository(skinTone: EmojiSkinTone.normal);

      EmojiRepository.reset();
      final lightRepo = EmojiRepository(skinTone: EmojiSkinTone.light);

      final normalGroups = normalRepo.byGroup();
      final lightGroups = lightRepo.byGroup();

      // Both should have categories
      expect(normalGroups.keys, isNotEmpty);
      expect(lightGroups.keys, isNotEmpty);

      // Most common categories should be present
      expect(normalGroups.keys.contains('Smileys & People'), isTrue);
      expect(lightGroups.keys.contains('Smileys & People'), isTrue);
    });
  });
}
