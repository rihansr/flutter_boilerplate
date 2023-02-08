import 'package:flutter/material.dart';
import 'routes.dart';
import '../views/chat_view.dart';
import '../views/dashboard_view.dart';

class RouterCustom {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments;

    switch (settings.name) {
      case Routes.dashboard:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          settings: const RouteSettings(name: Routes.dashboard),
        );

      case Routes.chat:
        return MaterialPageRoute(
          builder: (_) => const ChatView(),
          settings: const RouteSettings(name: Routes.chat),
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
