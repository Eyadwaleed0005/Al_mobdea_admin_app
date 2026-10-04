import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/connection/cubit/network_status_cubit.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/use_cases/get_dashboard_students_summary_use_case.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/cubit/home_dashboard_cubit.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

abstract final class MainNavigationRoutes {
  const MainNavigationRoutes._();

  static final GetIt _getIt = GetIt.instance;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name != RouteNames.mainNavigationScreen) {
      return null;
    }

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) {
        return BlocProvider<HomeDashboardCubit>(
          create: (_) => _createHomeDashboardCubit(),
          child: const MainNavigationScreen(),
        );
      },
    );
  }

  static HomeDashboardCubit _createHomeDashboardCubit() {
    return HomeDashboardCubit(
      getDashboardStudentsSummaryUseCase:
          _get<GetDashboardStudentsSummaryUseCase>(),
      networkStatusCubit: _get<NetworkStatusCubit>(),
    )..loadStudentsSummary();
  }

  static T _get<T extends Object>() {
    return _getIt.get<T>();
  }
}
