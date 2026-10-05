import 'package:al_mobdea_admin/app/dependency_injection/service_locator.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/screens/home_screen.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/cubit/bottom_navigation_cubit.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/stream_students_use_case.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/student_management_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/screens/student_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => BottomNavigationCubit(), child: const MainNavigationView());
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
          return KeyedSubtree(key: ValueKey<int>(currentIndex), child: _buildScreen(currentIndex));
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
        return const _PlaceholderScreen(
          title: 'المحتوى',
          description: 'ستظهر إدارة المحتوى هنا.',
          icon: Icons.menu_book_outlined,
        );
      case 3:
        return const _PlaceholderScreen(
          title: 'الامتحانات',
          description: 'ستظهر الامتحانات هنا.',
          icon: Icons.assignment_outlined,
        );
      case 4:
        return const _PlaceholderScreen(
          title: 'الحصة',
          description: 'ستظهر الحصة المباشرة هنا.',
          icon: Icons.videocam_outlined,
        );
      default:
        return const HomeScreen();
    }
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.description, required this.icon});

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return BackgroundStudentLayout(
      child: Scaffold(
        backgroundColor: ColorPalette.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: ColorPalette.primary),
                const SizedBox(height: 14),
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kufam',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF27191D),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    description,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                      color: Color(0xFF604B49),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
