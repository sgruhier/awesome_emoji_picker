import 'package:awesome_emoji_picker/src/model/emoji_model.dart';
import 'package:flutter/material.dart';

class EmojiWidget extends StatelessWidget {
  const EmojiWidget({super.key, required this.emoji, this.emojiSize = 24});

  final EmojiModel emoji;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(emoji.char, style: TextStyle(fontSize: emojiSize)),
    );
  }
}
