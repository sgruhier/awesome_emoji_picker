import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SkinToneButton extends StatelessWidget {
  const SkinToneButton({
    required this.skinTone,
    required this.onTap,
    this.selected = false,
    this.iconSize = 24,
    this.backgroundColor,
    this.selectedBorderColor,
    this.selectedBackgroundColor,
    super.key,
  });

  final EmojiSkinTone skinTone;
  final void Function(EmojiSkinTone) onTap;
  final bool selected;
  final double iconSize;
  final Color? backgroundColor;
  final Color? selectedBorderColor;
  final Color? selectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(skinTone),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? (selectedBackgroundColor ?? Colors.white) : (backgroundColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? (selectedBorderColor ?? Colors.blue) : (Colors.transparent),
            width: 2,
          ),
        ),
        child: SvgPicture.asset(
          'assets/skin${skinTone.index + 1}.svg',
          package: 'awesome_emoji_picker',
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}
