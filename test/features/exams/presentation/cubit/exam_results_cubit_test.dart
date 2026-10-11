import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_result_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/exam_results_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/exam_results_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGetExamByIdUseCase mockGetExamByIdUseCase;
  late MockGetExamResultsUseCase mockGetExamResultsUseCase;
  late MockStreamExamResultsUseCase mockStreamExamResultsUseCase;

  final AppErrorModel tError = AppErrorModel(
    code: 'firestore-error',
    message: 'results failed',
    type: AppErrorType.unknown,
    isRetryable: true,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockGetExamByIdUseCase = MockGetExamByIdUseCase();
    mockGetExamResultsUseCase = MockGetExamResultsUseCase();
    mockStreamExamResultsUseCase = MockStreamExamResultsUseCase();
  });

  ExamResultsCubit buildCubit() {
    return ExamResultsCubit(
      getExamByIdUseCase: mockGetExamByIdUseCase,
      getExamResultsUseCase: mockGetExamResultsUseCase,
      streamExamResultsUseCase: mockStreamExamResultsUseCase,
    );
  }

  void stubExamSuccess({ExamEntity? exam}) {
    when(
      () => mockGetExamByIdUseCase(examId: any(named: 'examId')),
    ).thenAnswer((_) async => Right(exam ?? tEndedExamEntity));
  }

  void stubExamFailure() {
    when(
      () => mockGetExamByIdUseCase(examId: any(named: 'examId')),
    ).thenAnswer((_) async => Left(tError));
  }

  void stubResultsStream({List<ExamResultEntity>? results}) {
    when(
      () => mockStreamExamResultsUseCase(examId: any(named: 'examId')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<ExamResultEntity>>>.value(
        Right(results ?? <ExamResultEntity>[tExamResultEntity]),
      ),
    );
  }

  void stubResultsStreamFailure() {
    when(
      () => mockStreamExamResultsUseCase(examId: any(named: 'examId')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<ExamResultEntity>>>.value(
        Left(tError),
      ),
    );
  }

  test('initial state is ExamResultsInitial', () async {
    final cubit = buildCubit();

    expect(cubit.state, isA<ExamResultsInitial>());

    await cubit.close();
  });

  blocTest<ExamResultsCubit, ExamResultsState>(
    'loadExamResults emits loading then success with the report',
    setUp: () {
      stubExamSuccess();
      stubResultsStream();
    },
    build: buildCubit,
    act: (cubit) => cubit.loadExamResults(examId: tExamId),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ExamResultsLoading>(),
      isA<ExamResultsSuccess>()
          .having((state) => state.report.exam.examId, 'exam id', tExamId)
          .having(
            (state) => state.report.results.length,
            'results count',
            1,
          )
          .having(
            (state) => state.report.submittedCount,
            'submitted count',
            1,
          )
          .having(
            (state) => state.report.passedStudentsCount,
            'passed count',
            1,
          )
          .having(
            (state) => state.report.averagePercentage,
            'average percentage',
            80,
          ),
    ],
    verify: (_) {
      verify(
        () => mockGetExamByIdUseCase(examId: tExamId),
      ).called(1);
      verify(
        () => mockStreamExamResultsUseCase(examId: tExamId),
      ).called(1);
    },
  );

  blocTest<ExamResultsCubit, ExamResultsState>(
    'loadExamResults emits empty when the exam has no attempts',
    setUp: () {
      stubExamSuccess();
      stubResultsStream(results: <ExamResultEntity>[]);
    },
    build: buildCubit,
    act: (cubit) => cubit.loadExamResults(examId: tExamId),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ExamResultsLoading>(),
      isA<ExamResultsEmpty>().having(
        (state) => state.exam.examId,
        'exam id',
        tExamId,
      ),
    ],
  );

  blocTest<ExamResultsCubit, ExamResultsState>(
    'loadExamResults keeps in-progress attempts in the report',
    setUp: () {
      stubExamSuccess();
      stubResultsStream(results: <ExamResultEntity>[tInProgressExamResultEntity]);
    },
    build: buildCubit,
    act: (cubit) => cubit.loadExamResults(examId: tExamId),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ExamResultsLoading>(),
      isA<ExamResultsSuccess>()
          .having(
            (state) => state.report.inProgressCount,
            'in progress count',
            1,
          )
          .having(
            (state) => state.report.submittedCount,
            'submitted count',
            0,
          ),
    ],
  );

  blocTest<ExamResultsCubit, ExamResultsState>(
    'loadExamResults emits error when the exam cannot be loaded',
    setUp: () {
      stubExamFailure();
      stubResultsStream();
    },
    build: buildCubit,
    act: (cubit) => cubit.loadExamResults(examId: tExamId),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ExamResultsLoading>(),
      isA<ExamResultsError>().having(
        (state) => state.error.message,
        'error message',
        tError.message,
      ),
    ],
  );

  blocTest<ExamResultsCubit, ExamResultsState>(
    'loadExamResults emits error when the results stream fails',
    setUp: () {
      stubExamSuccess();
      stubResultsStreamFailure();
    },
    build: buildCubit,
    act: (cubit) => cubit.loadExamResults(examId: tExamId),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ExamResultsLoading>(),
      isA<ExamResultsError>(),
    ],
  );

  blocTest<ExamResultsCubit, ExamResultsState>(
    'refreshExamResults fetches the results list again',
    setUp: () {
      stubExamSuccess();
      stubResultsStream();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadExamResults(examId: tExamId);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      when(
        () => mockGetExamResultsUseCase(examId: any(named: 'examId')),
      ).thenAnswer(
        (_) async => Right(<ExamResultEntity>[
          tExamResultEntity,
          tExamResultEntity.copyWith(
            resultId: 'exam-123_student-456',
            studentId: 'student-456',
          ),
        ]),
      );

      await cubit.refreshExamResults();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ExamResultsLoading>(),
      isA<ExamResultsSuccess>(),
      isA<ExamResultsSuccess>().having(
        (state) => state.report.results.length,
        'results count',
        2,
      ),
    ],
  );

  blocTest<ExamResultsCubit, ExamResultsState>(
    'retry reloads the exam and its results',
    setUp: () {
      stubExamFailure();
      stubResultsStream();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadExamResults(examId: tExamId);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      stubExamSuccess();

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ExamResultsLoading>(),
      isA<ExamResultsError>(),
      isA<ExamResultsLoading>(),
      isA<ExamResultsSuccess>(),
    ],
  );

  test('refreshExamResults is ignored before an exam is loaded', () async {
    final cubit = buildCubit();

    await cubit.refreshExamResults();

    expect(cubit.state, isA<ExamResultsInitial>());

    await cubit.close();
  });

  test('close cancels the results subscription', () async {
    stubExamSuccess();
    stubResultsStream();

    final cubit = buildCubit();

    await cubit.loadExamResults(examId: tExamId);

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await cubit.close();

    expect(cubit.isClosed, isTrue);
  });
}
