import 'dart:convert';
import '../utils/debug.dart';

enum AppMode { test, production }

final appConfig = AppConfig.value;

class AppConfig {
  static AppConfig get value => AppConfig._();
  AppConfig._();
  AppMode appMode = AppMode.test;

  //late Map<String, dynamic> configs;

  init(AppMode mode) {
    appMode = mode;

    debug.enabled = mode == AppMode.test;

    //configs = jsonDecode(config)[mode.name];

    _setConfigs();
  }

  void _setConfigs() {
    // Set configs here
  }

  Map<String, dynamic> get configs => jsonDecode(config)[appMode.name];

  bool get isInProduction => appMode == AppMode.production;

  static const config = '''
{
  "test": {
    "base": {
      "url": "https://httpbin.org"
      },
    "stripe": {
      "base_url": "https://api.stripe.com/v1",
      "payment_logo": "https://devathon.com/wp-content/uploads/2020/02/Top-10-Payment-Gateways-Devathon.png",
      "credentials": {
        "publish_key": "pk_test_BPZRRegJm0Y8KuX7nBElSfpq00hLnSTszJ",
        "secret_key": "sk_test_m14bnxcpkAaoZcQDDgOIYmaH007kykXYqQ"
      }
    },
    "ssl": {
      "credentials": {
        "ipn_url": "https://www.thegreatspoon.com/ipn",
        "store_id": "thegr63d1436813746",
        "store_password": "thegr63d1436813746@ssl"
      }
    }
  },
  "production": {
    "base": {
      "url": "https://httpbin.org"
      },
    "stripe": {
      "base_url": "https://api.stripe.com/v1",
      "payment_logo": "https://devathon.com/wp-content/uploads/2020/02/Top-10-Payment-Gateways-Devathon.png",
      "credentials": {
        "publish_key": "pk_test_BPZRRegJm0Y8KuX7nBElSfpq00hLnSTszJ",
        "secret_key": "sk_test_m14bnxcpkAaoZcQDDgOIYmaH007kykXYqQ"
      }
    },
     "ssl": {
      "credentials": {
        "ipn_url": "https://www.thegreatspoon.com/ipn",
        "store_id": "thegr63d1436813746",
        "store_password": "thegr63d1436813746@ssl"
      }
    }
  }
}
''';
}
