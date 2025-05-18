import 'package:flutter/material.dart';
import 'emoji_repository.dart';
import 'recent_store.dart';
import 'model/emoji.dart';

typedef EmojiSelected = void Function(Emoji emoji);

class EmojiView extends StatefulWidget {
  const EmojiView({
    super.key,
    required this.onEmojiSelected,
    required this.repository,
    required this.recentStore,
    this.columns = 8,
    this.emojiSize = 28,
  });

  final EmojiSelected onEmojiSelected;
  final EmojiRepository repository;
  final RecentStore recentStore;
  final int columns;
  final double emojiSize;

  @override
  State<EmojiView> createState() => _EmojiViewState();
}

class _EmojiViewState extends State<EmojiView> with AutomaticKeepAliveClientMixin {
  late final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final groups = widget.repository.byGroup().entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final pages = <Widget>[];

    // Recent page
    if (widget.recentStore.codes.isNotEmpty) {
      final recentEmoji = widget.recentStore.codes
          .map((code) => widget.repository.search(code).firstWhere(
                (e) => e.char == code,
                orElse: () => Emoji(code, 'recent', 'recent', []),
              ))
          .toList();
      pages.add(_EmojiGrid(
        emoji: recentEmoji,
        onTap: _onTap,
        columns: widget.columns,
        emojiSize: widget.emojiSize,
      ));
    }

    // Category pages
    for (final entry in groups) {
      pages.add(_EmojiGrid(
        emoji: entry.value,
        onTap: _onTap,
        columns: widget.columns,
        emojiSize: widget.emojiSize,
      ));
    }

    return PageView(
      controller: pageController,
      children: pages,
    );
  }

  void _onTap(Emoji e) {
    widget.onEmojiSelected(e);
    widget.recentStore.add(e.char);
  }

  @override
  bool get wantKeepAlive => true;
}

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({
    required this.emoji,
    required this.onTap,
    required this.columns,
    required this.emojiSize,
  });

  final List<Emoji> emoji;
  final EmojiSelected onTap;
  final int columns;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
      ),
      itemCount: emoji.length,
      itemBuilder: (context, index) {
        final e = emoji[index];
        return InkWell(
          onTap: () => onTap(e),
          child: Center(
            child: Text(
              e.char,
              style: TextStyle(fontSize: emojiSize),
            ),
          ),
        );
      },
    );
  }
}
