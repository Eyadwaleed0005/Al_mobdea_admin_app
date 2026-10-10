import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_service.dart';
import 'package:al_mobdea_admin/features/exams/data/data_sources/exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/exams/data/data_sources/firebase_exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_creation_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_deletion_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_firestore_guard_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_question_image_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_query_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_results_query_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_update_service.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/exams_data_validator.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/policy/exam_editing_policy.dart';
import 'package:al_mobdea_admin/features/exams/domain/repositories/exams_repository.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/create_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/create_exam_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/delete_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/delete_exam_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/get_exam_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/get_exam_results_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/get_exams_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/stream_exam_results_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/stream_exams_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/update_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/update_exam_use_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

void registerExamsDependencies(GetIt getIt) {
  // Validation
  getIt.registerLazySingleton<ExamsDataValidator>(
    () => const ExamsDataValidator(),
  );

  getIt.registerLazySingleton<ExamEditingPolicy>(
    () => const ExamEditingPolicy(),
  );

  // Services
  getIt.registerLazySingleton<ExamFirestoreGuardService>(
    () => ExamFirestoreGuardService(
      editingPolicy: getIt<ExamEditingPolicy>(),
    ),
  );

  getIt.registerLazySingleton<ExamQuestionImageService>(
    () => ExamQuestionImageService(
      storageService: getIt<StorageService>(),
      firebaseFirestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<ExamQueryService>(
    () => ExamQueryService(
      firestoreService: getIt<FirestoreService>(),
      examsDataValidator: getIt<ExamsDataValidator>(),
      examFirestoreGuardService: getIt<ExamFirestoreGuardService>(),
    ),
  );

  getIt.registerLazySingleton<ExamResultsQueryService>(
    () => ExamResultsQueryService(
      firestoreService: getIt<FirestoreService>(),
      examsDataValidator: getIt<ExamsDataValidator>(),
      examFirestoreGuardService: getIt<ExamFirestoreGuardService>(),
    ),
  );

  getIt.registerLazySingleton<ExamCreationService>(
    () => ExamCreationService(
      firebaseFirestore: getIt<FirebaseFirestore>(),
      examsDataValidator: getIt<ExamsDataValidator>(),
      examFirestoreGuardService: getIt<ExamFirestoreGuardService>(),
      examQuestionImageService: getIt<ExamQuestionImageService>(),
    ),
  );

  getIt.registerLazySingleton<ExamUpdateService>(
    () => ExamUpdateService(
      firebaseFirestore: getIt<FirebaseFirestore>(),
      examsDataValidator: getIt<ExamsDataValidator>(),
      examFirestoreGuardService: getIt<ExamFirestoreGuardService>(),
      examQuestionImageService: getIt<ExamQuestionImageService>(),
    ),
  );

  getIt.registerLazySingleton<ExamDeletionService>(
    () => ExamDeletionService(
      firebaseFirestore: getIt<FirebaseFirestore>(),
      examsDataValidator: getIt<ExamsDataValidator>(),
      examEditingPolicy: getIt<ExamEditingPolicy>(),
      examQuestionImageService: getIt<ExamQuestionImageService>(),
    ),
  );

  // Data Source
  getIt.registerLazySingleton<ExamsRemoteDataSource>(
    () => FirebaseExamsRemoteDataSource(
      examQueryService: getIt<ExamQueryService>(),
      examResultsQueryService: getIt<ExamResultsQueryService>(),
      examCreationService: getIt<ExamCreationService>(),
      examUpdateService: getIt<ExamUpdateService>(),
      examDeletionService: getIt<ExamDeletionService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<ExamsRepository>(
    () => ExamsRepositoryImpl(
      remoteDataSource: getIt<ExamsRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetExamsUseCase>(
    () => GetExamsUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<StreamExamsUseCase>(
    () => StreamExamsUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<GetExamByIdUseCase>(
    () => GetExamByIdUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<GetExamResultsUseCase>(
    () => GetExamResultsUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<StreamExamResultsUseCase>(
    () => StreamExamResultsUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<CreateExamUseCase>(
    () => CreateExamUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<CreateExamQuestionUseCase>(
    () => CreateExamQuestionUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<UpdateExamUseCase>(
    () => UpdateExamUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<UpdateExamQuestionUseCase>(
    () => UpdateExamQuestionUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<DeleteExamUseCase>(
    () => DeleteExamUseCase(examsRepository: getIt<ExamsRepository>()),
  );

  getIt.registerLazySingleton<DeleteExamQuestionUseCase>(
    () => DeleteExamQuestionUseCase(examsRepository: getIt<ExamsRepository>()),
  );
}
