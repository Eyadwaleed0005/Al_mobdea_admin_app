import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/app_refresh_indicator.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/cubit/home_dashboard_cubit.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/widgets/home_screen_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.dark(),
      child: Scaffold(
        backgroundColor: ColorPalette.background,
        appBar: CustomHeaderBar(title: 'لوحة التحكم', showProfileIcon: true),
        body: BackgroundStudentLayout(
          child: SafeArea(
            top: false,
            child: AppNetworkAwareContent(
              child: AppRefreshIndicator(
                onRefresh: () {
                  return context
                      .read<HomeDashboardCubit>()
                      .refreshStudentsSummary();
                },
                child: const HomeScreenContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
