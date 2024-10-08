import 'dart:collection';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../shared/enums.dart';
import '../shared/strings.dart';
import '../shared/styles.dart';

class BaseViewModel extends ChangeNotifier {
  final HashMap<String, bool> _loading = HashMap();
  bool _busy = false;
  bool get busy => _busy;

  void register(ReceivePort port, String key, {Function(dynamic)? listen}) {
    bool isSuccess = IsolateNameServer.registerPortWithName(port.sendPort, key);

    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping(key);
      register(port, key, listen: listen);
    } else {
      port.listen(listen);
    }
  }

  send(String key, [Object? data]) {
    final send = IsolateNameServer.lookupPortByName(key);
    send?.send(data);
  }

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

  Map<String, String> _errorLog = {};
  Map<String, String> get errorLog => _errorLog;
  get clearErrorLog => errorLog = {};
  set errorLog(Map<String, String> log) => this
    .._errorLog = log
    ..enabledAutoValidate = true
    ..notifyListeners();

  bool enabledAutoValidate = false;
  bool isFormValidate(GlobalKey<FormState> formKey,
      {autoValidate = true, orElse = true}) {
    bool validated =
        _errorLog.isNotEmpty || (formKey.currentState?.validate() ?? orElse);
    if (autoValidate) {
      this
        ..enabledAutoValidate = !validated
        ..notifyListeners();
    }
    return validated;
  }

  void showMessage(
    String? message, {
    String? tag,
    String? orElse,
    String? actionLabel,
    dynamic Function()? onAction,
    MessageType? type,
    bool showToast = false,
  }) {
    if (message == null) return;

    if (showToast) {
      style.toast(message.toString(), type: type);
    } else {
      ScaffoldMessenger.of(navigator.context).showSnackBar(style.snackbar(
        message.toString(),
        actionLabel: actionLabel ??
            (() {
              switch (type) {
                case MessageType.info:
                  return string().okay;
                case MessageType.error:
                  return string().retry;
                default:
                  return null;
              }
            }()),
        duration: 3,
        onAction: onAction,
      ));
    }
  }

  @override
  void dispose() {
    _busy = false;
    _loading.clear();
    super.dispose();
  }
}
