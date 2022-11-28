import 'package:boilerplate/models/settings_model.dart';
import 'package:flutter/material.dart';
import '../configs/app_settings.dart';

class SettingsListenableBuilder extends StatelessWidget {
  const SettingsListenableBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(Settings settings) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: appSettings.settings,
        builder: (context, settings, child) {
          return builder(settings);
        });
  }
}
