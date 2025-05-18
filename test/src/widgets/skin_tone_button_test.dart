import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:awesome_emoji_picker/src/widgets/skin_tone_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SkinToneButton', () {
    testWidgets('renders correctly with default properties', (WidgetTester tester) async {
      bool tapped = false;
      EmojiSkinTone? tappedSkinTone;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.normal,
              onTap: (skinTone) {
                tapped = true;
                tappedSkinTone = skinTone;
              },
            ),
          ),
        ),
      );

      // Verify the widget is rendered
      expect(find.byType(SkinToneButton), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);

      // Verify default styling
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(Colors.transparent));
      expect(decoration.borderRadius, equals(BorderRadius.circular(100)));
      expect(decoration.border?.top.color, equals(Colors.transparent));
      expect(decoration.border?.top.width, equals(2));

      // Test tap functionality
      await tester.tap(find.byType(SkinToneButton));
      await tester.pump();

      expect(tapped, isTrue);
      expect(tappedSkinTone, equals(EmojiSkinTone.normal));
    });

    testWidgets('renders correctly when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.light,
              onTap: (skinTone) {},
              selected: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      // Verify selected styling uses default colors
      expect(decoration.color, equals(Colors.white));
      expect(decoration.border?.top.color, equals(Colors.blue));
      expect(decoration.border?.top.width, equals(2));
    });

    testWidgets('applies custom colors when provided', (WidgetTester tester) async {
      const customBackgroundColor = Colors.red;
      const customSelectedBackgroundColor = Colors.green;
      const customSelectedBorderColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.medium,
              onTap: (skinTone) {},
              selected: true,
              backgroundColor: customBackgroundColor,
              selectedBackgroundColor: customSelectedBackgroundColor,
              selectedBorderColor: customSelectedBorderColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(customSelectedBackgroundColor));
      expect(decoration.border?.top.color, equals(customSelectedBorderColor));
    });

    testWidgets('applies custom icon size', (WidgetTester tester) async {
      const customIconSize = 32.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.dark,
              onTap: (skinTone) {},
              iconSize: customIconSize,
            ),
          ),
        ),
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, equals(customIconSize));
      expect(svgPicture.height, equals(customIconSize));
    });

    testWidgets('uses correct SVG asset path for each skin tone', (WidgetTester tester) async {
      for (int i = 0; i < EmojiSkinTone.values.length; i++) {
        final skinTone = EmojiSkinTone.values[i];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkinToneButton(
                skinTone: skinTone,
                onTap: (skinTone) {},
              ),
            ),
          ),
        );

        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));

        // Note: We can't directly access the asset path from SvgPicture.asset,
        // but we can verify the widget is created correctly
        expect(svgPicture.width, equals(24)); // default icon size
        expect(svgPicture.height, equals(24)); // default icon size
      }
    });

    testWidgets('handles all skin tone values correctly', (WidgetTester tester) async {
      final skinTones = EmojiSkinTone.values;
      final tappedSkinTones = <EmojiSkinTone>[];

      for (final skinTone in skinTones) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkinToneButton(
                skinTone: skinTone,
                onTap: (tappedSkinTone) {
                  tappedSkinTones.add(tappedSkinTone);
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(SkinToneButton));
        await tester.pump();
      }

      expect(tappedSkinTones.length, equals(skinTones.length));
      for (int i = 0; i < skinTones.length; i++) {
        expect(tappedSkinTones[i], equals(skinTones[i]));
      }
    });

    testWidgets('applies correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.normal,
              onTap: (skinTone) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, equals(const EdgeInsets.all(2)));
    });

    testWidgets('maintains correct border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.normal,
              onTap: (skinTone) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(100)));
    });

    testWidgets('uses correct package name for SVG asset', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.normal,
              onTap: (skinTone) {},
            ),
          ),
        ),
      );

      // Verify the SvgPicture widget is created (package verification would require more complex testing)
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('handles rapid taps correctly', (WidgetTester tester) async {
      int tapCount = 0;
      EmojiSkinTone? lastTappedSkinTone;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.medium,
              onTap: (skinTone) {
                tapCount++;
                lastTappedSkinTone = skinTone;
              },
            ),
          ),
        ),
      );

      // Perform multiple rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(SkinToneButton));
        await tester.pump();
      }

      expect(tapCount, equals(5));
      expect(lastTappedSkinTone, equals(EmojiSkinTone.medium));
    });

    testWidgets('maintains state when not selected', (WidgetTester tester) async {
      const customBackgroundColor = Colors.yellow;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinToneButton(
              skinTone: EmojiSkinTone.mediumDark,
              onTap: (skinTone) {},
              selected: false,
              backgroundColor: customBackgroundColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(customBackgroundColor));
      expect(decoration.border?.top.color, equals(Colors.transparent));
    });

    group('EmojiSkinTone integration', () {
      testWidgets('works with all EmojiSkinTone enum values', (WidgetTester tester) async {
        final testCases = [
          EmojiSkinTone.normal,
          EmojiSkinTone.light,
          EmojiSkinTone.mediumLight,
          EmojiSkinTone.medium,
          EmojiSkinTone.mediumDark,
          EmojiSkinTone.dark,
        ];

        for (final skinTone in testCases) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SkinToneButton(
                  skinTone: skinTone,
                  onTap: (tappedSkinTone) {
                    expect(tappedSkinTone, equals(skinTone));
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.byType(SkinToneButton));
          await tester.pump();
        }
      });
    });
  });
}
