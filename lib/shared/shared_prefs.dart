import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/settings_model.dart';

final sharedPrefs = SharedPrefs();

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  static const String _settingsKey = "sp_settings_key";

  init() async => _sharedPrefs = await SharedPreferences.getInstance();

  // Settings
  set settings(Settings settings) =>
      _sharedPrefs.setString(_settingsKey, json.encode(settings.toJson()));
  Settings get settings => _sharedPrefs.getString(_settingsKey) == null
      ? const Settings()
      : Settings.fromJson(json.decode(_sharedPrefs.getString(_settingsKey)!));
}
