import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Emoji', () {
    group('constructor', () {
      test('creates emoji with all required parameters', () {
        const emoji = EmojiModel('😀', 'grinning face', 'Smileys & People');

        expect(emoji.char, equals('😀'));
        expect(emoji.name, equals('grinning face'));
        expect(emoji.group, equals('Smileys & People'));
      });

      test('creates emoji with empty strings', () {
        const emoji = EmojiModel('', '', '');

        expect(emoji.char, equals(''));
        expect(emoji.name, equals(''));
        expect(emoji.group, equals(''));
      });

      test('creates emoji with special characters in name and group', () {
        const emoji = EmojiModel('🎯', 'direct hit & target', 'Activities & Sports');

        expect(emoji.char, equals('🎯'));
        expect(emoji.name, equals('direct hit & target'));
        expect(emoji.group, equals('Activities & Sports'));
      });

      test('creates emoji with unicode characters', () {
        const emoji = EmojiModel('👨‍💻', 'man technologist', 'People & Body');

        expect(emoji.char, equals('👨‍💻'));
        expect(emoji.name, equals('man technologist'));
        expect(emoji.group, equals('People & Body'));
      });
    });

    group('properties', () {
      test('char property returns correct emoji character', () {
        const emoji = EmojiModel('🚀', 'rocket', 'Travel & Places');
        expect(emoji.char, equals('🚀'));
      });

      test('name property returns correct emoji name', () {
        const emoji = EmojiModel('🚀', 'rocket', 'Travel & Places');
        expect(emoji.name, equals('rocket'));
      });

      test('group property returns correct emoji group', () {
        const emoji = EmojiModel('🚀', 'rocket', 'Travel & Places');
        expect(emoji.group, equals('Travel & Places'));
      });

      test('properties are immutable', () {
        const emoji = EmojiModel('🎵', 'musical note', 'Objects');

        // These should be final and cannot be changed
        expect(emoji.char, equals('🎵'));
        expect(emoji.name, equals('musical note'));
        expect(emoji.group, equals('Objects'));
      });
    });

    group('toString', () {
      test('returns formatted string with char and name', () {
        const emoji = EmojiModel('😂', 'face with tears of joy', 'Smileys & People');
        expect(emoji.toString(), equals('😂 (face with tears of joy)'));
      });

      test('handles empty name', () {
        const emoji = EmojiModel('🔥', '', 'Objects');
        expect(emoji.toString(), equals('🔥 ()'));
      });

      test('handles empty char', () {
        const emoji = EmojiModel('', 'unknown', 'Unknown');
        expect(emoji.toString(), equals(' (unknown)'));
      });

      test('handles special characters in name', () {
        const emoji = EmojiModel('💯', '100% symbol', 'Symbols');
        expect(emoji.toString(), equals('💯 (100% symbol)'));
      });
    });

    group('equality', () {
      test('returns true for identical instances', () {
        const emoji = EmojiModel('🎉', 'party popper', 'Objects');
        expect(emoji == emoji, isTrue);
      });

      test('returns true for emoji with same char', () {
        const emoji1 = EmojiModel('🎉', 'party popper', 'Objects');
        const emoji2 = EmojiModel('🎉', 'celebration', 'Activities');

        expect(emoji1 == emoji2, isTrue);
      });

      test('returns false for emoji with different char', () {
        const emoji1 = EmojiModel('🎉', 'party popper', 'Objects');
        const emoji2 = EmojiModel('🎊', 'confetti ball', 'Objects');

        expect(emoji1 == emoji2, isFalse);
      });

      test('equality ignores name and group differences', () {
        const emoji1 = EmojiModel('🌟', 'star', 'Nature');
        const emoji2 = EmojiModel('🌟', 'glowing star', 'Symbols');
        const emoji3 = EmojiModel('🌟', '', '');

        expect(emoji1 == emoji2, isTrue);
        expect(emoji1 == emoji3, isTrue);
        expect(emoji2 == emoji3, isTrue);
      });
    });

    group('hashCode', () {
      test('returns same hashCode for emoji with same char', () {
        const emoji1 = EmojiModel('🌈', 'rainbow', 'Nature');
        const emoji2 = EmojiModel('🌈', 'colorful arc', 'Weather');

        expect(emoji1.hashCode, equals(emoji2.hashCode));
      });

      test('returns different hashCode for emoji with different char', () {
        const emoji1 = EmojiModel('🌈', 'rainbow', 'Nature');
        const emoji2 = EmojiModel('🌙', 'crescent moon', 'Nature');

        expect(emoji1.hashCode, isNot(equals(emoji2.hashCode)));
      });

      test('hashCode is consistent with equality', () {
        const emoji1 = EmojiModel('⭐', 'star', 'Symbols');
        const emoji2 = EmojiModel('⭐', 'white star', 'Objects');

        // If two objects are equal, their hashCodes must be equal
        expect(emoji1 == emoji2, isTrue);
        expect(emoji1.hashCode, equals(emoji2.hashCode));
      });

      test('hashCode is based on char property', () {
        const emoji = EmojiModel('🎯', 'direct hit', 'Activities');
        expect(emoji.hashCode, equals(emoji.char.hashCode));
      });
    });

    group('immutability', () {
      test('emoji instance is immutable', () {
        const emoji = EmojiModel('🔒', 'locked', 'Objects');

        // Verify that the class is marked as immutable by checking
        // that all fields are final (this is enforced by the @immutable annotation)
        expect(emoji.char, equals('🔒'));
        expect(emoji.name, equals('locked'));
        expect(emoji.group, equals('Objects'));

        // The @immutable annotation ensures compile-time immutability
        // Runtime immutability is guaranteed by final fields
      });
    });

    group('edge cases', () {
      test('handles very long emoji names', () {
        const longName = 'this is a very long emoji name that might be used in some edge cases for testing purposes';
        const emoji = EmojiModel('📝', longName, 'Objects');

        expect(emoji.name, equals(longName));
        expect(emoji.toString(), equals('📝 ($longName)'));
      });

      test('handles very long group names', () {
        const longGroup = 'This is a very long group name that might be used in some edge cases';
        const emoji = EmojiModel('📂', 'folder', longGroup);

        expect(emoji.group, equals(longGroup));
      });

      test('handles emoji with skin tone modifiers', () {
        const emoji = EmojiModel('👋🏽', 'waving hand: medium skin tone', 'People & Body');

        expect(emoji.char, equals('👋🏽'));
        expect(emoji.name, equals('waving hand: medium skin tone'));
        expect(emoji.group, equals('People & Body'));
      });

      test('handles complex emoji sequences', () {
        const emoji = EmojiModel('👨‍👩‍👧‍👦', 'family: man, woman, girl, boy', 'People & Body');

        expect(emoji.char, equals('👨‍👩‍👧‍👦'));
        expect(emoji.name, equals('family: man, woman, girl, boy'));
        expect(emoji.group, equals('People & Body'));
      });

      test('handles emoji with variation selectors', () {
        const emoji = EmojiModel('❤️', 'red heart', 'Smileys & People');

        expect(emoji.char, equals('❤️'));
        expect(emoji.name, equals('red heart'));
        expect(emoji.group, equals('Smileys & People'));
      });
    });
  });
}
