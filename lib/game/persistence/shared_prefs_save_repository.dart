import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:immortal_path/game/models/game_state.dart';

abstract class SaveRepository {
  Future<GameState?> load();
  Future<void> save(GameState state);
}

class SharedPrefsSaveRepository implements SaveRepository {
  static const String _key = 'immortal_path_save_v1';

  @override
  Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }
}
