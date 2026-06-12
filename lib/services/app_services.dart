import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../shared/models/history_entry.dart';

// ---------------------------------------------------------------------------
// HISTORIAL
// ---------------------------------------------------------------------------

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  HistoryNotifier() : super(_load());

  static Box get _box => Hive.box('history');

  static List<HistoryEntry> _load() {
    final raw = _box.get('entries', defaultValue: <dynamic>[]) as List;
    return raw
        .map((e) => HistoryEntry.fromMap(e as Map))
        .toList()
        .reversed
        .toList();
  }

  Future<void> add(HistoryEntry entry) async {
    final raw = List<dynamic>.from(
        _box.get('entries', defaultValue: <dynamic>[]) as List);
    raw.add(entry.toMap());
    // Conservar máximo 500 entradas.
    if (raw.length > 500) raw.removeRange(0, raw.length - 500);
    await _box.put('entries', raw);
    state = _load();
  }

  Future<void> removeAt(int index) async {
    final current = List<HistoryEntry>.from(state);
    current.removeAt(index);
    await _box.put(
        'entries', current.reversed.map((e) => e.toMap()).toList());
    state = current;
  }

  Future<void> clear() async {
    await _box.put('entries', <dynamic>[]);
    state = [];
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
        (ref) => HistoryNotifier());

// ---------------------------------------------------------------------------
// FAVORITOS
// ---------------------------------------------------------------------------

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super(_load());

  static Box get _box => Hive.box('favorites');

  static List<String> _load() =>
      List<String>.from(_box.get('tools', defaultValue: <String>[]) as List);

  Future<void> toggle(String toolId) async {
    final current = List<String>.from(state);
    current.contains(toolId) ? current.remove(toolId) : current.add(toolId);
    await _box.put('tools', current);
    state = current;
  }

  bool isFavorite(String toolId) => state.contains(toolId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
        (ref) => FavoritesNotifier());

// ---------------------------------------------------------------------------
// TEMA
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_load());

  static Box get _box => Hive.box('settings');

  static ThemeMode _load() {
    final value = _box.get('themeMode', defaultValue: 'system') as String;
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    await _box.put('themeMode', mode.name);
    state = mode;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
    (ref) => ThemeModeNotifier());
