import 'package:al_mobdea_admin/app/dependency_injection/service_locator.dart';
import 'package:al_mobdea_admin/core/connection/cubit/network_status_cubit.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/screens/home_screen.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/view_exams_screen.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:al_mobdea_admin/features/live_session/domain/use_cases/delete_live_session_use_case.dart';
import 'package:al_mobdea_admin/features/live_session/domain/use_cases/get_live_session_use_case.dart';
import 'package:al_mobdea_admin/features/live_session/domain/use_cases/save_live_session_use_case.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/cubit/live_session_cubit.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/screens/live_session_screen.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/cubit/bottom_navigation_cubit.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/stream_students_use_case.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/student_management_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/screens/student_management_screen.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/screens/content_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavigationCubit(),
      child: const MainNavigationView(),
    );
  }
}

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background,
      extendBody: true,
      body: BlocBuilder<BottomNavigationCubit, int>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, currentIndex) {
          return KeyedSubtree(
            key: ValueKey<int>(currentIndex),
            child: _buildScreen(currentIndex),
          );
        },
      ),
      bottomNavigationBar: AppAnimations.bottomNavBarEntrance(
        child: BlocBuilder<BottomNavigationCubit, int>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, currentIndex) {
            return CustomBottomNavBar(
              currentIndex: currentIndex,
              onTap: (newIndex) {
                context.read<BottomNavigationCubit>().changePage(newIndex);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return BlocProvider<StudentManagementCubit>(
          create: (_) => StudentManagementCubit(
            streamStudentsUseCase: getIt<StreamStudentsUseCase>(),
            streamGradesUseCase: getIt<StreamGradesUseCase>(),
          )..watchStudentManagement(),
          child: const StudentManagementScreen(),
        );
      case 2:
        return const ContentManagementScreen();
      case 3:
        return const ViewExamsScreen();
      case 4:
        return BlocProvider<LiveSessionCubit>(
          create: (_) => LiveSessionCubit(
            streamGradesUseCase: getIt<StreamGradesUseCase>(),
            getLiveSessionUseCase: getIt<GetLiveSessionUseCase>(),
            saveLiveSessionUseCase: getIt<SaveLiveSessionUseCase>(),
            deleteLiveSessionUseCase: getIt<DeleteLiveSessionUseCase>(),
            networkStatusCubit: getIt<NetworkStatusCubit>(),
          )..initialize(),
          child: const LiveSessionScreen(),
        );
      default:
        return const HomeScreen();
    }
  }
}
