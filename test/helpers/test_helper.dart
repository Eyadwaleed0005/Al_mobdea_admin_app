import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_service.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/cache/dashboard_local_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/use_cases/get_dashboard_students_summary_use_case.dart';
import 'package:al_mobdea_admin/features/exams/data/data_sources/exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_creation_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_deletion_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_query_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_question_image_service.dart';
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
import 'package:al_mobdea_admin/features/grades/data/data_sources/grades_remote_data_source.dart';
import 'package:al_mobdea_admin/features/grades/domain/repositories/grades_repository.dart';
import 'package:al_mobdea_admin/features/result_student/data/data_sources/student_exam_results_remote_data_source.dart';
import 'package:al_mobdea_admin/features/result_student/domain/repository/student_exam_results_repository.dart';
import 'package:al_mobdea_admin/features/lessons/data/data_sources/lessons_remote_data_source.dart';
import 'package:al_mobdea_admin/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/create_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/delete_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/get_lesson_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/get_lessons_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/stream_lessons_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/update_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/data_sources/lesson_exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/live_session/data/data_sources/live_sessions_remote_data_source.dart';
import 'package:al_mobdea_admin/features/live_session/domain/repository/live_sessions_repository.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/repositories/lesson_exam_repository.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/create_lesson_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/delete_lesson_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/save_lesson_exam_answers_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/stream_lesson_exam_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/update_lesson_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/data/data_sources/study_notes_remote_data_source.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/repositories/study_notes_repository.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/create_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/delete_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_note_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/stream_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/update_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/students/data/data_sources/auth/student_auth_remote_data_source.dart';
import 'package:al_mobdea_admin/features/students/data/data_sources/firestore/students_remote_data_source.dart';
import 'package:al_mobdea_admin/features/students/domain/repositories/student_auth_repository.dart';
import 'package:al_mobdea_admin/features/students/domain/repositories/students_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mocktail/mocktail.dart';

// Core mocks
class MockFirestoreService extends Mock
    implements FirestoreService {}

class MockFirebaseFunctions extends Mock
    implements FirebaseFunctions {}

// Exams feature mocks
class MockExamsRemoteDataSource extends Mock
    implements ExamsRemoteDataSource {}

class MockExamsRepository extends Mock
    implements ExamsRepository {}

class MockExamQueryService extends Mock
    implements ExamQueryService {}

class MockExamResultsQueryService extends Mock
    implements ExamResultsQueryService {}

class MockExamCreationService extends Mock
    implements ExamCreationService {}

class MockExamUpdateService extends Mock
    implements ExamUpdateService {}

class MockExamDeletionService extends Mock
    implements ExamDeletionService {}

class MockExamQuestionImageService extends Mock
    implements ExamQuestionImageService {}

class MockExamsDataValidator extends Mock
    implements ExamsDataValidator {}

class MockExamEditingPolicy extends Mock
    implements ExamEditingPolicy {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// Students feature mocks
class MockStudentsRemoteDataSource extends Mock
    implements StudentsRemoteDataSource {}

class MockStudentAuthRemoteDataSource extends Mock
    implements StudentAuthRemoteDataSource {}

class MockStudentsRepository extends Mock
    implements StudentsRepository {}

class MockStudentAuthRepository extends Mock
    implements StudentAuthRepository {}

// Lessons feature mocks
class MockLessonsRemoteDataSource extends Mock
    implements LessonsRemoteDataSource {}

class MockLessonsRepository extends Mock
    implements LessonsRepository {}

class MockStorageService extends Mock
    implements StorageService {}

class MockGetLessonsUseCase extends Mock
    implements GetLessonsUseCase {}

class MockGetLessonByIdUseCase extends Mock
    implements GetLessonByIdUseCase {}

class MockStreamLessonsUseCase extends Mock
    implements StreamLessonsUseCase {}

class MockCreateLessonUseCase extends Mock
    implements CreateLessonUseCase {}

class MockUpdateLessonUseCase extends Mock
    implements UpdateLessonUseCase {}

class MockDeleteLessonUseCase extends Mock
    implements DeleteLessonUseCase {}

// Lesson exams feature mocks
class MockLessonExamsRemoteDataSource extends Mock
    implements LessonExamsRemoteDataSource {}

class MockLessonExamRepository extends Mock
    implements LessonExamRepository {}

class MockStreamLessonExamUseCase extends Mock
    implements StreamLessonExamUseCase {}

class MockCreateLessonExamQuestionUseCase extends Mock
    implements CreateLessonExamQuestionUseCase {}

class MockUpdateLessonExamQuestionUseCase extends Mock
    implements UpdateLessonExamQuestionUseCase {}

class MockDeleteLessonExamQuestionUseCase extends Mock
    implements DeleteLessonExamQuestionUseCase {}

class MockSaveLessonExamAnswersUseCase extends Mock
    implements SaveLessonExamAnswersUseCase {}

// Study notes feature mocks
class MockStudyNotesRemoteDataSource extends Mock
    implements StudyNotesRemoteDataSource {}

class MockStudyNotesRepository extends Mock
    implements StudyNotesRepository {}

class MockGetStudyNotesUseCase extends Mock
    implements GetStudyNotesUseCase {}

class MockGetStudyNoteByIdUseCase extends Mock
    implements GetStudyNoteByIdUseCase {}

class MockStreamStudyNotesUseCase extends Mock
    implements StreamStudyNotesUseCase {}

class MockCreateStudyNoteUseCase extends Mock
    implements CreateStudyNoteUseCase {}

class MockUpdateStudyNoteUseCase extends Mock
    implements UpdateStudyNoteUseCase {}

class MockDeleteStudyNoteUseCase extends Mock
    implements DeleteStudyNoteUseCase {}

// Dashboard feature mocks
class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

class MockDashboardLocalDataSource extends Mock
    implements DashboardLocalDataSource {}

class MockDashboardRepository extends Mock
    implements DashboardRepository {}

class MockGetDashboardStudentsSummaryUseCase extends Mock
    implements GetDashboardStudentsSummaryUseCase {}

// Exams feature use case mocks
class MockGetExamsUseCase extends Mock
    implements GetExamsUseCase {}

class MockStreamExamsUseCase extends Mock
    implements StreamExamsUseCase {}

class MockGetExamByIdUseCase extends Mock
    implements GetExamByIdUseCase {}

class MockGetExamResultsUseCase extends Mock
    implements GetExamResultsUseCase {}

class MockStreamExamResultsUseCase extends Mock
    implements StreamExamResultsUseCase {}

class MockCreateExamUseCase extends Mock
    implements CreateExamUseCase {}

class MockCreateExamQuestionUseCase extends Mock
    implements CreateExamQuestionUseCase {}

class MockUpdateExamUseCase extends Mock
    implements UpdateExamUseCase {}

class MockUpdateExamQuestionUseCase extends Mock
    implements UpdateExamQuestionUseCase {}

class MockDeleteExamUseCase extends Mock
    implements DeleteExamUseCase {}

class MockDeleteExamQuestionUseCase extends Mock
    implements DeleteExamQuestionUseCase {}

// Live session feature mocks
class MockLiveSessionsRemoteDataSource extends Mock
    implements LiveSessionsRemoteDataSource {}

class MockLiveSessionsRepository extends Mock
    implements LiveSessionsRepository {}

// Grades feature mocks
class MockGradesRemoteDataSource extends Mock
    implements GradesRemoteDataSource {}

class MockGradesRepository extends Mock
    implements GradesRepository {}

// Result student feature mocks
class MockStudentExamResultsRemoteDataSource extends Mock
    implements StudentExamResultsRemoteDataSource {}

class MockStudentExamResultsRepository extends Mock
    implements StudentExamResultsRepository {}
