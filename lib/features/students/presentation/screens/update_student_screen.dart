import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/students/presentation/widgets/update_student_screen_widgets/update_student_body.dart';
import 'package:al_mobdea_admin/features/students/presentation/widgets/update_student_screen_widgets/update_student_feedback_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateStudentScreen extends StatelessWidget {
  const UpdateStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.dark(),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: CustomHeaderBar(title: 'حساب طالب', showBackButton: true),
          backgroundColor: ColorPalette.background,
          body: BackgroundStudentLayout(
            child: UpdateStudentFeedbackListener(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [const Expanded(child: UpdateStudentBody())],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
