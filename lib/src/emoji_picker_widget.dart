import 'package:flutter/material.dart';

import 'emoji_repository.dart';
import 'emoji_view.dart';
import 'recent_store.dart';
import 'search_field.dart';

/// High‑level wrapper widget.
class EmojiPicker extends StatefulWidget {
  const EmojiPicker({
    super.key,
    required this.onEmojiSelected,
    this.onBackspacePressed, // new

    this.columns = 8,
    this.emojiSize = 28,
  });

  /// Callback when the user taps an emoji.
  final EmojiSelected onEmojiSelected;

  final VoidCallback? onBackspacePressed; // new
  /// Grid columns on narrow screens.
  final int columns;

  /// Logical pixel size of emoji glyph.
  final double emojiSize;

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  late final repository = const EmojiRepository();
  late final recentStore = RecentStore();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: EmojiView(
            onEmojiSelected: (e) => widget.onEmojiSelected(e),
            repository: repository,
            recentStore: recentStore,
            columns: widget.columns,
            emojiSize: widget.emojiSize,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            final picked = await showSearch(
              context: context,
              delegate: EmojiSearchDelegate(repository),
            );
            if (picked != null) widget.onEmojiSelected(picked);
          },
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.backspace),
          onPressed: widget.onBackspacePressed,
        ),
      ],
    );
  }
}
