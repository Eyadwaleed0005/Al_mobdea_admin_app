import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_empty_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_loading_indicator.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_state.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/add_exam_screen_widgets/add_exam_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddExamContent extends StatelessWidget {
  const AddExamContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: const CustomHeaderBar(title: 'إنشاء اختبار عام'),
        backgroundColor: ColorPalette.background,
        body: BackgroundStudentLayout(
          child: SafeArea(
            child: AppNetworkAwareContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: BlocBuilder<AddExamCubit, AddExamState>(builder: _buildState)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildState(BuildContext context, AddExamState state) {
    return switch (state) {
      AddExamLoading() => const Center(
        child: AppLoadingIndicator(color: ColorPalette.primary, size: 32, strokeWidth: 3),
      ),

      AddExamEmpty() => const AppEmptyWidget(
        title: 'لا توجد صفوف دراسية',
        message: 'يجب إضافة صف دراسي وتفعيله قبل إنشاء الاختبار.',
        icon: Icons.school_outlined,
      ),

      AddExamError(:final error) => AppErrorWidget(
        message: error.message,
        onRetry: context.read<AddExamCubit>().retry,
      ),

      AddExamSuccess(:final grades) => AppAnimations.screenSection(
        delay: 120,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: AddExamForm(grades: grades),
        ),
      ),
    };
  }
}
