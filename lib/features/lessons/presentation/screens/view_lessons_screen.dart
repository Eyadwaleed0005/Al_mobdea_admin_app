import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/view_lessons_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/view_lessons_state.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/view_lessons_screen_widgets/view_lessons_content.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/view_lessons_screen_widgets/view_lessons_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewLessonsScreen extends StatelessWidget {
  const ViewLessonsScreen({
    super.key,
    this.onAddLessonPressed,
    this.onLessonTap,
  });

  final VoidCallback? onAddLessonPressed;
  final ValueChanged<LessonEntity>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.light(),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: const CustomHeaderBar(title: 'إدارة الدروس'),
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
                          child: BlocBuilder<ViewLessonsCubit, ViewLessonsState>(
                            builder: (context, state) {
                              if (state is ViewLessonsInitial ||
                                  state is ViewLessonsLoading) {
                                return const ViewLessonsLoadingSkeleton();
                              }

                              if (state is ViewLessonsFailure) {
                                return AppErrorWidget(
                                  message: state.error.message,
                                  onRetry: () {
                                    context.read<ViewLessonsCubit>().retry();
                                  },
                                );
                              }

                              if (state is ViewLessonsDataSuccess) {
                                return ViewLessonsContent(
                                  state: state,
                                  onAddLessonPressed: () {
                                    _handleAddLessonPressed(context);
                                  },
                                  onLessonTap: (lesson) {
                                    _handleLessonTap(context, lesson);
                                  },
                                );
                              }

                              return const ViewLessonsLoadingSkeleton();
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
    );
  }

  void _handleAddLessonPressed(BuildContext context) {
    final callback = onAddLessonPressed;

    if (callback != null) {
      callback();
      return;
    }

    Navigator.of(context).pushNamed(RouteNames.addLessonScreen);
  }

  void _handleLessonTap(BuildContext context, LessonEntity lesson) {
    final callback = onLessonTap;

    if (callback != null) {
      callback(lesson);
      return;
    }

    final lessonId = lesson.lessonId.trim();

    if (lessonId.isEmpty) {
      return;
    }

    Navigator.of(context).pushNamed(
      RouteNames.editLessonScreen,
      arguments: lessonId,
    );
  }
}
