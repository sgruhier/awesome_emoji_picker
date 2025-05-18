// tool/generate_emoji_data.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

/// Downloads the latest emoji.json and converts it to `lib/generated/emoji_data.dart`.
///
/// Run with:
///   dart run tool/generate_emoji_data.dart
///
Future<void> main() async {
  const source = 'https://raw.githubusercontent.com/amio/emoji.json/master/emoji.json';
  final client = HttpClient();
  stdout.writeln('Downloading emoji.json …');

  final request = await client.getUrl(Uri.parse(source));
  final response = await request.close();

  if (response.statusCode != 200) {
    stderr.writeln('HTTP ${response.statusCode} — cannot download emoji.json');
    exitCode = 1;
    return;
  }

  final raw = await response.transform(utf8.decoder).join();
  final list = jsonDecode(raw) as List<dynamic>;

  final buffer = StringBuffer('''// GENERATED FILE — do not edit by hand.
// Run `dart run tool/generate_emoji_data.dart` to regenerate.
// ignore_for_file: constant_identifier_names, prefer_collection_literals

import '../src/model/emoji.dart';

const kEmojiList = <Emoji>[
''');

  for (final obj in list) {
    final e = obj as Map<String, dynamic>;

    final char = e['char'] as String;
    final name = e['name'] as String;
    final group = (e['group'] ?? e['category'] ?? 'Symbols') as String;

    // `keywords` is optional in newer dumps
    final keywords = (e['keywords'] as List<dynamic>? ?? []).cast<String>();

    buffer.writeln("  Emoji(${jsonEncode(char)}, ${jsonEncode(name)}, ${jsonEncode(group)}, ${jsonEncode(keywords)}),");
  }

  buffer.writeln('];');

  const outPath = 'lib/generated/emoji_data.dart';
  await File(outPath).create(recursive: true);
  await File(outPath).writeAsString(buffer.toString());
  stdout.writeln('✅  Wrote $outPath with ${list.length} emoji');
}
