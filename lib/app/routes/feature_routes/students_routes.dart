import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/create_student_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/delete_student_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/get_student_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/stream_students_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/update_student_email_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/update_student_password_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/update_student_profile_use_case.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/update_student_subscription_use_case.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/add_student_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/student_management_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/update_student_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/screens/add_student_screen.dart';
import 'package:al_mobdea_admin/features/students/presentation/screens/student_management_screen.dart';
import 'package:al_mobdea_admin/features/students/presentation/screens/update_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

abstract final class StudentsRoutes {
  const StudentsRoutes._();

  static final GetIt _getIt = GetIt.instance;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.studentManagementScreen:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<StudentManagementCubit>(
            create: (_) => StudentManagementCubit(
              streamStudentsUseCase: _get<StreamStudentsUseCase>(),
              streamGradesUseCase: _get<StreamGradesUseCase>(),
            )..watchStudentManagement(),
            child: const StudentManagementScreen(),
          ),
        );

      case RouteNames.addStudentScreen:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<AddStudentCubit>(
            create: (_) => AddStudentCubit(
              createStudentUseCase: _get<CreateStudentUseCase>(),
              streamGradesUseCase: _get<StreamGradesUseCase>(),
            )..watchGrades(),
            child: const AddStudentScreen(),
          ),
        );

      case RouteNames.updateStudentScreen:
        final studentId = settings.arguments as String? ?? '';
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<UpdateStudentCubit>(
            create: (_) => UpdateStudentCubit(
              studentId: studentId,
              getStudentByIdUseCase: _get<GetStudentByIdUseCase>(),
              streamGradesUseCase: _get<StreamGradesUseCase>(),
              updateStudentProfileUseCase: _get<UpdateStudentProfileUseCase>(),
              updateStudentEmailUseCase: _get<UpdateStudentEmailUseCase>(),
              updateStudentPasswordUseCase: _get<UpdateStudentPasswordUseCase>(),
              updateStudentSubscriptionUseCase:
                  _get<UpdateStudentSubscriptionUseCase>(),
              deleteStudentUseCase: _get<DeleteStudentUseCase>(),
            )..initialize(),
            child: const UpdateStudentScreen(),
          ),
        );

      default:
        return null;
    }
  }

  static T _get<T extends Object>() {
    return _getIt.get<T>();
  }
}
