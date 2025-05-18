import 'package:flutter/foundation.dart';

/// Represents a single emoji character with its metadata.
///
/// This immutable class contains the character representation of an emoji
/// along with its descriptive name and category group. It serves as the core
/// data model for all emoji operations within the library.
@immutable
class EmojiModel {
  /// Creates a new immutable [EmojiModel] instance.
  ///
  /// @param char The string representation of the emoji character
  /// @param name The descriptive name of the emoji (e.g., "grinning face")
  /// @param group The category group this emoji belongs to (e.g., "smileys & emotion")
  const EmojiModel(this.char, this.name, this.group, {this.isSelected = false});

  /// The string representation of the emoji character.
  ///
  /// This is the actual emoji character that can be displayed or stored.
  final String char;

  /// The descriptive name of the emoji.
  ///
  /// This name is used for search functionality and accessibility.
  final String name;

  /// The category group this emoji belongs to.
  ///
  /// Used for organizing emoji into logical categories in the UI.
  final String group;

  /// Whether the emoji is selected.
  ///
  /// Used for highlighting the selected emoji in the UI.
  final bool isSelected;

  factory EmojiModel.fromString(String emoji) {
    return EmojiModel(emoji, '', '', isSelected: true);
  }

  EmojiModel copyWith({bool? isSelected}) {
    return EmojiModel(char, name, group, isSelected: isSelected ?? this.isSelected);
  }

  @override
  String toString() => '$char ($name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmojiModel && other.char == char;
  }

  @override
  int get hashCode => char.hashCode;
}
