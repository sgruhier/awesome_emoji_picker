import '../generated/emoji_data.dart';
import 'model/emoji.dart';

/// Provides search across the emoji list.
class EmojiRepository {
  const EmojiRepository();

  /// O(n) but fast in practice; list size ~3k.
  List<Emoji> search(String query) {
    if (query.trim().isEmpty) return const [];
    final q = query.toLowerCase().trim();
    return kEmojiList.where((e) => e.name.contains(q) || e.keywords.any((k) => k.contains(q))).toList();
  }

  /// Group emoji by CLDR group for category tabs.
  Map<String, List<Emoji>> byGroup() {
    final map = <String, List<Emoji>>{};
    for (final e in kEmojiList) {
      map.putIfAbsent(e.group, () => []).add(e);
    }
    return map;
  }
}
