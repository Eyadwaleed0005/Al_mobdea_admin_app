import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/add_student_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/add_student_state.dart';
import 'package:al_mobdea_admin/features/students/presentation/widgets/add_student_screen_widgets/add_student_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddStudentBody extends StatelessWidget {
  const AddStudentBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppAnimations.screenSection(
            delay: 0,
            child: const AddStudentFormFields(),
          ),
          verticalSpace(30),
          AppAnimations.screenSection(
            delay: 200,
            child: BlocBuilder<AddStudentCubit, AddStudentState>(
              buildWhen: (prev, curr) => prev.isSubmitting != curr.isSubmitting,
              builder: (context, state) {
                return CustomButton(
                  text: 'إنشاء حساب الطالب',
                  isLoading: state.isSubmitting,
                  onPressed: context.read<AddStudentCubit>().submit,
                );
              },
            ),
          ),
          verticalSpace(24),
        ],
      ),
    );
  }
}
