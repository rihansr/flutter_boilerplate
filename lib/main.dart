import 'package:boilerplate/configs/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'configs/provider_config.dart';
import 'configs/theme_config.dart';
import 'routes/route_generator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'models/settings_model.dart';
import 'routes/routes.dart';
import 'services/navigation_service.dart';
import 'shared/constants.dart';
import 'shared/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await sharedPrefs.init();
  await Future.delayed(const Duration(seconds: kSplashDelayInSec), () {});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: ValueListenableBuilder(
        valueListenable: appSettings.settings,
        builder: (context, Settings settings, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle(settings.themeMode),
          child: MaterialApp(
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
                    name: MOBILE, scaleFactor: .725),
                const ResponsiveBreakpoint.autoScale(320,
                    name: MOBILE, scaleFactor: .725),
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
            initialRoute: Routes.intro,
            onGenerateRoute: RouterCustom.generateRoute,
          ),
        ),
      ),
    );
  }
}
