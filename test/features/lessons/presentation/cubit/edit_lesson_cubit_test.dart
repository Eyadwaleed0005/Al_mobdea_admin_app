import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/edit_lesson_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/edit_lesson_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGetLessonByIdUseCase mockGetLessonByIdUseCase;
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockUpdateLessonUseCase mockUpdateLessonUseCase;
  late MockDeleteLessonUseCase mockDeleteLessonUseCase;

  const String updatedTitle = 'الجملة الاسمية';

  final AppErrorModel updateError = AppErrorModel(
    code: 'firestore-error',
    message: 'update failed',
    type: AppErrorType.unknown,
    isRetryable: true,
  );

  final AppErrorModel deleteError = AppErrorModel(
    code: 'firestore-error',
    message: 'delete failed',
    type: AppErrorType.unknown,
    isRetryable: true,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
    registerFallbackValue(tLessonEntity);
  });

  setUp(() {
    mockGetLessonByIdUseCase = MockGetLessonByIdUseCase();
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockUpdateLessonUseCase = MockUpdateLessonUseCase();
    mockDeleteLessonUseCase = MockDeleteLessonUseCase();
  });

  EditLessonCubit buildCubit() {
    return EditLessonCubit(
      lessonId: ' $tLessonId ',
      getLessonByIdUseCase: mockGetLessonByIdUseCase,
      streamGradesUseCase: mockStreamGradesUseCase,
      updateLessonUseCase: mockUpdateLessonUseCase,
      deleteLessonUseCase: mockDeleteLessonUseCase,
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

  void stubLessonSuccess({LessonEntity? lesson}) {
    when(
      () => mockGetLessonByIdUseCase(lessonId: any(named: 'lessonId')),
    ).thenAnswer((_) async => Right(lesson ?? tLessonEntity));
  }

  void stubLessonFailure() {
    when(
      () => mockGetLessonByIdUseCase(lessonId: any(named: 'lessonId')),
    ).thenAnswer(
      (_) async => Left(
        AppErrorModel(
          code: 'firestore-error',
          message: 'lesson load failed',
          type: AppErrorType.unknown,
          isRetryable: true,
        ),
      ),
    );
  }

  void stubUpdateSuccess() {
    when(
      () => mockUpdateLessonUseCase(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right(unit));
  }

  void stubUpdateFailure() {
    when(
      () => mockUpdateLessonUseCase(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => Left(updateError));
  }

  void stubDeleteSuccess() {
    when(
      () => mockDeleteLessonUseCase(lessonId: any(named: 'lessonId')),
    ).thenAnswer((_) async => const Right(unit));
  }

  void stubDeleteFailure() {
    when(
      () => mockDeleteLessonUseCase(lessonId: any(named: 'lessonId')),
    ).thenAnswer((_) async => Left(deleteError));
  }

  Future<EditLessonCubit> initializedCubit() async {
    final cubit = buildCubit();

    await cubit.initialize();

    await Future<void>.delayed(const Duration(milliseconds: 50));

    return cubit;
  }

  test('initial state is loading-agnostic and idle', () async {
    final cubit = buildCubit();

    expect(cubit.state.pageStatus, EditLessonPageStatus.initial);
    expect(cubit.state.actionStatus, EditLessonActionStatus.idle);
    expect(cubit.state.lesson, isNull);

    await cubit.close();
  });

  blocTest<EditLessonCubit, EditLessonState>(
    'initialize emits loading then a ready state filled from the lesson',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditLessonState>().having(
        (s) => s.pageStatus,
        'pageStatus',
        EditLessonPageStatus.loading,
      ),
      isA<EditLessonState>()
          .having((s) => s.isPageReady, 'isPageReady', isTrue)
          .having((s) => s.lesson?.lessonId, 'lessonId', tLessonId)
          .having((s) => s.title, 'title', tLessonTitle)
          .having((s) => s.subtitle, 'subtitle', tLessonSubtitle)
          .having((s) => s.youtubeUrl, 'youtubeUrl', tYoutubeUrl)
          .having((s) => s.selectedGradeId, 'gradeId', tGradeId)
          .having((s) => s.isPublished, 'isPublished', isTrue)
          .having((s) => s.hasExistingPdf, 'hasExistingPdf', isTrue)
          .having((s) => s.grades.map((grade) => grade.gradeId), 'grades', [
            tGradeId,
          ]),
    ],
    verify: (_) {
      verify(() => mockGetLessonByIdUseCase(lessonId: tLessonId)).called(1);

      verify(() => mockStreamGradesUseCase(activeOnly: false)).called(1);
    },
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'initialize emits a page failure when loading the lesson fails',
    setUp: () {
      stubGradesSuccess();
      stubLessonFailure();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditLessonState>(),
      isA<EditLessonState>()
          .having((s) => s.hasPageFailure, 'hasPageFailure', isTrue)
          .having((s) => s.pageError?.message, 'pageError', 'lesson load failed'),
    ],
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'initialize emits a page failure when the grades stream fails',
    setUp: () {
      stubGradesFailure();
      stubLessonSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditLessonState>(),
      isA<EditLessonState>()
          .having((s) => s.hasPageFailure, 'hasPageFailure', isTrue)
          .having((s) => s.pageError?.message, 'pageError', 'grades stream failed'),
    ],
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'retry reloads the lesson and re-subscribes to the grades stream',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditLessonState>(),
      isA<EditLessonState>(),
      isA<EditLessonState>(),
      isA<EditLessonState>(),
    ],
    verify: (_) {
      verify(() => mockGetLessonByIdUseCase(lessonId: tLessonId)).called(2);
    },
  );

  test('form changes are ignored while the page is not ready', () async {
    final cubit = buildCubit();

    cubit.changeTitle(updatedTitle);
    cubit.selectGrade(tSecondGradeEntity.gradeId);
    cubit.changePublicationStatus(true);
    cubit.removeExistingPdf();

    expect(cubit.state.title, isEmpty);
    expect(cubit.state.selectedGradeId, isEmpty);
    expect(cubit.state.isPublished, isFalse);
    expect(cubit.state.shouldRemoveExistingPdf, isFalse);

    await cubit.close();
  });

  blocTest<EditLessonCubit, EditLessonState>(
    'form changes reset the action status and keep the loaded lesson',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.changeTitle(updatedTitle);
      cubit.changeSubtitle('وصف جديد');
      cubit.changeYoutubeUrl(tYoutubeUrl);
      cubit.selectGrade(tGradeId);
      cubit.changePublicationStatus(false);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditLessonState>(),
      isA<EditLessonState>(),
      isA<EditLessonState>().having((s) => s.title, 'title', updatedTitle),
      isA<EditLessonState>().having((s) => s.subtitle, 'subtitle', 'وصف جديد'),
      isA<EditLessonState>().having((s) => s.youtubeUrl, 'youtubeUrl', tYoutubeUrl),
      isA<EditLessonState>().having((s) => s.selectedGradeId, 'gradeId', tGradeId),
      isA<EditLessonState>()
          .having((s) => s.isPublished, 'isPublished', isFalse)
          .having((s) => s.actionStatus, 'actionStatus', EditLessonActionStatus.idle),
    ],
  );

  test('selectReplacementPdf accepts a valid PDF and rejects invalid files', () async {
    stubGradesSuccess();
    stubLessonSuccess();

    final cubit = await initializedCubit();

    cubit.selectReplacementPdf(
      const EditLessonPdfFile(
        name: tPdfFileName,
        path: tLocalPdfFilePath,
        sizeInBytes: tPdfFileSize,
      ),
    );

    expect(cubit.state.hasReplacementPdf, isTrue);
    expect(cubit.state.hasValidReplacementPdf, isTrue);
    expect(cubit.state.displayedPdfFileName, tPdfFileName);
    expect(cubit.state.shouldRemoveExistingPdf, isFalse);

    cubit.selectReplacementPdf(
      const EditLessonPdfFile(
        name: 'notes.txt',
        path: tLocalPdfFilePath,
        sizeInBytes: tPdfFileSize,
      ),
    );

    expect(cubit.state.replacementPdf?.name, tPdfFileName);

    cubit.selectReplacementPdf(
      const EditLessonPdfFile(
        name: tPdfFileName,
        path: tLocalPdfFilePath,
        sizeInBytes: 0,
      ),
    );

    expect(cubit.state.replacementPdf?.name, tPdfFileName);

    await cubit.close();
  });

  test('removeReplacementPdf and removeExistingPdf clear the PDF state', () async {
    stubGradesSuccess();
    stubLessonSuccess();

    final cubit = await initializedCubit();

    cubit.selectReplacementPdf(
      const EditLessonPdfFile(
        name: tPdfFileName,
        path: tLocalPdfFilePath,
        sizeInBytes: tPdfFileSize,
      ),
    );

    cubit.removeReplacementPdf();

    expect(cubit.state.hasReplacementPdf, isFalse);
    expect(cubit.state.shouldRemoveExistingPdf, isFalse);
    expect(cubit.state.hasCurrentPdf, isTrue);

    cubit.removeExistingPdf();

    expect(cubit.state.shouldRemoveExistingPdf, isTrue);
    expect(cubit.state.hasCurrentPdf, isFalse);
    expect(cubit.state.displayedPdfFileName, isEmpty);

    await cubit.close();
  });

  test('updateLesson is ignored when there are no changes', () async {
    stubGradesSuccess();
    stubLessonSuccess();
    stubUpdateSuccess();

    final cubit = await initializedCubit();

    expect(cubit.state.hasChanges, isFalse);
    expect(cubit.state.canUpdate, isFalse);

    await cubit.updateLesson();

    expect(cubit.state.actionStatus, EditLessonActionStatus.idle);

    verifyNever(
      () => mockUpdateLessonUseCase(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    );

    await cubit.close();
  });

  blocTest<EditLessonCubit, EditLessonState>(
    'updateLesson submits the changed fields and emits update success',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
      stubUpdateSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.changeTitle(updatedTitle);
      cubit.changePublicationStatus(false);

      await cubit.updateLesson();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditLessonState>(),
      isA<EditLessonState>(),
      isA<EditLessonState>().having((s) => s.title, 'title', updatedTitle),
      isA<EditLessonState>().having((s) => s.isPublished, 'isPublished', isFalse),
      isA<EditLessonState>()
          .having((s) => s.isUpdating, 'isUpdating', isTrue)
          .having((s) => s.actionStatus, 'actionStatus', EditLessonActionStatus.updating),
      isA<EditLessonState>()
          .having((s) => s.updateSucceeded, 'updateSucceeded', isTrue)
          .having((s) => s.lesson?.title, 'lessonTitle', updatedTitle)
          .having((s) => s.lesson?.isPublished, 'lessonIsPublished', isFalse),
    ],
    verify: (_) {
      final captured = verify(
        () => mockUpdateLessonUseCase(
          lesson: captureAny(named: 'lesson'),
          replacementPdfFilePath: null,
          removeExistingPdf: false,
        ),
      ).captured;

      final submittedLesson = captured.first as LessonEntity;

      expect(submittedLesson.lessonId, tLessonId);
      expect(submittedLesson.title, updatedTitle);
      expect(submittedLesson.pdfFileName, tPdfFileName);
      expect(submittedLesson.pdfStoragePath, tPdfStoragePath);
    },
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'updateLesson sends the replacement PDF path when a new file is selected',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
      stubUpdateSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.selectReplacementPdf(
        const EditLessonPdfFile(
          name: 'new-notes.pdf',
          path: tLocalPdfFilePath,
          sizeInBytes: tPdfFileSize,
        ),
      );

      await cubit.updateLesson();
    },
    wait: const Duration(milliseconds: 100),
    skip: 2,
    expect: () => [
      isA<EditLessonState>().having(
        (s) => s.hasReplacementPdf,
        'hasReplacementPdf',
        isTrue,
      ),
      isA<EditLessonState>().having((s) => s.isUpdating, 'isUpdating', isTrue),
      isA<EditLessonState>()
          .having((s) => s.updateSucceeded, 'updateSucceeded', isTrue)
          .having((s) => s.hasReplacementPdf, 'hasReplacementPdf', isFalse)
          .having((s) => s.lesson?.pdfFileName, 'pdfFileName', 'new-notes.pdf'),
    ],
    verify: (_) {
      final captured = verify(
        () => mockUpdateLessonUseCase(
          lesson: captureAny(named: 'lesson'),
          replacementPdfFilePath: tLocalPdfFilePath,
          removeExistingPdf: false,
        ),
      ).captured;

      final submittedLesson = captured.first as LessonEntity;

      expect(submittedLesson.pdfFileName, 'new-notes.pdf');
      expect(submittedLesson.pdfStoragePath, tPdfStoragePath);
    },
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'updateLesson flags the existing PDF for removal when it is deleted',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
      stubUpdateSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.removeExistingPdf();

      await cubit.updateLesson();
    },
    wait: const Duration(milliseconds: 100),
    skip: 2,
    expect: () => [
      isA<EditLessonState>().having(
        (s) => s.shouldRemoveExistingPdf,
        'shouldRemoveExistingPdf',
        isTrue,
      ),
      isA<EditLessonState>().having((s) => s.isUpdating, 'isUpdating', isTrue),
      isA<EditLessonState>()
          .having((s) => s.updateSucceeded, 'updateSucceeded', isTrue)
          .having((s) => s.lesson?.pdfFileName, 'pdfFileName', isNull)
          .having((s) => s.lesson?.pdfStoragePath, 'pdfStoragePath', isNull)
          .having((s) => s.shouldRemoveExistingPdf, 'shouldRemoveExistingPdf', isFalse),
    ],
    verify: (_) {
      final captured = verify(
        () => mockUpdateLessonUseCase(
          lesson: captureAny(named: 'lesson'),
          replacementPdfFilePath: null,
          removeExistingPdf: true,
        ),
      ).captured;

      final submittedLesson = captured.first as LessonEntity;

      expect(submittedLesson.pdfFileName, isNull);
      expect(submittedLesson.pdfStoragePath, isNull);
    },
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'updateLesson emits an update failure with the error',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
      stubUpdateFailure();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.changeTitle(updatedTitle);

      await cubit.updateLesson();
    },
    wait: const Duration(milliseconds: 100),
    skip: 2,
    expect: () => [
      isA<EditLessonState>(),
      isA<EditLessonState>().having((s) => s.isUpdating, 'isUpdating', isTrue),
      isA<EditLessonState>()
          .having((s) => s.updateFailed, 'updateFailed', isTrue)
          .having((s) => s.actionError?.message, 'actionError', 'update failed'),
    ],
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'deleteLesson deletes the lesson and emits delete success',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
      stubDeleteSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await cubit.deleteLesson();
    },
    wait: const Duration(milliseconds: 100),
    skip: 2,
    expect: () => [
      isA<EditLessonState>().having((s) => s.isDeleting, 'isDeleting', isTrue),
      isA<EditLessonState>().having(
        (s) => s.deleteSucceeded,
        'deleteSucceeded',
        isTrue,
      ),
    ],
    verify: (_) {
      verify(() => mockDeleteLessonUseCase(lessonId: tLessonId)).called(1);
    },
  );

  blocTest<EditLessonCubit, EditLessonState>(
    'deleteLesson emits a delete failure with the error',
    setUp: () {
      stubGradesSuccess();
      stubLessonSuccess();
      stubDeleteFailure();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await cubit.deleteLesson();
    },
    wait: const Duration(milliseconds: 100),
    skip: 2,
    expect: () => [
      isA<EditLessonState>().having((s) => s.isDeleting, 'isDeleting', isTrue),
      isA<EditLessonState>()
          .having((s) => s.deleteFailed, 'deleteFailed', isTrue)
          .having((s) => s.actionError?.message, 'actionError', 'delete failed'),
    ],
  );

  test('deleteLesson is ignored while the page is not ready', () async {
    final cubit = buildCubit();

    await cubit.deleteLesson();

    expect(cubit.state.actionStatus, EditLessonActionStatus.idle);

    verifyNever(() => mockDeleteLessonUseCase(lessonId: any(named: 'lessonId')));

    await cubit.close();
  });

  test('consumeActionResult resets a finished action to idle', () async {
    stubGradesSuccess();
    stubLessonSuccess();
    stubUpdateSuccess();

    final cubit = await initializedCubit();

    await cubit.updateLesson();

    expect(cubit.state.actionStatus, EditLessonActionStatus.idle);

    cubit.changeTitle(updatedTitle);

    await cubit.updateLesson();

    expect(cubit.state.updateSucceeded, isTrue);

    cubit.consumeActionResult();

    expect(cubit.state.actionStatus, EditLessonActionStatus.idle);
    expect(cubit.state.actionError, isNull);

    await cubit.close();
  });

  test('close cancels the grades subscription', () async {
    stubGradesSuccess();
    stubLessonSuccess();

    final cubit = await initializedCubit();

    await expectLater(cubit.close(), completes);
  });
}
