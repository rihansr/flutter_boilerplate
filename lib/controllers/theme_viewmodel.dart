import 'package:boilerplate/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../shared/shared_prefs.dart';

ThemeViewModel themeViewModel({BuildContext? context, listen = true}) =>
    Provider.of<ThemeViewModel>(context ?? navigator.context, listen: listen);

class ThemeViewModel extends ChangeNotifier {
  Settings settings = sharedPrefs.settings;

  set _settings(Settings settings) {
    this.settings = settings;
    sharedPrefs.settings = settings;
    notifyListeners();
  }

  // Theme
  set theme(dynamic mode) {
    if (mode == null) return;
    _settings = settings.copyWith(
      themeMode: mode is ThemeMode ? mode : ThemeMode.values.byName('$mode'),
    );
  }

  bool isDarkTheme([Settings? settings]) =>
      (settings ?? this.settings).themeMode == ThemeMode.system
          ? SchedulerBinding.instance.window.platformBrightness ==
              Brightness.dark
          : (settings ?? this.settings).themeMode == ThemeMode.dark;

  get switchTheme => theme = isDarkTheme() ? ThemeMode.light : ThemeMode.dark;

  // Locale
  set language(dynamic locale) {
    if (locale == null) return;
    _settings = settings.copyWith(
      locale: locale is Locale ? locale : Locale('$locale', ''),
    );
  }

  bool get isEnglish => settings.locale.languageCode == 'en';

  get switchLanguage => language = isEnglish ? 'bn' : 'en';
}
