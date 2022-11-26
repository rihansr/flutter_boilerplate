import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefs = SharedPrefs();

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  static const String _themeKey = "sp_themeKeys";

  init() async => _sharedPrefs = await SharedPreferences.getInstance();

  // Theming
  set themeMode(ThemeMode mode) => _sharedPrefs.setString(_themeKey, mode.name);
  ThemeMode get themeMode => ThemeMode.values
      .byName(_sharedPrefs.getString(_themeKey) ?? ThemeMode.system.name);
}
