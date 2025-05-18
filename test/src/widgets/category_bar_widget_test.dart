import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:awesome_emoji_picker/src/widgets/category_bar_widget.dart';
import 'package:awesome_emoji_picker/src/widgets/skin_tone_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryBarWidget', () {
    late List<String> categories;
    late List<String> iconPaths;
    late int selectedIndex;
    late ValueChanged<int> onCategoryTap;
    late ValueChanged<EmojiSkinTone> onSkinToneTap;

    setUp(() {
      categories = ['Smileys', 'Animals', 'Food', 'Activities'];
      iconPaths = [
        'smileys_emotion.svg',
        'animals_nature.svg',
        'food_drink.svg',
        'activities.svg',
      ];
      selectedIndex = 0;
      onCategoryTap = (_) {};
      onSkinToneTap = (_) {};
    });

    Widget createWidget({
      List<String>? customCategories,
      int? customSelectedIndex,
      ValueChanged<int>? customOnCategoryTap,
      ValueChanged<EmojiSkinTone>? customOnSkinToneTap,
      double? iconSize,
      Color? iconColor,
      Color? iconSelectedColor,
      EdgeInsets? padding,
      TextStyle? headerTextStyle,
      String? skinToneLabel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CategoryBarWidget(
            categories: customCategories ?? categories,
            selectedIndex: customSelectedIndex ?? selectedIndex,
            onCategoryTap: customOnCategoryTap ?? onCategoryTap,
            onSkinToneTap: customOnSkinToneTap ?? onSkinToneTap,
            iconSize: iconSize ?? 24,
            iconPaths: iconPaths,
            iconColor: iconColor ?? Colors.grey,
            iconSelectedColor: iconSelectedColor ?? Colors.blue,
            padding: padding,
            headerTextStyle: headerTextStyle,
            skinToneLabel: skinToneLabel ?? 'Skin Tone',
          ),
        ),
      );
    }

    testWidgets('renders all category icons', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Should render all category icons
      expect(find.byType(SvgPicture), findsNWidgets(categories.length + EmojiSkinTone.values.length + 1));

      // Should render all skin tone buttons (1 main + 6 options, always present)
      expect(find.byType(SkinToneButton), findsNWidgets(EmojiSkinTone.values.length + 1));
    });

    testWidgets('highlights selected category', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(customSelectedIndex: 1));

      // The second category should be selected
      final svgWidgets = tester.widgetList<SvgPicture>(find.byType(SvgPicture)).toList();

      // Check that the selected icon has the selected color
      expect(svgWidgets[1].colorFilter, ColorFilter.mode(Colors.blue, BlendMode.srcIn));

      // Check that other icons have the normal color
      expect(svgWidgets[0].colorFilter, ColorFilter.mode(Colors.grey, BlendMode.srcIn));
      expect(svgWidgets[2].colorFilter, ColorFilter.mode(Colors.grey, BlendMode.srcIn));
    });

    testWidgets('calls onCategoryTap when category is tapped', (WidgetTester tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        createWidget(
          customOnCategoryTap: (index) => tappedIndex = index,
        ),
      );

      // Tap the second category
      await tester.tap(find.byType(SvgPicture).at(1));
      await tester.pump();

      expect(tappedIndex, 1);

      // Tap the third category
      await tester.tap(find.byType(SvgPicture).at(2));
      await tester.pump();

      expect(tappedIndex, 2);
    });

    testWidgets('shows skin tone selector when skin tone button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // All skin tone buttons are always present (1 main + 6 options)
      expect(find.byType(SkinToneButton), findsNWidgets(7));

      // Initially, the skin tone selector should be hidden (heightFactor = 0)
      final animatedAlign = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(animatedAlign.heightFactor, 0);

      // Tap the skin tone button
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      // Now the skin tone selector should be visible (heightFactor = 1)
      final animatedAlignAfter = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(animatedAlignAfter.heightFactor, 1);

      // Should show the skin tone label
      expect(find.text('Skin Tone'), findsOneWidget);
    });

    testWidgets('hides skin tone selector when tapped again', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Show skin tone selector
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      final animatedAlignShown = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(animatedAlignShown.heightFactor, 1);

      // Hide skin tone selector
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      final animatedAlignHidden = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(animatedAlignHidden.heightFactor, 0);
    });

    testWidgets('calls onSkinToneTap when skin tone is selected', (WidgetTester tester) async {
      EmojiSkinTone? selectedSkinTone;
      await tester.pumpWidget(
        createWidget(
          customOnSkinToneTap: (skinTone) => selectedSkinTone = skinTone,
        ),
      );

      // Show skin tone selector
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      // Select the second skin tone (index 1)
      final skinToneButtons = find.byType(SkinToneButton);
      await tester.tap(skinToneButtons.at(2)); // Skip the main button
      await tester.pump();

      expect(selectedSkinTone, EmojiSkinTone.values[1]);
    });

    testWidgets('updates selected skin tone visually', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Show skin tone selector
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      // Select a different skin tone
      final skinToneButtons = find.byType(SkinToneButton);
      await tester.tap(skinToneButtons.at(3)); // Select skin tone at index 2
      await tester.pump();

      // The main skin tone button should now show the selected skin tone
      final mainButton = tester.widget<SkinToneButton>(skinToneButtons.first);
      expect(mainButton.skinTone, EmojiSkinTone.values[2]);
    });

    testWidgets('applies custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(16.0);
      await tester.pumpWidget(createWidget(padding: customPadding));

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, customPadding);
    });

    testWidgets('applies custom icon size', (WidgetTester tester) async {
      const customIconSize = 32.0;
      await tester.pumpWidget(createWidget(iconSize: customIconSize));

      // Check category icons have the custom size
      final svgWidgets = tester.widgetList<SvgPicture>(find.byType(SvgPicture)).toList();
      // First 4 SVGs are category icons
      for (int i = 0; i < categories.length; i++) {
        expect(svgWidgets[i].width, customIconSize);
        expect(svgWidgets[i].height, customIconSize);
      }

      // The main skin tone button should have size - 4
      final mainSkinToneButton = tester.widget<SkinToneButton>(find.byType(SkinToneButton).first);
      expect(mainSkinToneButton.iconSize, customIconSize - 4);
    });

    testWidgets('applies custom colors', (WidgetTester tester) async {
      const customIconColor = Colors.red;
      const customSelectedColor = Colors.green;

      await tester.pumpWidget(
        createWidget(
          iconColor: customIconColor,
          iconSelectedColor: customSelectedColor,
          customSelectedIndex: 1,
        ),
      );

      final svgWidgets = tester.widgetList<SvgPicture>(find.byType(SvgPicture)).toList();

      // Check unselected icons have custom color
      expect(svgWidgets[0].colorFilter, ColorFilter.mode(customIconColor, BlendMode.srcIn));

      // Check selected icon has custom selected color
      expect(svgWidgets[1].colorFilter, ColorFilter.mode(customSelectedColor, BlendMode.srcIn));
    });

    testWidgets('applies custom header text style', (WidgetTester tester) async {
      const customTextStyle = TextStyle(fontSize: 20, color: Colors.red);
      await tester.pumpWidget(
        createWidget(
          headerTextStyle: customTextStyle,
        ),
      );

      // Show skin tone selector to see the header
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Skin Tone'));
      expect(textWidget.style, customTextStyle);
    });

    testWidgets('uses custom skin tone label', (WidgetTester tester) async {
      const customLabel = 'Couleur de peau';
      await tester.pumpWidget(
        createWidget(
          skinToneLabel: customLabel,
        ),
      );

      // Show skin tone selector
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      expect(find.text(customLabel), findsOneWidget);
    });

    testWidgets('skin tone selector animates smoothly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Find the AnimatedAlign widget
      final animatedAlign = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(animatedAlign.duration, const Duration(milliseconds: 300));
      expect(animatedAlign.heightFactor, 0);

      // Show skin tone selector
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pump();

      // Check that animation has started
      final animatedAlignAfter = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(animatedAlignAfter.heightFactor, 1);
    });

    testWidgets('maintains state when rebuilt', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Show skin tone selector
      await tester.tap(find.byType(SkinToneButton).first);
      await tester.pumpAndSettle();

      // Select a skin tone
      final skinToneButtons = find.byType(SkinToneButton);
      await tester.tap(skinToneButtons.at(3));
      await tester.pump();

      // Rebuild the widget
      await tester.pumpWidget(createWidget());

      // The skin tone selector should still be visible (heightFactor = 1)
      final animatedAlign = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(animatedAlign.heightFactor, 1);

      // The selected skin tone should be maintained
      final mainButton = tester.widget<SkinToneButton>(find.byType(SkinToneButton).first);
      expect(mainButton.skinTone, EmojiSkinTone.values[2]);
    });

    testWidgets('skin tone button has correct size relative to icon size', (WidgetTester tester) async {
      const customIconSize = 32.0;
      await tester.pumpWidget(createWidget(iconSize: customIconSize));

      final allSkinToneButtons = tester.widgetList<SkinToneButton>(find.byType(SkinToneButton)).toList();

      // The main skin tone button (first one) should have size - 4
      expect(allSkinToneButtons[0].iconSize, customIconSize - 4);

      // The skin tone option buttons (rest) should have the full icon size
      for (int i = 1; i < allSkinToneButtons.length; i++) {
        expect(allSkinToneButtons[i].iconSize, customIconSize);
      }
    });
  });
}
