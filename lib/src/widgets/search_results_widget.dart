import 'package:flutter/material.dart';

import '../model/emoji_model.dart';
import 'emoji_grid_view.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<EmojiModel> results;
  final void Function(EmojiModel) onEmojiTap;
  final double cellSize;
  final double emojiSize;
  final String searchResultsText;
  final TextStyle? textStyle;
  final Color headerBackgroundColor;
  final double categoryBarHeight;
  final Widget Function(EmojiModel)? emojiRenderer;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.onEmojiTap,
    required this.cellSize,
    required this.emojiSize,
    required this.searchResultsText,
    required this.headerBackgroundColor,
    required this.categoryBarHeight,
    required this.emojiRenderer,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Group all results under a single category
    final Map<String, List<EmojiModel>> emojiByCategory = {
      searchResultsText: results,
    };
    final Map<String, GlobalKey> headerKeys = {
      searchResultsText: GlobalKey(),
    };
    final GlobalKey scrollViewKey = GlobalKey();
    String getCategoryName(String name) => name;

    return EmojiGridView(
      emojiByCategory: emojiByCategory,
      headerKeys: headerKeys,
      scrollViewKey: scrollViewKey,
      getCategoryName: getCategoryName,
      emojiSize: emojiSize,
      cellSize: cellSize,
      onEmojiTap: onEmojiTap,
      headerBackgroundColor: headerBackgroundColor,
      headerTextStyle: textStyle ?? Theme.of(context).textTheme.titleMedium,
      categoryBarHeight: categoryBarHeight,
      emojiRenderer: emojiRenderer,
    );
  }
}
