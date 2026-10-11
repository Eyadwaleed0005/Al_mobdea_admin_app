import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockCreateLessonUseCase mockCreateLessonUseCase;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
    registerFallbackValue(tLessonEntity);
  });

  setUp(() {
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockCreateLessonUseCase = MockCreateLessonUseCase();
  });

  AddLessonCubit buildCubit() {
    return AddLessonCubit(
      streamGradesUseCase: mockStreamGradesUseCase,
      createLessonUseCase: mockCreateLessonUseCase,
    );
  }

  void stubGradesSuccess({List<GradeEntity>? grades}) {
    final effectiveGrades = grades ?? [tGradeEntity];

    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Right(effectiveGrades),
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

  void stubCreateLessonSuccess() {
    when(
      () => mockCreateLessonUseCase(
        lesson: any(named: 'lesson'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right(unit));
  }

  void stubCreateLessonFailure(AppErrorModel error) {
    when(
      () => mockCreateLessonUseCase(
        lesson: any(named: 'lesson'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => Left(error));
  }

  void fillValidForm(AddLessonCubit cubit) {
    cubit.changeTitle(tLessonTitle);
    cubit.changeSubtitle(tLessonSubtitle);
    cubit.changeYoutubeUrl(tYoutubeUrl);
    cubit.selectGrade(tGradeId);
  }

  test('initial state is idle with empty form', () async {
    final cubit = buildCubit();

    expect(cubit.state.pageStatus, AddLessonPageStatus.initial);
    expect(cubit.state.submissionStatus, AddLessonSubmissionStatus.idle);
    expect(cubit.state.grades, isEmpty);
    expect(cubit.state.isPublished, isFalse);
    expect(cubit.state.selectedPdf, isNull);

    await cubit.close();
  });

  blocTest<AddLessonCubit, AddLessonState>(
    'initialize emits loading then ready when the grades stream emits',
    setUp: stubGradesSuccess,
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddLessonState>()
          .having((s) => s.pageStatus, 'pageStatus', AddLessonPageStatus.loading)
          .having((s) => s.grades, 'grades', isEmpty),
      isA<AddLessonState>()
          .having((s) => s.pageStatus, 'pageStatus', AddLessonPageStatus.ready)
          .having((s) => s.isPageReady, 'isPageReady', isTrue)
          .having((s) => s.grades.map((grade) => grade.gradeId), 'grades', [
            tGradeId,
          ]),
    ],
    verify: (_) {
      verify(() => mockStreamGradesUseCase(activeOnly: true)).called(1);
    },
  );

  blocTest<AddLessonCubit, AddLessonState>(
    'initialize emits page failure when the grades stream fails',
    setUp: stubGradesFailure,
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddLessonState>().having(
        (s) => s.pageStatus,
        'pageStatus',
        AddLessonPageStatus.loading,
      ),
      isA<AddLessonState>()
          .having((s) => s.pageStatus, 'pageStatus', AddLessonPageStatus.failure)
          .having((s) => s.hasPageFailure, 'hasPageFailure', isTrue)
          .having((s) => s.error?.message, 'error', 'grades stream failed'),
    ],
  );

  blocTest<AddLessonCubit, AddLessonState>(
    'form field changes update the state and reset the submission status',
    setUp: stubGradesSuccess,
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.changeTitle(tLessonTitle);
      cubit.changeSubtitle(tLessonSubtitle);
      cubit.changeYoutubeUrl(tYoutubeUrl);
      cubit.selectGrade(' $tGradeId ');
      cubit.changePublicationStatus(true);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>().having((s) => s.title, 'title', tLessonTitle),
      isA<AddLessonState>().having((s) => s.subtitle, 'subtitle', tLessonSubtitle),
      isA<AddLessonState>().having((s) => s.youtubeUrl, 'youtubeUrl', tYoutubeUrl),
      isA<AddLessonState>().having((s) => s.selectedGradeId, 'grade', tGradeId),
      isA<AddLessonState>()
          .having((s) => s.isPublished, 'isPublished', isTrue)
          .having((s) => s.submissionStatus, 'submissionStatus', AddLessonSubmissionStatus.idle),
    ],
  );

  blocTest<AddLessonCubit, AddLessonState>(
    'selectPdf and removePdf update the selected PDF file',
    setUp: stubGradesSuccess,
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.selectPdf(
        const AddLessonPdfFile(
          name: tPdfFileName,
          path: tLocalPdfFilePath,
          sizeInBytes: tPdfFileSize,
        ),
      );

      cubit.removePdf();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>()
          .having((s) => s.hasSelectedPdf, 'hasSelectedPdf', isTrue)
          .having((s) => s.selectedPdf?.name, 'pdfName', tPdfFileName)
          .having((s) => s.hasValidPdf, 'hasValidPdf', isTrue),
      isA<AddLessonState>()
          .having((s) => s.selectedPdf, 'selectedPdf', isNull)
          .having((s) => s.hasSelectedPdf, 'hasSelectedPdf', isFalse),
    ],
  );

  test('canSubmit requires a valid form and a ready page', () async {
    stubGradesSuccess();

    final cubit = buildCubit();

    await cubit.initialize();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(cubit.state.canSubmit, isFalse);

    fillValidForm(cubit);

    expect(cubit.state.canSubmit, isTrue);
    expect(cubit.state.hasValidPdf, isTrue);

    cubit.changeYoutubeUrl('not-a-youtube-link');

    expect(cubit.state.hasValidYoutubeUrl, isFalse);
    expect(cubit.state.canSubmit, isFalse);

    await cubit.close();
  });

  test('createLesson is ignored while the form is invalid', () async {
    stubGradesSuccess();
    stubCreateLessonSuccess();

    final cubit = buildCubit();

    await cubit.initialize();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await cubit.createLesson();

    expect(cubit.state.submissionStatus, AddLessonSubmissionStatus.idle);

    verifyNever(
      () => mockCreateLessonUseCase(
        lesson: any(named: 'lesson'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    );

    await cubit.close();
  });

  blocTest<AddLessonCubit, AddLessonState>(
    'createLesson submits the form and emits success',
    setUp: () {
      stubGradesSuccess();
      stubCreateLessonSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      fillValidForm(cubit);

      cubit.selectPdf(
        const AddLessonPdfFile(
          name: tPdfFileName,
          path: tLocalPdfFilePath,
          sizeInBytes: tPdfFileSize,
        ),
      );

      await cubit.createLesson();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>()
          .having((s) => s.isSubmitting, 'isSubmitting', isTrue)
          .having((s) => s.submissionStatus, 'submissionStatus', AddLessonSubmissionStatus.loading),
      isA<AddLessonState>()
          .having((s) => s.submissionSucceeded, 'submissionSucceeded', isTrue)
          .having((s) => s.error, 'error', isNull),
    ],
    verify: (_) {
      final captured = verify(
        () => mockCreateLessonUseCase(
          lesson: captureAny(named: 'lesson'),
          localPdfFilePath: captureAny(named: 'localPdfFilePath'),
        ),
      ).captured;

      final submittedLesson = captured.first as LessonEntity;

      expect(submittedLesson.title, tLessonTitle);
      expect(submittedLesson.subtitle, tLessonSubtitle);
      expect(submittedLesson.youtubeUrl, tYoutubeUrl);
      expect(submittedLesson.gradeId, tGradeId);
      expect(submittedLesson.pdfFileName, tPdfFileName);
      expect(submittedLesson.pdfFileSize, tPdfFileSize);
      expect(submittedLesson.isPublished, isFalse);
      expect(submittedLesson.lessonId, startsWith('lesson_'));
      expect(captured.last, tLocalPdfFilePath);
    },
  );

  blocTest<AddLessonCubit, AddLessonState>(
    'createLesson emits a submission failure with the error',
    setUp: () {
      stubGradesSuccess();

      stubCreateLessonFailure(
        AppErrorModel(
          code: 'firestore-error',
          message: 'create failed',
          type: AppErrorType.unknown,
          isRetryable: true,
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      fillValidForm(cubit);

      await cubit.createLesson();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>()
          .having((s) => s.isSubmitting, 'isSubmitting', isTrue),
      isA<AddLessonState>()
          .having((s) => s.submissionFailed, 'submissionFailed', isTrue)
          .having((s) => s.error?.message, 'error', 'create failed'),
    ],
  );

  blocTest<AddLessonCubit, AddLessonState>(
    'consumeSubmissionResult resets the submission status to idle',
    setUp: () {
      stubGradesSuccess();
      stubCreateLessonSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      fillValidForm(cubit);

      await cubit.createLesson();

      cubit.consumeSubmissionResult();
    },
    wait: const Duration(milliseconds: 100),
    skip: 6,
    expect: () => [
      isA<AddLessonState>()
          .having((s) => s.isSubmitting, 'isSubmitting', isTrue),
      isA<AddLessonState>()
          .having((s) => s.submissionSucceeded, 'submissionSucceeded', isTrue),
      isA<AddLessonState>()
          .having((s) => s.submissionStatus, 'submissionStatus', AddLessonSubmissionStatus.idle)
          .having((s) => s.error, 'error', isNull),
    ],
  );

  blocTest<AddLessonCubit, AddLessonState>(
    'retry re-subscribes to the grades stream',
    setUp: stubGradesSuccess,
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
      isA<AddLessonState>(),
    ],
    verify: (_) {
      verify(() => mockStreamGradesUseCase(activeOnly: true)).called(2);
    },
  );

  test('close cancels the grades subscription', () async {
    stubGradesSuccess();

    final cubit = buildCubit();

    await cubit.initialize();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await expectLater(cubit.close(), completes);
  });
}
