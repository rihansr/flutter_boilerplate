import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../shared/shared_prefs.dart';
import 'base_viewmodel.dart';

final ThemeViewModel themeViewmodel = ThemeViewModel();

class ThemeViewModel extends BaseViewModel {
  ThemeMode _current = sharedPrefs.themeMode;
  ThemeMode get current => _current;
  set current(theme) => {
        sharedPrefs.themeMode = theme,
        _current = theme,
        notifyListeners(),
      };

  bool get isDark => _current == ThemeMode.system
      ? SchedulerBinding.instance.window.platformBrightness == Brightness.dark
      : _current == ThemeMode.dark;

  switchTheme() => current = isDark ? ThemeMode.light : ThemeMode.dark;
}
