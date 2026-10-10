import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/cubit/student_exam_results_cubit.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/cubit/student_exam_results_state.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/widgets/student_exam_results_header.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/widgets/student_exam_results_states/student_exam_results_empty_view.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/widgets/student_exam_results_states/student_exam_results_error_view.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/widgets/student_exam_results_states/student_exam_results_loading_view.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/widgets/student_exam_results_states/student_exam_results_success_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentExamResultsContent extends StatelessWidget {
  final String studentId;

  const StudentExamResultsContent({required this.studentId, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: ColorPalette.background,
        appBar: const StudentExamResultsHeader(),
        body: BackgroundStudentLayout(
          child: SafeArea(
            child: BlocBuilder<StudentExamResultsCubit, StudentExamResultsState>(
              builder: (context, state) {
                if (state is StudentExamResultsInitial ||
                    state is StudentExamResultsLoading) {
                  return const StudentExamResultsLoadingView();
                }
      
                if (state is StudentExamResultsError) {
                  return StudentExamResultsErrorView(
                    studentId: studentId,
                    errorMessage: state.appErrorModel.message,
                  );
                }
      
                if (state is StudentExamResultsEmpty) {
                  return StudentExamResultsEmptyView(
                    studentExamResultsOverview: state.studentExamResultsOverview,
                  );
                }
      
                if (state is StudentExamResultsSuccess) {
                  return StudentExamResultsSuccessView(
                    studentId: studentId,
                    studentExamResultsOverview: state.studentExamResultsOverview,
                  );
                }
      
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
