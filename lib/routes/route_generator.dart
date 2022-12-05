import 'package:flutter/material.dart';
import 'routes.dart';
import '../views/dashboard_view.dart';

class RouterCustom {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      /* case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const IntroView(),
          settings: const RouteSettings(name: Routes.splash),
        ); */

      case Routes.dashboard:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          settings: const RouteSettings(name: Routes.dashboard),
        );

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ),
            settings: const RouteSettings(name: "404"));
    }
  }
}
