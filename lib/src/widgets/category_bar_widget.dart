import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:awesome_emoji_picker/src/widgets/skin_tone_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryBarWidget extends StatefulWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategoryTap;
  final ValueChanged<EmojiSkinTone> onSkinToneTap;

  final double iconSize;
  final List<String> iconPaths;
  final Color iconColor;
  final Color iconSelectedColor;
  final EdgeInsets? padding;
  final TextStyle? headerTextStyle;
  final String skinToneLabel;
  const CategoryBarWidget({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
    required this.onSkinToneTap,
    required this.iconSize,
    required this.iconPaths,
    required this.iconColor,
    required this.iconSelectedColor,
    this.padding,
    this.headerTextStyle,
    required this.skinToneLabel,
  });

  @override
  State<CategoryBarWidget> createState() => _CategoryBarWidgetState();
}

class _CategoryBarWidgetState extends State<CategoryBarWidget> {
  EmojiSkinTone selectedSkinTone = EmojiSkinTone.normal;
  bool showSkinTone = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconCount = widget.categories.length + 1;
        final spacing = 8.0; // Adjust if you use different spacing
        final iconTotalWidth =
            iconCount * widget.iconSize + (iconCount - 1) * spacing + (widget.padding?.horizontal ?? 16);
        final fits = iconTotalWidth <= constraints.maxWidth;

        Widget row = Row(
          mainAxisAlignment: fits ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
          children: List.generate(widget.categories.length + 1, (i) {
            final selected = i == widget.selectedIndex;
            if (i == widget.categories.length) {
              return SkinToneButton(
                skinTone: selectedSkinTone,
                selected: showSkinTone,
                iconSize: widget.iconSize - 4,
                onTap: (skinTone) {
                  setState(() => showSkinTone = !showSkinTone);
                },
              );
            }
            return Padding(
              padding: EdgeInsets.only(right: i == widget.categories.length - 1 ? 0 : spacing),
              child: GestureDetector(
                onTap: () => widget.onCategoryTap(i),
                child: SvgPicture.asset(
                  'assets/${widget.iconPaths[i]}',
                  package: 'awesome_emoji_picker',
                  width: widget.iconSize,
                  height: widget.iconSize,
                  colorFilter: selected
                      ? ColorFilter.mode(widget.iconSelectedColor, BlendMode.srcIn)
                      : ColorFilter.mode(widget.iconColor, BlendMode.srcIn),
                ),
              ),
            );
          }),
        );

        Widget content = Padding(
          padding: widget.padding ?? const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fits ? row : SingleChildScrollView(scrollDirection: Axis.horizontal, child: row),
              Transform.translate(
                offset: Offset(-4, 0),
                child: ClipRect(
                  child: AnimatedAlign(
                    alignment: Alignment.topLeft,
                    duration: const Duration(milliseconds: 300),
                    heightFactor: showSkinTone ? 1 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 8),
                          child: Text(
                            widget.skinToneLabel,
                            style: widget.headerTextStyle ?? Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Row(
                          // spacing: 8, // If you want spacing between skin tone buttons, wrap with a SizedBox or use a custom widget
                          children: [
                            for (int i = 0; i < EmojiSkinTone.values.length; i++)
                              Padding(
                                padding: EdgeInsets.only(right: i == EmojiSkinTone.values.length - 1 ? 0 : 8),
                                child: SkinToneButton(
                                  skinTone: EmojiSkinTone.values[i],
                                  onTap: (skinTone) {
                                    setState(() => selectedSkinTone = skinTone);
                                    widget.onSkinToneTap(skinTone);
                                  },
                                  selected: selectedSkinTone == EmojiSkinTone.values[i],
                                  iconSize: widget.iconSize,
                                  selectedBorderColor: widget.iconSelectedColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        return content;
      },
    );
  }
}
