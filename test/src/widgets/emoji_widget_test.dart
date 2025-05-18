// test/emoji_widget_test.dart
import 'package:awesome_emoji_picker/src/model/emoji_model.dart';
import 'package:awesome_emoji_picker/src/widgets/emoji_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmojiWidget displays emoji correctly', (WidgetTester tester) async {
    // Create an EmojiModel instance
    final emoji = EmojiModel('😊', 'grinning face', 'smileys & emotion');

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmojiWidget(emoji: emoji),
        ),
      ),
    );

    // Verify that the text containing the emoji is displayed
    expect(find.text('😊'), findsOneWidget);
  });

  testWidgets('EmojiWidget applies correct font size', (WidgetTester tester) async {
    // Create an EmojiModel instance with a specific font size
    final emoji = EmojiModel('😊', 'grinning face', 'smileys & emotion');

    // Build the widget tree with a custom emojiSize
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmojiWidget(emoji: emoji, emojiSize: 48),
        ),
      ),
    );

    // Verify that the text has the correct font size
    final textWidget = find.byType(Text);
    expect(textWidget, findsOneWidget);

    final textStyle = (tester.firstWidget(textWidget) as Text).style;
    expect(textStyle?.fontSize, 48.0);
  });
}
