import 'package:flutter/material.dart';
import 'emoji_repository.dart';
import 'model/emoji.dart';

class EmojiSearchDelegate extends SearchDelegate<Emoji?> {
  EmojiSearchDelegate(this.repository);

  final EmojiRepository repository;

  @override
  String get searchFieldLabel => 'Search emoji';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return BackButton(onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = repository.search(query);
    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search emoji'));
    }
    final results = repository.search(query);
    return _buildList(results);
  }

  Widget _buildList(List<Emoji> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final e = list[index];
        return ListTile(
          leading: Text(e.char, style: const TextStyle(fontSize: 24)),
          title: Text(e.name.replaceAll('_', ' ')),
          onTap: () => close(context, e),
        );
      },
    );
  }
}
