import 'package:al_mobdea_admin/app/dependency_injection/app_dependencies/app_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/app_dependencies/core_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/dashboard_injection.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/exams_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/grades_injection.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/lesson_exams_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/live_session_injection.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/lessons_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/students_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/study_notes_dependencies.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  registerCoreDependencies(getIt);

  registerAppDependencies(getIt);
  registerStudentsDependencies(getIt);
  registerDashboardDependencies(getIt);
  registerLessonsDependencies(getIt);
  registerLessonExamsDependencies(getIt);
  registerStudyNotesDependencies(getIt);
  registerExamsDependencies(getIt);
  registerLiveSessionDependencies(getIt);
  registerGradesDependencies(getIt);
}
