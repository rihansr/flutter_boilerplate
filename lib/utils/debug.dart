import 'dart:developer';
import 'package:flutter/foundation.dart';

final Debug debug = Debug.value;

class Debug {
  static Debug get value => Debug._();

  Debug._();

  var enabled = kDebugMode;

  print(dynamic message, {bool bounded = false, String? boundedText}) =>
      {if (enabled) _log(message, bounded, boundedText)};

  _log(dynamic message, bool bounded, String? boundedText) {
    log(
      '${bounded || boundedText != null ? '\n<=====${boundedText ?? ''}=====>\n' : ''}'
      '$message'
      '${bounded || boundedText != null ? '\n<=====${boundedText ?? ''}=====>\n' : ''}',
    );
  }
}