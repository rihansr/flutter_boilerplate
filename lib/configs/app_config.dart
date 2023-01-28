import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/constants.dart';
import '../shared/shared_prefs.dart';

enum _AppMode { test, production }

final appConfig = AppConfig.value;

class AppConfig {
  static AppConfig get value => AppConfig._();
  AppConfig._();
  _AppMode appMode = kReleaseMode ? _AppMode.production : _AppMode.test;

  init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Future.wait([
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
      sharedPrefs.init(),
      Future.delayed(kSplashDelay),
    ]);

    //FlutterNativeSplash.remove();
  }

  Map<String, dynamic> get configs => jsonDecode(config)[appMode.name];

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
