import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_loading_indicator.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/cubit/home_dashboard_cubit.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/cubit/home_dashboard_state.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/widgets/students_overview_cards.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/widgets/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          verticalSpace(25),
          AppAnimations.screenSection(delay: 100, child: const WelcomeCard()),
          verticalSpace(20),
          AppAnimations.screenSection(
            delay: 200,
            child: BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
              builder: (context, state) {
                return switch (state) {
                  HomeDashboardInitial() || HomeDashboardLoading() => SizedBox(
                    height: 140.h,
                    child: const Center(
                      child: AppLoadingIndicator(
                        color: ColorPalette.primary,
                        size: 32,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  HomeDashboardLoaded(:final summary) => StudentsOverviewCards(
                    totalStudents: summary.totalStudents,
                    expiredSubscriptions: summary.expiredSubscriptions,
                  ),
                };
              },
            ),
          ),
          verticalSpace(24),
          AppAnimations.screenSection(
            delay: 300,
            child: QuickActionsSection(
              onStudentsTap: () {
                Navigator.of(context).pushNamed(RouteNames.addStudentScreen);
              },
              onContentTap: () {
                Navigator.of(context).pushNamed(RouteNames.addLessonScreen);
              },
              onExamsTap: () {
                Navigator.of(context).pushNamed(RouteNames.addExamScreen);
              },
              onNotesTap: () {
                Navigator.of(context).pushNamed(RouteNames.liveSession);
              },
            ),
          ),
        ],
      ),
    );
  }
}
