import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentStore extends ChangeNotifier {
  static const _prefsKey = 'emoji_picker_plus_recent';
  static const _maxItems = 24;

  RecentStore() {
    _load();
  }

  final List<String> _codes = [];

  List<String> get codes => List.unmodifiable(_codes);

  bool contains(String code) => _codes.contains(code);

  Future<void> add(String code) async {
    _codes.remove(code);
    _codes.insert(0, code);
    if (_codes.length > _maxItems) _codes.removeLast();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_codes));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List<dynamic>).cast<String>();
      _codes
        ..clear()
        ..addAll(list);
      notifyListeners();
    }
  }
}
