import 'package:boilerplate/models/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../shared/shared_prefs.dart';

final AppSettings appSettings = AppSettings.value;

class AppSettings {
  static AppSettings get value => AppSettings._();
  AppSettings._();

  ValueNotifier<Settings> settings = ValueNotifier(sharedPrefs.settings);

  set _settings(Settings settings) {
    this.settings.value = settings;
    sharedPrefs.settings = settings;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    this.settings.notifyListeners();
  }

  set language(dynamic locale) {
    if (locale == null) return;
    _settings = settings.value.copyWith(
      locale: locale is Locale ? locale : Locale('$locale', ''),
    );
  }

  set theme(dynamic mode) {
    if (mode == null) return;
    _settings = settings.value.copyWith(
      themeMode: mode is ThemeMode ? mode : ThemeMode.values.byName('$mode'),
    );
  }

  get switchTheme => theme = isDarkTheme ? ThemeMode.light : ThemeMode.dark;

  bool get isDarkTheme => settings.value.themeMode == ThemeMode.system
      ? SchedulerBinding.instance.window.platformBrightness == Brightness.dark
      : settings.value.themeMode == ThemeMode.dark;
}
