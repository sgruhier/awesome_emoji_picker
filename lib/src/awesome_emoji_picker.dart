import 'package:awesome_emoji_picker/src/widgets/emoji_widget.dart';
import 'package:flutter/material.dart';

import 'emoji_repository.dart';
import 'model/emoji_model.dart';
import 'widgets/category_bar_widget.dart';
import 'widgets/emoji_grid_view.dart';
import 'widgets/search_field_widget.dart';
import 'widgets/search_results_widget.dart';

/// A widget that displays a grid of emoji organized by categories with search functionality.
///
/// This widget provides a complete emoji picker UI including:
/// - Emoji grid organized by categories
/// - Category navigation bar
/// - Search functionality
/// - Recently used emoji tracking
/// - Skin tone support
class AwesomeEmojiPicker extends StatefulWidget {
  /// Creates an emoji picker with customizable appearance and behavior.
  ///
  /// The [onEmojiSelected] callback is required and will be called when an emoji is tapped.
  const AwesomeEmojiPicker({
    super.key,
    required this.onEmojiSelected,
    this.emojiRenderer,
    this.emojiSize = 28,
    this.cellSize = 40,
    this.iconSize = 24,
    this.categoryTranslations,
    this.searchHintText = 'Search',
    this.searchResultsText = 'Search Results',
    this.categoryIconColor,
    this.categoryIconSelectedColor,
    this.categoryBarPadding,
    this.categoryBarHeight,
    this.skinTone = EmojiSkinTone.normal,
    this.skinToneLabel = 'Skin Tone',
  });

  /// Callback that is called when the user selects an emoji.
  final void Function(EmojiModel) onEmojiSelected;

  /// The size of emoji characters in logical pixels.
  final double emojiSize;

  /// The size of each emoji grid cell in logical pixels.
  final double cellSize;

  /// The size of the category icons in logical pixels.
  final double iconSize;

  /// Optional map of category translations.
  ///
  /// Keys should match the default English category names, and values should be the translated names.
  /// For example: {'Recents': 'Récents', 'Smileys & People': 'Émoticônes et personnes', ...}
  ///
  final Map<String, String>? categoryTranslations;

  /// The hint text displayed in the search input field.
  final String searchHintText;

  /// The text displayed above the search results.
  final String searchResultsText;

  /// The color of the category icons when not selected.
  final Color? categoryIconColor;

  /// The color of the category icons when selected.
  final Color? categoryIconSelectedColor;

  /// The padding around the category bar.
  final EdgeInsets? categoryBarPadding;

  /// The height of the category bar in logical pixels.
  final double? categoryBarHeight;

  /// The skin tone to use for emoji that support skin tone modifiers.
  final EmojiSkinTone skinTone;

  /// The label text for the skin tone selection.
  final String skinToneLabel;

  /// The widget to render the emoji.
  final Widget Function(EmojiModel)? emojiRenderer;

  @override
  State<AwesomeEmojiPicker> createState() => _AwesomeEmojiPickerState();
}

class _AwesomeEmojiPickerState extends State<AwesomeEmojiPicker> {
  // Data sources
  late EmojiRepository _repository;

  // Search state
  String _query = '';

  // Category sections (fixed order)
  static const List<String> _defaultCategories = [
    "Recents",
    'Smileys & People',
    'Animals & Nature',
    'Food & Drink',
    'Activities',
    'Travel & Places',
    'Objects',
    'Symbols',
    'Flags',
  ];

  static const List<String> _kCategorieIcons = [
    'recently_used.svg',
    'smileys_emotion.svg',
    'animals_nature.svg',
    'food_drink.svg',
    'activities.svg',
    'travel_places.svg',
    'objects.svg',
    'symbols.svg',
    'flags.svg',
  ];

  Map<String, List<EmojiModel>> _emojiByCategory = {};

  int _selectedCategoryIndex = 0;
  String _currentSection = '';
  String? _pendingScrollToCategory;

  // Map to store the starting position of each category
  final Map<String, double> _categoryOffsets = {};

  late final Map<String, GlobalKey> _headerKeys;
  final GlobalKey _scrollViewKey = GlobalKey();

  // Get the category name with translation if available
  String _getCategoryName(String defaultName) {
    return widget.categoryTranslations?[defaultName] ?? defaultName;
  }

  // Get the list of categories, using the default order
  List<String> get _categories => _defaultCategories;

  @override
  void initState() {
    super.initState();
    // Prepare category header keys
    _headerKeys = {for (var cat in _categories) cat: GlobalKey()};

    _repository = EmojiRepository(skinTone: widget.skinTone);

    // Register for repository changes (for recent emoji updates)
    _repository.addListener(_onRepositoryChanged);

    // Load emoji list, then rebuild
    _buildFlatEmojiList().then((_) {
      setState(() {}); // Rebuild when map is ready
    });
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  // Called when the repository notifies listeners (e.g., when recent emoji list changes)
  void _onRepositoryChanged() {
    setState(() {
      // Update the "Recents" category with fresh data
      _emojiByCategory['Recents'] = _repository.recentEmojis;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool searching = _query.trim().isNotEmpty;

    // Update category offsets after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCategoryOffsets();
    });

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchFieldWidget(
            query: _query,
            onChanged: (v) => setState(() => _query = v),
            hintText: widget.searchHintText,
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!searching) ...[
            _buildCategoryBar(context),
          ],
          Expanded(
            child: searching ? _buildSearchResults(context) : _buildGrid(),
          ),
        ],
      ),
    );
  }

  // Initialize _categoryOffsets during build
  void _updateCategoryOffsets() {
    _categoryOffsets.clear();
    double offset = 0.0;

    for (final category in _categories) {
      _categoryOffsets[category] = offset;

      final count = _emojiByCategory[category]?.length ?? 0;
      final screenWidth = MediaQuery.of(context).size.width;
      final perRow = (screenWidth / widget.cellSize).floor();
      final rows = (count / perRow).ceil();
      final gridHeight = rows * widget.cellSize;

      const headerHeight = 30.0;
      const sectionSpacing = 6.0; // Bottom padding of SliverPadding

      offset += headerHeight + gridHeight + sectionSpacing;
    }
  }

  /// Builds the complete emoji list organized by category
  Future<void> _buildFlatEmojiList() async {
    final byGroup = _repository.byGroup();

    // Repository already loads recent emoji in its constructor
    final newMap = <String, List<EmojiModel>>{};
    for (final cat in _categories) {
      if (cat == 'Recents') {
        newMap[cat] = _repository.recentEmojis;
      } else {
        newMap[cat] = (byGroup[cat] ?? []);
      }
    }
    _emojiByCategory = newMap;

    // Recalculate after new content is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCategoryOffsets();
    });
  }

  /// Builds the emoji grid with category headers
  Widget _buildGrid() {
    return EmojiGridView(
      emojiByCategory: _emojiByCategory,
      headerKeys: _headerKeys,
      scrollViewKey: _scrollViewKey,
      getCategoryName: _getCategoryName,
      emojiSize: widget.emojiSize,
      cellSize: widget.cellSize,
      onEmojiTap: _onEmojiTap,
      headerBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      headerTextStyle: Theme.of(context).textTheme.titleMedium,
      onScroll: (section) {
        final idx = _categories.indexOf(section);
        if (section != _currentSection || idx != _selectedCategoryIndex) {
          setState(() {
            _currentSection = section;
            _selectedCategoryIndex = idx;
          });
        }
      },
      scrollToCategory: _pendingScrollToCategory,
      categoryBarHeight: widget.categoryBarHeight ?? 30,
      emojiRenderer: widget.emojiRenderer ?? _buildEmojiRenderer,
    );
  }

  /// Builds the category selection bar
  Widget _buildCategoryBar(BuildContext context) {
    return CategoryBarWidget(
      padding: widget.categoryBarPadding,
      categories: _categories,
      selectedIndex: _selectedCategoryIndex,
      onSkinToneTap: (skinTone) {
        _repository = EmojiRepository(skinTone: skinTone);
        _repository.addListener(_onRepositoryChanged);
        _buildFlatEmojiList().then((_) {
          setState(() {});
        });
      },
      onCategoryTap: (i) {
        setState(() {
          _selectedCategoryIndex = i;
          _currentSection = _categories[i];
          _pendingScrollToCategory = _categories[i];
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _pendingScrollToCategory = null;
            });
          }
        });
      },
      iconSize: widget.iconSize,
      iconPaths: _kCategorieIcons,
      iconColor: widget.categoryIconColor ?? Theme.of(context).colorScheme.primary,
      iconSelectedColor: widget.categoryIconSelectedColor ?? Theme.of(context).colorScheme.secondary,
      skinToneLabel: widget.skinToneLabel,
    );
  }

  /// Builds the search results view
  Widget _buildSearchResults(BuildContext context) {
    final results = _repository.search(_query.trim());
    return SearchResultsWidget(
      results: results,
      onEmojiTap: _onEmojiTap,
      cellSize: widget.cellSize,
      emojiSize: widget.emojiSize,
      searchResultsText: widget.searchResultsText,
      textStyle: Theme.of(context).textTheme.titleMedium,
      headerBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      categoryBarHeight: widget.categoryBarHeight ?? 30,
      emojiRenderer: widget.emojiRenderer ?? _buildEmojiRenderer,
    );
  }

  /// Handles emoji tap events
  void _onEmojiTap(EmojiModel e) {
    // 1) Send emoji to parent
    widget.onEmojiSelected(e);

    // 2) Add to "recent" list in repository
    _repository.addToRecent(e);
  }

  Widget _buildEmojiRenderer(EmojiModel emoji) {
    return EmojiWidget(emoji: emoji, emojiSize: widget.emojiSize);
  }
}
