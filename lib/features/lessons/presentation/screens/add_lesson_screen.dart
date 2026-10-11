import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_state.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/add_lesson_screen_widgets/add_lesson_content.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/add_lesson_screen_widgets/add_lesson_feedback_listener.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/add_lesson_screen_widgets/add_lesson_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddLessonScreen extends StatelessWidget {
  const AddLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AddLessonFeedbackListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.light(),
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            appBar: const CustomHeaderBar(title: 'إضافة درس'),
            backgroundColor: ColorPalette.background,
            body: BackgroundStudentLayout(
              child: SafeArea(
                child: AppNetworkAwareContent(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: AppAnimations.screenSection(
                            delay: 0,
                            child: BlocBuilder<AddLessonCubit, AddLessonState>(
                              builder: (context, state) {
                                if (state.isPageLoading) {
                                  return const AddLessonLoadingSkeleton();
                                }

                                if (state.hasPageFailure &&
                                    state.error != null) {
                                  return AppErrorWidget(
                                    message: state.error!.message,
                                    onRetry: () {
                                      context.read<AddLessonCubit>().retry();
                                    },
                                  );
                                }

                                if (state.isPageReady) {
                                  return AddLessonContent(state: state);
                                }

                                return const AddLessonLoadingSkeleton();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
