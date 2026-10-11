import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/edit_exam_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/edit_exam_state.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGetExamByIdUseCase mockGetExamByIdUseCase;
  late MockUpdateExamUseCase mockUpdateExamUseCase;
  late MockDeleteExamUseCase mockDeleteExamUseCase;
  late MockGradesRepository mockGradesRepository;

  final AppErrorModel tError = AppErrorModel(
    code: 'firestore-error',
    message: 'operation failed',
    type: AppErrorType.unknown,
    isRetryable: true,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(tExamEntity);
  });

  setUp(() {
    mockGetExamByIdUseCase = MockGetExamByIdUseCase();
    mockUpdateExamUseCase = MockUpdateExamUseCase();
    mockDeleteExamUseCase = MockDeleteExamUseCase();
    mockGradesRepository = MockGradesRepository();
  });

  EditExamCubit buildCubit({String examId = tExamId}) {
    return EditExamCubit(
      examId: examId,
      getExamByIdUseCase: mockGetExamByIdUseCase,
      updateExamUseCase: mockUpdateExamUseCase,
      deleteExamUseCase: mockDeleteExamUseCase,
      gradesRepository: mockGradesRepository,
    );
  }

  void stubExamSuccess({ExamEntity? exam}) {
    when(
      () => mockGetExamByIdUseCase(examId: any(named: 'examId')),
    ).thenAnswer((_) async => Right(exam ?? tExamEntity));
  }

  void stubExamFailure() {
    when(
      () => mockGetExamByIdUseCase(examId: any(named: 'examId')),
    ).thenAnswer((_) async => Left(tError));
  }

  void stubGrades({List<GradeEntity>? grades}) {
    when(
      () => mockGradesRepository.streamGrades(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Right(grades ?? <GradeEntity>[tGradeEntity]),
      ),
    );
  }

  void stubGradesFailure() {
    when(
      () => mockGradesRepository.streamGrades(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Left(tError),
      ),
    );
  }

  test('initial state is EditExamLoading', () async {
    final cubit = buildCubit();

    expect(cubit.state, isA<EditExamLoading>());

    await cubit.close();
  });

  blocTest<EditExamCubit, EditExamState>(
    'initialize emits loading then ready with the exam and grades',
    setUp: () {
      stubExamSuccess();
      stubGrades();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    expect: () => [
      isA<EditExamLoading>(),
      isA<EditExamReady>()
          .having((state) => state.exam.examId, 'exam id', tExamId)
          .having((state) => state.grades.length, 'grades count', 1)
          .having((state) => state.canEditForm, 'can edit form', isTrue),
    ],
    verify: (_) {
      verify(() => mockGetExamByIdUseCase(examId: tExamId)).called(1);
      verify(
        () => mockGradesRepository.streamGrades(activeOnly: false),
      ).called(1);
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'initialize emits error when the exam cannot be loaded',
    setUp: () {
      stubExamFailure();
      stubGrades();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    expect: () => [
      isA<EditExamLoading>(),
      isA<EditExamError>().having(
        (state) => state.error.message,
        'error message',
        tError.message,
      ),
    ],
  );

  blocTest<EditExamCubit, EditExamState>(
    'initialize emits error when the grades stream fails',
    setUp: () {
      stubExamSuccess();
      stubGradesFailure();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    expect: () => [isA<EditExamLoading>(), isA<EditExamError>()],
  );

  blocTest<EditExamCubit, EditExamState>(
    'saveChanges emits the operating state then the success state',
    setUp: () {
      stubExamSuccess();
      stubGrades();

      when(
        () => mockUpdateExamUseCase(exam: any(named: 'exam')),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.saveChanges(
        examName: '  اختبار محدث  ',
        gradeId: tGradeId,
        durationMinutes: 90,
        isPublished: true,
      );
    },
    expect: () => [
      isA<EditExamLoading>(),
      isA<EditExamReady>(),
      isA<EditExamReady>()
          .having((state) => state.isOperating, 'is operating', isTrue)
          .having(
            (state) => state.operation,
            'operation',
            EditExamOperation.save,
          ),
      isA<EditExamReady>()
          .having((state) => state.operationSucceeded, 'succeeded', isTrue)
          .having(
            (state) => state.operation,
            'operation',
            EditExamOperation.save,
          ),
    ],
    verify: (_) {
      final ExamEntity captured = verify(
        () => mockUpdateExamUseCase(exam: captureAny(named: 'exam')),
      ).captured.single as ExamEntity;

      expect(captured.examName, 'اختبار محدث');
      expect(captured.gradeId, tGradeId);
      expect(captured.durationMinutes, 90);
      expect(captured.status, ExamStatus.published);
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'saveChanges emits the operation error when the update fails',
    setUp: () {
      stubExamSuccess();
      stubGrades();

      when(
        () => mockUpdateExamUseCase(exam: any(named: 'exam')),
      ).thenAnswer((_) async => Left(tError));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.saveChanges(
        examName: 'اختبار محدث',
        gradeId: tGradeId,
        durationMinutes: 90,
        isPublished: false,
      );
    },
    expect: () => [
      isA<EditExamLoading>(),
      isA<EditExamReady>(),
      isA<EditExamReady>().having(
        (state) => state.isOperating,
        'is operating',
        isTrue,
      ),
      isA<EditExamReady>().having(
        (state) => state.operationError?.message,
        'operation error',
        tError.message,
      ),
    ],
  );

  blocTest<EditExamCubit, EditExamState>(
    'saveChanges ignores an empty exam name',
    setUp: () {
      stubExamSuccess();
      stubGrades();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.saveChanges(
        examName: '   ',
        gradeId: tGradeId,
        durationMinutes: 90,
        isPublished: false,
      );
    },
    expect: () => [isA<EditExamLoading>(), isA<EditExamReady>()],
    verify: (_) {
      verifyNever(() => mockUpdateExamUseCase(exam: any(named: 'exam')));
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'saveChanges ignores a grade that is not available',
    setUp: () {
      stubExamSuccess();
      stubGrades();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.saveChanges(
        examName: tExamName,
        gradeId: 'missing-grade',
        durationMinutes: 90,
        isPublished: false,
      );
    },
    expect: () => [isA<EditExamLoading>(), isA<EditExamReady>()],
    verify: (_) {
      verifyNever(() => mockUpdateExamUseCase(exam: any(named: 'exam')));
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'saveChanges ignores an invalid duration',
    setUp: () {
      stubExamSuccess();
      stubGrades();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.saveChanges(
        examName: tExamName,
        gradeId: tGradeId,
        durationMinutes: 0,
        isPublished: false,
      );
    },
    expect: () => [isA<EditExamLoading>(), isA<EditExamReady>()],
    verify: (_) {
      verifyNever(() => mockUpdateExamUseCase(exam: any(named: 'exam')));
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'closeExam marks a published exam as ended',
    setUp: () {
      stubExamSuccess(exam: tPublishedExamEntity);
      stubGrades();

      when(
        () => mockUpdateExamUseCase(exam: any(named: 'exam')),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.closeExam();
    },
    expect: () => [
      isA<EditExamLoading>(),
      isA<EditExamReady>(),
      isA<EditExamReady>().having(
        (state) => state.operation,
        'operation',
        EditExamOperation.close,
      ),
      isA<EditExamReady>().having(
        (state) => state.operationSucceeded,
        'succeeded',
        isTrue,
      ),
    ],
    verify: (_) {
      final ExamEntity captured = verify(
        () => mockUpdateExamUseCase(exam: captureAny(named: 'exam')),
      ).captured.single as ExamEntity;

      expect(captured.status, ExamStatus.ended);
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'closeExam is ignored when the exam is not published',
    setUp: () {
      stubExamSuccess();
      stubGrades();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.closeExam();
    },
    expect: () => [isA<EditExamLoading>(), isA<EditExamReady>()],
    verify: (_) {
      verifyNever(() => mockUpdateExamUseCase(exam: any(named: 'exam')));
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'deleteExam removes the exam',
    setUp: () {
      stubExamSuccess();
      stubGrades();

      when(
        () => mockDeleteExamUseCase(examId: any(named: 'examId')),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await cubit.deleteExam();
    },
    expect: () => [
      isA<EditExamLoading>(),
      isA<EditExamReady>(),
      isA<EditExamReady>().having(
        (state) => state.operation,
        'operation',
        EditExamOperation.delete,
      ),
      isA<EditExamReady>().having(
        (state) => state.operationSucceeded,
        'succeeded',
        isTrue,
      ),
    ],
    verify: (_) {
      verify(() => mockDeleteExamUseCase(examId: tExamId)).called(1);
    },
  );

  blocTest<EditExamCubit, EditExamState>(
    'retry reloads the exam after a failure',
    setUp: () {
      stubExamFailure();
      stubGrades();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      stubExamSuccess();

      await cubit.retry();
    },
    expect: () => [
      isA<EditExamLoading>(),
      isA<EditExamError>(),
      isA<EditExamLoading>(),
      isA<EditExamReady>(),
    ],
  );
}
