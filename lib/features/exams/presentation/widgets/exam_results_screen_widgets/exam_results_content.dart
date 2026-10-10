import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/app_refresh_indicator.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/exam_results_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/exam_results_screen_widgets/exam_results_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamResultsContent extends StatelessWidget {
  const ExamResultsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: const CustomHeaderBar(title: 'تقرير النتائج'),
        backgroundColor: ColorPalette.background,
        body: BackgroundStudentLayout(
          child: SafeArea(
            child: AppNetworkAwareContent(
              child: AppRefreshIndicator(
                onRefresh: () {
                  return context.read<ExamResultsCubit>().refreshExamResults();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: <Widget>[
                    SliverToBoxAdapter(child: verticalSpace(24)),
                    const ExamResultsStateView(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
