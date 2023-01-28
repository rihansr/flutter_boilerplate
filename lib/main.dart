import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'configs/provider_config.dart';
import 'configs/theme_config.dart';
import 'configs/app_config.dart';
import 'configs/app_settings.dart';
import 'routes/route_generator.dart';
import 'routes/routes.dart';
import 'services/navigation_service.dart';

void main() async => appConfig.init().then((_) => runApp(const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: ValueListenableBuilder(
        valueListenable: appSettings.settings,
        builder: (context, settings, child) =>
            AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle(settings.themeMode),
          child: MaterialApp(
            scaffoldMessengerKey: navigator.scaffoldMessengerKey,
            navigatorKey: navigator.navigatorKey,
            locale: settings.locale,
            debugShowCheckedModeBanner: false,
            title: 'Boilerplate',
            themeMode: settings.themeMode,
            theme: theming(ThemeMode.light),
            darkTheme: theming(ThemeMode.dark),
            builder: (context, widget) => ResponsiveWrapper.builder(
              widget,
              maxWidth: 1024,
              minWidth: 280,
              defaultScale: true,
              breakpoints: [
                const ResponsiveBreakpoint.resize(280,
                    name: MOBILE, scaleFactor: .725),
                const ResponsiveBreakpoint.autoScale(280,
                    name: MOBILE, scaleFactor: .725),
                const ResponsiveBreakpoint.resize(320,
                    name: MOBILE, scaleFactor: .85),
                const ResponsiveBreakpoint.autoScale(320,
                    name: MOBILE, scaleFactor: .85),
                const ResponsiveBreakpoint.resize(480, name: MOBILE),
                const ResponsiveBreakpoint.autoScale(480, name: MOBILE),
                const ResponsiveBreakpoint.resize(540, name: TABLET),
                const ResponsiveBreakpoint.autoScale(540, name: TABLET),
                const ResponsiveBreakpoint.resize(768,
                    name: TABLET, scaleFactor: 1.25),
                const ResponsiveBreakpoint.autoScale(768,
                    name: TABLET, scaleFactor: 1.25),
                const ResponsiveBreakpoint.resize(1024,
                    name: DESKTOP, scaleFactor: 1.25),
                const ResponsiveBreakpoint.autoScale(1024,
                    name: DESKTOP, scaleFactor: 1.25),
              ],
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: Routes.dashboard,
            onGenerateRoute: RouterCustom.generateRoute,
          ),
        ),
      ),
    );
  }
}
