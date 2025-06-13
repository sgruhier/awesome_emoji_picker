import 'package:awesome_emoji_picker/src/widgets/emoji_widget.dart';
import 'package:flutter/material.dart';

import '../model/emoji_model.dart';

class EmojiGridView extends StatefulWidget {
  final Map<String, List<EmojiModel>> emojiByCategory;
  final Map<String, GlobalKey> headerKeys;
  final GlobalKey scrollViewKey;
  final String Function(String) getCategoryName;
  final double emojiSize;
  final double cellSize;
  final void Function(EmojiModel) onEmojiTap;
  final Color? headerBackgroundColor;
  final TextStyle? headerTextStyle;
  final void Function(String section)? onScroll;
  final String? scrollToCategory;
  final double? categoryBarHeight;
  final Widget Function(EmojiModel)? emojiRenderer;
  const EmojiGridView({
    super.key,
    required this.emojiByCategory,
    required this.headerKeys,
    required this.scrollViewKey,
    required this.getCategoryName,
    required this.emojiSize,
    required this.cellSize,
    required this.onEmojiTap,
    required this.emojiRenderer,
    this.headerBackgroundColor,
    this.headerTextStyle,
    this.onScroll,
    this.scrollToCategory,
    this.categoryBarHeight = 30,
  });

  @override
  State<EmojiGridView> createState() => _EmojiGridViewState();
}

class _EmojiGridViewState extends State<EmojiGridView> {
  late final ScrollController _scrollController;
  String? _lastSection;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollToCategory != null) {
        _scrollToCategory(widget.scrollToCategory!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EmojiGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollToCategory != null && widget.scrollToCategory != oldWidget.scrollToCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCategory(widget.scrollToCategory!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      key: widget.scrollViewKey,
      slivers: [
        for (final category in widget.emojiByCategory.keys)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SectionHeaderDelegate(
                  child: Container(
                    key: widget.headerKeys[category],
                    color: widget.headerBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.getCategoryName(category),
                      style: widget.headerTextStyle ?? Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  minHeight: widget.categoryBarHeight ?? 30,
                  maxHeight: widget.categoryBarHeight ?? 30,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 6),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final e = widget.emojiByCategory[category]![i];
                    return GestureDetector(
                      onTap: () => widget.onEmojiTap(e),
                      child: widget.emojiRenderer?.call(e) ?? EmojiWidget(emoji: e, emojiSize: widget.emojiSize),
                    );
                  }, childCount: widget.emojiByCategory[category]!.length),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: widget.cellSize,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    childAspectRatio: 1,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _onScroll() {
    final scrollContext = widget.scrollViewKey.currentContext;
    if (scrollContext == null) return;
    final scrollBox = scrollContext.findRenderObject() as RenderBox;
    final scrollTopGlobalY = scrollBox.localToGlobal(Offset.zero).dy;

    String? newSection;
    for (final cat in widget.emojiByCategory.keys) {
      final key = widget.headerKeys[cat];
      final ctx = key?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox;
      final headerGlobalY = box.localToGlobal(Offset.zero).dy;
      final headerLocalY = headerGlobalY - scrollTopGlobalY;
      if (headerLocalY <= 0 + 0.1) {
        newSection = cat;
      } else {
        break;
      }
    }
    if (newSection != null && newSection != _lastSection) {
      _lastSection = newSection;
      if (widget.onScroll != null) {
        widget.onScroll!(newSection);
      }
    }
  }

  Future<void> _scrollToCategory(String category) async {
    final ctx = widget.headerKeys[category]?.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
      alignment: 0.0,
    );
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.offset - 2);
    }
  }
}

/// Delegate to manage sticky header size and position (copied from awesome_emoji_picker.dart)
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SectionHeaderDelegate({required this.child, required this.minHeight, required this.maxHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight || oldDelegate.maxHeight != maxHeight || oldDelegate.child != child;
  }
}
