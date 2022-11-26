import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BaseViewModel extends ChangeNotifier {
  final HashMap<String, bool> _loading = HashMap();
  bool _busy = false;
  bool get busy => _busy;

  void setBusy(bool status, {String? key, bool afterBinding = false}) {
    _busy = status;
    if (key != null) _loading[key] = status;
    afterBinding
        ? WidgetsBinding.instance
            .addPostFrameCallback((timeStamp) => notifyListeners())
        : notifyListeners();
    if (status == false && key != null && _loading.containsKey(key)) {
      _loading.remove(key);
    }
  }

  bool isLoading({String? key, bool? orElse}) =>
      (key != null && _loading.containsKey(key) ? _loading[key] : orElse) ??
      busy;

  @override
  void dispose() {
    _busy = false;
    _loading.clear();
    super.dispose();
  }
}
