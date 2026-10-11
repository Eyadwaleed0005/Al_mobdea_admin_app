import 'package:al_mobdea_admin/app/routes/feature_routes/app_startup_routes.dart';
import 'package:al_mobdea_admin/app/routes/feature_routes/dashboard_routes.dart';
import 'package:al_mobdea_admin/app/routes/feature_routes/lesson_exams_routes.dart';
import 'package:al_mobdea_admin/app/routes/feature_routes/lessons_routes.dart';
import 'package:al_mobdea_admin/app/routes/feature_routes/live_session_routes.dart';
import 'package:al_mobdea_admin/app/routes/feature_routes/main_navigation_routes.dart';
import 'package:flutter/material.dart';

abstract final class AppRoutes {
  const AppRoutes._();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    return AppStartupRoutes.generateRoute(settings) ??
        DashboardRoutes.generateRoute(settings) ??
        MainNavigationRoutes.generateRoute(settings);
  }
}
