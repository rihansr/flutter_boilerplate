import 'dart:convert';
import '../utils/debug.dart';

enum AppMode { test, production }

final appConfig = AppConfig.value;

class AppConfig {
  static AppConfig get value => AppConfig._();
  AppConfig._();
  AppMode appMode = AppMode.test;

  late Map<String, dynamic> configs;

  init({required AppMode mode}){
    appMode = mode;

    debug.enabled = mode == AppMode.test;

    configs = jsonDecode(config)[mode.name];

    _setConfigs();
  }

  void _setConfigs() {
    // Set configs here
  }

  bool get isInProduction => appMode == AppMode.production;
}

const config = '''
{
  "test": {
    "base": {
      "url": ""
      }
  },
  "production": {
    "base": {
      "url": ""
      }
  }
}
''';
