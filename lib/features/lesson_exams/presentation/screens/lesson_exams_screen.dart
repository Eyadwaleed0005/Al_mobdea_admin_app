import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/lesson_exams_cubit.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/lesson_exams_state.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/lesson_exams_screen_widgets/lesson_exams_screen_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonExamsScreen extends StatelessWidget {
  const LessonExamsScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.dark(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const CustomHeaderBar(title: '').preferredSize,
          child: BlocBuilder<LessonExamsCubit, LessonExamsState>(
            buildWhen: (previous, current) {
              return previous.hasQuestions != current.hasQuestions;
            },
            builder: (context, state) {
              return CustomHeaderBar(
                title: state.hasQuestions
                    ? 'تعديل اختبار الدرس'
                    : 'إنشاء اختبار الدرس',
                showBackButton: true,
              );
            },
          ),
        ),
        backgroundColor: ColorPalette.background,
        body: BackgroundStudentLayout(
          child: SafeArea(
            top: false,
            child: AppNetworkAwareContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: LessonExamsScreenContent(lessonId: lessonId),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
