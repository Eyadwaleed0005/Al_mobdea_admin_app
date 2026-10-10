import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_service.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/data_sources/firebase_lesson_exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/data_sources/lesson_exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/repositories/lesson_exam_repository_impl.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/repositories/lesson_exam_repository.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/create_lesson_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/delete_lesson_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/save_lesson_exam_answers_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/stream_lesson_exam_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/update_lesson_exam_question_use_case.dart';
import 'package:get_it/get_it.dart';

void registerLessonExamsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<LessonExamsRemoteDataSource>(
    () => FirebaseLessonExamsRemoteDataSource(
      firestoreService: getIt<FirestoreService>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<LessonExamRepository>(
    () => LessonExamRepositoryImpl(
      remoteDataSource: getIt<LessonExamsRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<StreamLessonExamUseCase>(
    () => StreamLessonExamUseCase(getIt<LessonExamRepository>()),
  );

  getIt.registerLazySingleton<CreateLessonExamQuestionUseCase>(
    () => CreateLessonExamQuestionUseCase(
      getIt<LessonExamRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateLessonExamQuestionUseCase>(
    () => UpdateLessonExamQuestionUseCase(
      getIt<LessonExamRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteLessonExamQuestionUseCase>(
    () => DeleteLessonExamQuestionUseCase(
      getIt<LessonExamRepository>(),
    ),
  );

  getIt.registerLazySingleton<SaveLessonExamAnswersUseCase>(
    () => SaveLessonExamAnswersUseCase(
      getIt<LessonExamRepository>(),
    ),
  );
}
