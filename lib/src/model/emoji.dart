import 'package:flutter/foundation.dart';

@immutable
class Emoji {
  const Emoji(this.char, this.name, this.group, this.keywords);

  final String char;
  final String name;
  final String group;
  final List<String> keywords;
}
