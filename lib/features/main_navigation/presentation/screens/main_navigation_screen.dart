import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/screens/home_screen.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/cubit/bottom_navigation_cubit.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/widgets/custom_bottom_nav_bar.dart';
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
        return const _PlaceholderScreen(
          title: 'الطلاب',
          description: 'ستظهر إدارة الطلاب هنا.',
          icon: Icons.group_outlined,
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
