import 'package:al_mobdea_admin/features/result_student/data/data_sources/firebase_student_exam_results_remote_data_source.dart';
import 'package:al_mobdea_admin/features/result_student/data/data_sources/student_exam_results_remote_data_source.dart';
import 'package:al_mobdea_admin/features/result_student/data/repository/student_exam_results_repository_impl.dart';
import 'package:al_mobdea_admin/features/result_student/domain/repository/student_exam_results_repository.dart';
import 'package:al_mobdea_admin/features/result_student/domain/use_cases/get_student_results_by_student_id_use_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

void registerStudentExamResultsDependencies(GetIt getIt) {
  // Data Source
  getIt.registerLazySingleton<StudentExamResultsRemoteDataSource>(
    () => FirebaseStudentExamResultsRemoteDataSource(
      firebaseFirestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<StudentExamResultsRepository>(
    () => StudentExamResultsRepositoryImpl(
      studentExamResultsRemoteDataSource:
          getIt<StudentExamResultsRemoteDataSource>(),
    ),
  );

  // Use Case
  getIt.registerLazySingleton<GetStudentExamResultsByStudentIdUseCase>(
    () => GetStudentExamResultsByStudentIdUseCase(
      studentExamResultsRepository: getIt<StudentExamResultsRepository>(),
    ),
  );
}
