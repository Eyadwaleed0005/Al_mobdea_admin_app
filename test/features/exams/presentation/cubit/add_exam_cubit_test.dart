import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_state.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStreamGradesUseCase mockStreamGradesUseCase;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
  });

  setUp(() {
    mockStreamGradesUseCase = MockStreamGradesUseCase();
  });

  AddExamCubit buildCubit() {
    return AddExamCubit(streamGradesUseCase: mockStreamGradesUseCase);
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

  void stubGradesEmpty() {
    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Right(<GradeEntity>[]),
      ),
    );
  }

  void stubGradesFailure() {
    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Left(
          AppErrorModel(
            code: 'firestore-error',
            message: 'grades stream failed',
            type: AppErrorType.unknown,
            isRetryable: true,
          ),
        ),
      ),
    );
  }

  test('initial state is AddExamLoading', () async {
    final cubit = buildCubit();

    expect(cubit.state, isA<AddExamLoading>());

    await cubit.close();
  });

  blocTest<AddExamCubit, AddExamState>(
    'loadGrades emits loading then success with the active grades',
    setUp: () => stubGradesSuccess(),
    build: buildCubit,
    act: (cubit) => cubit.loadGrades(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddExamLoading>(),
      isA<AddExamSuccess>().having(
        (state) => state.grades.map((grade) => grade.gradeId),
        'grade ids',
        [tGradeId],
      ),
    ],
    verify: (_) {
      verify(() => mockStreamGradesUseCase(activeOnly: true)).called(1);
    },
  );

  blocTest<AddExamCubit, AddExamState>(
    'loadGrades emits empty when there are no active grades',
    setUp: stubGradesEmpty,
    build: buildCubit,
    act: (cubit) => cubit.loadGrades(),
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<AddExamLoading>(), isA<AddExamEmpty>()],
  );

  blocTest<AddExamCubit, AddExamState>(
    'loadGrades emits error when the grades stream fails',
    setUp: stubGradesFailure,
    build: buildCubit,
    act: (cubit) => cubit.loadGrades(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddExamLoading>(),
      isA<AddExamError>().having(
        (state) => state.error.message,
        'error message',
        'grades stream failed',
      ),
    ],
  );

  blocTest<AddExamCubit, AddExamState>(
    'retry reloads the grades stream',
    setUp: stubGradesFailure,
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadGrades();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      stubGradesSuccess();

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddExamLoading>(),
      isA<AddExamError>(),
      isA<AddExamLoading>(),
      isA<AddExamSuccess>(),
    ],
  );

  test('createDraft trims the values and marks an unpublished exam', () async {
    final cubit = buildCubit();

    final ExamDraftEntity draft = cubit.createDraft(
      examName: '  اختبار الباب الأول  ',
      gradeId: '  $tGradeId  ',
      durationMinutes: 120,
      isPublished: false,
    );

    expect(draft.examName, 'اختبار الباب الأول');
    expect(draft.gradeId, tGradeId);
    expect(draft.durationMinutes, 120);
    expect(draft.status, ExamStatus.unpublished);
    expect(draft.isUnpublished, isTrue);

    await cubit.close();
  });

  test('createDraft marks a published exam when requested', () async {
    final cubit = buildCubit();

    final ExamDraftEntity draft = cubit.createDraft(
      examName: tExamName,
      gradeId: tGradeId,
      durationMinutes: tExamDurationMinutes,
      isPublished: true,
    );

    expect(draft.status, ExamStatus.published);
    expect(draft.isPublished, isTrue);

    await cubit.close();
  });

  test('close cancels the grades subscription', () async {
    stubGradesSuccess();

    final cubit = buildCubit();

    await cubit.loadGrades();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await cubit.close();

    expect(cubit.isClosed, isTrue);
  });
}
