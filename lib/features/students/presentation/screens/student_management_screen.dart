import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_empty_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/app_no_search_results_widget.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/student_management_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/student_management_state.dart';
import 'package:al_mobdea_admin/features/students/presentation/widgets/student_management_screen_widgets/student_management_content.dart';
import 'package:al_mobdea_admin/features/students/presentation/widgets/student_management_screen_widgets/student_management_skeleton.dart';
import 'package:al_mobdea_admin/features/students/presentation/widgets/student_management_screen_widgets/students_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentManagementCubit>().watchStudentManagement();
  }

  void _navigateToAdd() {
    Navigator.of(context).pushNamed(RouteNames.addStudentScreen);
  }

  void _navigateToUpdate(StudentEntity student) {
    Navigator.of(context).pushNamed(RouteNames.updateStudentScreen, arguments: student.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.dark(),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: CustomHeaderBar(title: 'إدارة الطلاب', showProfileIcon: true),
          backgroundColor: ColorPalette.background,
          body: BackgroundStudentLayout(
            child: AppNetworkAwareContent(
              child: BlocBuilder<StudentManagementCubit, StudentManagementState>(
                builder: (context, state) {
                  return switch (state) {
                    StudentManagementInitial() ||
                    StudentManagementLoading() => const StudentManagementSkeleton(),

                    StudentManagementEmpty() => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                      child: AppEmptyWidget(
                        title: 'لا يوجد طلاب بعد',
                        message: 'ابدأ بإضافة أول طالب وإنشاء حسابه لمتابعة الدروس والاختبارات.',
                        actionText: 'إضافة طالب',
                        icon: Icons.person_outline_rounded,
                        onActionPressed: _navigateToAdd,
                      ),
                    ),

                    StudentManagementNoSearchResults(
                      grades: final grades,
                      filters: final filters,
                    ) =>
                      StudentManagementContent(
                        grades: grades,
                        filters: filters,
                        onAddStudent: _navigateToAdd,
                        content: const AppNoSearchResultsWidget(
                          message: 'جرب البحث باسم آخر أو تغيير الفلاتر المستخدمة.',
                        ),
                      ),

                    StudentManagementLoaded(
                      students: final students,
                      grades: final grades,
                      filters: final filters,
                    ) =>
                      StudentManagementContent(
                        grades: grades,
                        filters: filters,
                        onAddStudent: _navigateToAdd,
                        content: StudentsList(
                          students: students,
                          grades: grades,
                          onStudentTap: _navigateToUpdate,
                        ),
                      ),

                    StudentManagementFailure(error: final error) => AppErrorWidget(
                      message: error.message,
                      onRetry: () {
                        context.read<StudentManagementCubit>().watchStudentManagement();
                      },
                    ),
                  };
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
