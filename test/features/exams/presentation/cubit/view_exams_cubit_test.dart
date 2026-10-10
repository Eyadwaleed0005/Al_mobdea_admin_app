import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/view_exams_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/view_exams_state.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStreamExamsUseCase mockStreamExamsUseCase;
  late MockStreamGradesUseCase mockStreamGradesUseCase;

  final AppErrorModel tError = AppErrorModel(
    code: 'firestore-error',
    message: 'stream failed',
    type: AppErrorType.unknown,
    isRetryable: true,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
  });

  setUp(() {
    mockStreamExamsUseCase = MockStreamExamsUseCase();
    mockStreamGradesUseCase = MockStreamGradesUseCase();
  });

  ViewExamsCubit buildCubit() {
    return ViewExamsCubit(
      streamExamsUseCase: mockStreamExamsUseCase,
      streamGradesUseCase: mockStreamGradesUseCase,
    );
  }

  void stubGradesSuccess({List<GradeEntity>? grades}) {
    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Right(grades ?? <GradeEntity>[tGradeEntity]),
      ),
    );
  }

  void stubGradesFailure() {
    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Left(tError),
      ),
    );
  }

  void stubExamsSuccess({List<ExamEntity>? exams}) {
    when(
      () => mockStreamExamsUseCase(),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<ExamEntity>>>.value(
        Right(exams ?? <ExamEntity>[tExamEntity]),
      ),
    );
  }

  void stubExamsFailure() {
    when(
      () => mockStreamExamsUseCase(),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<ExamEntity>>>.value(
        Left(tError),
      ),
    );
  }

  test('initial state is ViewExamsLoading', () async {
    final cubit = buildCubit();

    expect(cubit.state, isA<ViewExamsLoading>());
    expect(cubit.searchQuery, isEmpty);
    expect(cubit.selectedGradeId, isEmpty);
    expect(cubit.selectedStatus, isNull);

    await cubit.close();
  });

  blocTest<ViewExamsCubit, ViewExamsState>(
    'loadData emits loading then success with exams and grades',
    setUp: () {
      stubGradesSuccess();
      stubExamsSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.loadData(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsSuccess>()
          .having(
            (state) => state.exams.map((exam) => exam.examId),
            'exam ids',
            [tExamId],
          )
          .having(
            (state) => state.grades.map((grade) => grade.gradeId),
            'grade ids',
            [tGradeId],
          ),
    ],
    verify: (_) {
      verify(() => mockStreamExamsUseCase()).called(1);
      verify(() => mockStreamGradesUseCase(activeOnly: true)).called(1);
    },
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'loadData emits empty when there are no exams',
    setUp: () {
      stubGradesSuccess();
      stubExamsSuccess(exams: <ExamEntity>[]);
    },
    build: buildCubit,
    act: (cubit) => cubit.loadData(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsEmpty>().having(
        (state) => state.grades.length,
        'grades count',
        1,
      ),
    ],
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'loadData emits error when the exams stream fails',
    setUp: () {
      stubGradesSuccess();
      stubExamsFailure();
    },
    build: buildCubit,
    act: (cubit) => cubit.loadData(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsError>().having(
        (state) => state.error.message,
        'error message',
        tError.message,
      ),
      isA<ViewExamsError>(),
    ],
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'loadData emits error when the grades stream fails',
    setUp: () {
      stubGradesFailure();
      stubExamsSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.loadData(),
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<ViewExamsLoading>(), isA<ViewExamsError>()],
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'searchExams filters exams by name',
    setUp: () {
      stubGradesSuccess();
      stubExamsSuccess(
        exams: <ExamEntity>[
          tExamEntity,
          tExamEntity.copyWith(examId: tSecondExamId, examName: 'نتائج النحو'),
        ],
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadData();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.searchExams('نتائج');
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsSuccess>().having(
        (state) => state.exams.length,
        'exams count',
        2,
      ),
      isA<ViewExamsSuccess>()
          .having((state) => state.exams.length, 'filtered count', 1)
          .having(
            (state) => state.exams.first.examId,
            'filtered exam id',
            tSecondExamId,
          ),
    ],
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'selectStatus filters exams by publication status',
    setUp: () {
      stubGradesSuccess();
      stubExamsSuccess(
        exams: <ExamEntity>[tExamEntity, tPublishedExamEntity],
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadData();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.selectStatus(ExamStatus.published);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsSuccess>(),
      isA<ViewExamsSuccess>()
          .having((state) => state.exams.length, 'filtered count', 1)
          .having(
            (state) => state.exams.first.status,
            'filtered status',
            ExamStatus.published,
          ),
    ],
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'selectStatus with null keeps all exams',
    setUp: () {
      stubGradesSuccess();
      stubExamsSuccess(
        exams: <ExamEntity>[tExamEntity, tPublishedExamEntity],
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadData();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.selectStatus(null);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsSuccess>(),
      isA<ViewExamsSuccess>().having(
        (state) => state.exams.length,
        'filtered count',
        2,
      ),
    ],
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'selectGrade filters exams by grade id',
    setUp: () {
      stubGradesSuccess(grades: <GradeEntity>[tGradeEntity, tSecondGradeEntity]);
      stubExamsSuccess(
        exams: <ExamEntity>[
          tExamEntity,
          tExamEntity.copyWith(
            examId: tSecondExamId,
            gradeId: tSecondGradeEntity.gradeId,
          ),
        ],
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadData();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.selectGrade(tSecondGradeEntity.gradeId);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsSuccess>(),
      isA<ViewExamsSuccess>()
          .having((state) => state.exams.length, 'filtered count', 1)
          .having(
            (state) => state.exams.first.gradeId,
            'filtered grade id',
            tSecondGradeEntity.gradeId,
          ),
    ],
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'refreshData restarts streams without emitting the loading state',
    setUp: () {
      stubGradesSuccess();
      stubExamsSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadData();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.refreshData();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsSuccess>(),
      isA<ViewExamsSuccess>(),
    ],
    verify: (_) {
      verify(() => mockStreamExamsUseCase()).called(2);
    },
  );

  blocTest<ViewExamsCubit, ViewExamsState>(
    'retry reloads the streams after a failure',
    setUp: () {
      stubGradesSuccess();
      stubExamsFailure();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadData();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      stubExamsSuccess();

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewExamsLoading>(),
      isA<ViewExamsError>(),
      isA<ViewExamsError>(),
      isA<ViewExamsLoading>(),
      isA<ViewExamsSuccess>(),
    ],
  );

  test('close cancels the exams and grades subscriptions', () async {
    stubGradesSuccess();
    stubExamsSuccess();

    final cubit = buildCubit();

    await cubit.loadData();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await cubit.close();

    expect(cubit.isClosed, isTrue);
  });
}
