import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:flutter/material.dart';

abstract final class AppRoutes {
  const AppRoutes._();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.homeScreen:
        return MaterialPageRoute(
          builder: (context) => const SizedBox(),
        );
      default:
        return null;
    }
  }
}
