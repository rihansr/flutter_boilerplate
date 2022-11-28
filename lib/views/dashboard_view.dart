import 'package:boilerplate/configs/app_settings.dart';
import 'package:boilerplate/controllers/dashboard_viewmodel.dart';
import 'package:boilerplate/shared/colors.dart';
import 'package:boilerplate/shared/strings.dart';
import 'package:boilerplate/widgets/base_widget.dart';
import 'package:boilerplate/widgets/button_widget.dart';
import 'package:boilerplate/widgets/splitter_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/settings_listenable_builder.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      model: Provider.of<DashboardViewModel>(context),
      builder: (context, controller, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: SettingsListenableBuilder(
            builder: (settings) => Text(
              string(context).appName,
              style: TextStyle(color: ColorPalette.current(settings).primary),
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Splitter.horizontal(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(
                label: string(context).change,
                leading: const Icon(Icons.dark_mode),
                contentSpacing: 4,
                onPressed: () => appSettings.switchTheme,
              ),
              ButtonWidget(
                label: string(context).change,
                leading: const Icon(Icons.language),
                contentSpacing: 4,
                onPressed: () => {appSettings.switchLanguage},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
