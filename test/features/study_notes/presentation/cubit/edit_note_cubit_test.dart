import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/edit_note_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/edit_note_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGetStudyNoteByIdUseCase mockGetStudyNoteByIdUseCase;
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockUpdateStudyNoteUseCase mockUpdateStudyNoteUseCase;
  late MockDeleteStudyNoteUseCase mockDeleteStudyNoteUseCase;

  const tReplacementPdf = EditNotePdfFile(
    name: 'replacement.pdf',
    path: '/tmp/replacement.pdf',
    sizeInBytes: 2048,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
    registerFallbackValue(tStudyNoteEntity);
  });

  setUp(() {
    mockGetStudyNoteByIdUseCase = MockGetStudyNoteByIdUseCase();
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockUpdateStudyNoteUseCase = MockUpdateStudyNoteUseCase();
    mockDeleteStudyNoteUseCase = MockDeleteStudyNoteUseCase();
  });

  EditNoteCubit buildCubit() {
    return EditNoteCubit(
      noteId: tStudyNoteId,
      getStudyNoteByIdUseCase: mockGetStudyNoteByIdUseCase,
      streamGradesUseCase: mockStreamGradesUseCase,
      updateStudyNoteUseCase: mockUpdateStudyNoteUseCase,
      deleteStudyNoteUseCase: mockDeleteStudyNoteUseCase,
    );
  }

  void stubNoteSuccess({
    StudyNoteEntity? note,
  }) {
    final effectiveNote = note ?? tStudyNoteEntity;

    when(
      () => mockGetStudyNoteByIdUseCase(noteId: any(named: 'noteId')),
    ).thenAnswer(
      (_) async => Right<AppErrorModel, StudyNoteEntity>(effectiveNote),
    );
  }

  void stubGradesSuccess({
    List<GradeEntity>? grades,
  }) {
    final effectiveGrades = grades ?? [tGradeEntity];

    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Right(effectiveGrades),
      ),
    );
  }

  void stubEverythingReady({StudyNoteEntity? note}) {
    stubNoteSuccess(note: note);
    stubGradesSuccess();
  }
  test('initial state has default EditNoteState values', () async {
    final cubit = buildCubit();

    expect(cubit.state.pageStatus, equals(EditNotePageStatus.initial));
    expect(cubit.state.actionStatus, equals(EditNoteActionStatus.idle));
    expect(cubit.state.note, isNull);
    expect(cubit.state.canUpdate, isFalse);
    expect(cubit.state.canDelete, isFalse);

    await cubit.close();
  });

  blocTest<EditNoteCubit, EditNoteState>(
    'initialize emits loading then ready with pre-filled note fields',
    setUp: () {
      stubEverythingReady();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>()
          .having((s) => s.isPageLoading, 'isPageLoading', isTrue),
      isA<EditNoteState>()
          .having((s) => s.isPageReady, 'isPageReady', isTrue)
          .having((s) => s.title, 'title', tStudyNoteName)
          .having((s) => s.description, 'description', tStudyNoteDescription)
          .having((s) => s.selectedGradeId, 'selectedGradeId', tGradeId)
          .having((s) => s.isPublished, 'isPublished', isTrue)
          .having((s) => s.note?.noteId, 'noteId', tStudyNoteId),
    ],
    verify: (_) {
      verify(
        () => mockGetStudyNoteByIdUseCase(noteId: tStudyNoteId),
      ).called(1);

      verify(() => mockStreamGradesUseCase(activeOnly: false)).called(1);
    },
  );

  blocTest<EditNoteCubit, EditNoteState>(
    'initialize emits page failure when loading the note fails',
    setUp: () {
      when(
        () => mockGetStudyNoteByIdUseCase(noteId: any(named: 'noteId')),
      ).thenAnswer(
        (_) async => Left<AppErrorModel, StudyNoteEntity>(
          AppErrorModel(
            code: 'not-found',
            message: 'note not found',
            type: AppErrorType.notFound,
            isRetryable: false,
          ),
        ),
      );

      stubGradesSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>()
          .having((s) => s.isPageLoading, 'isPageLoading', isTrue),
      isA<EditNoteState>()
          .having((s) => s.hasPageFailure, 'hasPageFailure', isTrue)
          .having((s) => s.pageError?.message, 'pageError', 'note not found'),
    ],
  );

  blocTest<EditNoteCubit, EditNoteState>(
    'retry re-initializes the page',
    setUp: () {
      stubEverythingReady();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>(),
    ],
    verify: (_) {
      verify(
        () => mockGetStudyNoteByIdUseCase(noteId: any(named: 'noteId')),
      ).called(2);
    },
  );

  blocTest<EditNoteCubit, EditNoteState>(
    'field changes update state when page is ready',
    setUp: () {
      stubEverythingReady();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit
        ..changeTitle('  عنوان جديد  ')
        ..changeDescription('  وصف جديد  ')
        ..selectGrade(' grade-2 ')
        ..changePublicationStatus(false);
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>()
          .having((s) => s.title, 'title', '  عنوان جديد  '),
      isA<EditNoteState>()
          .having((s) => s.description, 'description', '  وصف جديد  '),
      isA<EditNoteState>()
          .having((s) => s.selectedGradeId, 'selectedGradeId', 'grade-2'),
      isA<EditNoteState>()
          .having((s) => s.isPublished, 'isPublished', isFalse),
    ],
  );

  test(
    'field changes are ignored when page is not ready',
    () async {
      final cubit = buildCubit();

      cubit
        ..changeTitle('عنوان')
        ..changeDescription('وصف')
        ..selectGrade('grade-1')
        ..changePublicationStatus(true);

      expect(cubit.state.title, isEmpty);
      expect(cubit.state.description, isEmpty);
      expect(cubit.state.selectedGradeId, isEmpty);
      expect(cubit.state.isPublished, isFalse);

      await cubit.close();
    },
  );

  test('selectReplacementPdf stores a valid file', () async {
    final cubit = buildCubit();

    cubit.selectReplacementPdf(tReplacementPdf);

    expect(cubit.state.replacementPdf, isNull);

    await cubit.close();
  });

  test('selectReplacementPdf ignores invalid files when not ready', () async {
    final cubit = buildCubit();

    cubit.selectReplacementPdf(
      const EditNotePdfFile(name: '', path: '', sizeInBytes: 0),
    );

    expect(cubit.state.replacementPdf, isNull);

    await cubit.close();
  });

  blocTest<EditNoteCubit, EditNoteState>(
    'selectReplacementPdf and removeReplacementPdf manage the replacement file',
    setUp: () {
      stubEverythingReady();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.selectReplacementPdf(tReplacementPdf);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.removeReplacementPdf();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>()
          .having((s) => s.hasReplacementPdf, 'hasReplacementPdf', isTrue)
          .having(
            (s) => s.displayedPdfFileName,
            'displayedPdfFileName',
            'replacement.pdf',
          )
          .having(
            (s) => s.displayedPdfFileSize,
            'displayedPdfFileSize',
            2048,
          ),
      isA<EditNoteState>()
          .having((s) => s.hasReplacementPdf, 'hasReplacementPdf', isFalse)
          .having(
            (s) => s.displayedPdfFileName,
            'displayedPdfFileName',
            tStudyNotePdfFileName,
          ),
    ],
  );

  test('canUpdate requires valid form, changes, and ready page', () async {
    final cubit = buildCubit();

    expect(cubit.state.canUpdate, isFalse);

    await cubit.close();
  });

  test('canDelete is false while the page is not ready', () async {
    final cubit = buildCubit();

    expect(cubit.state.canDelete, isFalse);

    await cubit.close();
  });

  blocTest<EditNoteCubit, EditNoteState>(
    'updateNote submits updated note with replacement PDF path and succeeds',
    setUp: () {
      stubEverythingReady();

      when(
        () => mockUpdateStudyNoteUseCase(
          note: any(named: 'note'),
          replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        ),
      ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit
        ..changeTitle('  عنوان معدّل  ')
        ..selectReplacementPdf(tReplacementPdf);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.updateNote();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>()
          .having(
            (s) => s.actionStatus,
            'actionStatus',
            EditNoteActionStatus.updating,
          ),
      isA<EditNoteState>()
          .having(
            (s) => s.actionStatus,
            'actionStatus',
            EditNoteActionStatus.updateSuccess,
          ),
    ],
    verify: (_) {
      final captured = verify(
        () => mockUpdateStudyNoteUseCase(
          note: captureAny(named: 'note'),
          replacementPdfFilePath: captureAny(named: 'replacementPdfFilePath'),
        ),
      ).captured;

      final updatedNote = captured[0] as StudyNoteEntity;
      final replacementPath = captured[1] as String?;

      expect(updatedNote.name, equals('عنوان معدّل'));
      expect(updatedNote.noteId, equals(tStudyNoteId));
      expect(updatedNote.pdfFileName, equals('replacement.pdf'));
      expect(updatedNote.pdfFileSize, equals(2048));
      expect(replacementPath, equals('/tmp/replacement.pdf'));
    },
  );

  blocTest<EditNoteCubit, EditNoteState>(
    'updateNote does nothing when canUpdate is false',
    setUp: () {
      stubEverythingReady();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.updateNote();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
    ],
    verify: (_) {
      verifyNever(
        () => mockUpdateStudyNoteUseCase(
          note: any(named: 'note'),
          replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        ),
      );
    },
  );

  blocTest<EditNoteCubit, EditNoteState>(
    'updateNote emits update failure when the use case fails',
    setUp: () {
      stubEverythingReady();

      when(
        () => mockUpdateStudyNoteUseCase(
          note: any(named: 'note'),
          replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        ),
      ).thenAnswer(
        (_) async => Left<AppErrorModel, Unit>(
          AppErrorModel(
            code: 'update-failed',
            message: 'update failed',
            type: AppErrorType.unknown,
            isRetryable: true,
          ),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.changeTitle('عنوان معدّل');

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.updateNote();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>()
          .having(
            (s) => s.actionStatus,
            'actionStatus',
            EditNoteActionStatus.updateFailure,
          )
          .having((s) => s.actionError?.message, 'actionError', 'update failed'),
    ],
  );

  blocTest<EditNoteCubit, EditNoteState>(
    'deleteNote deletes the note and succeeds',
    setUp: () {
      stubEverythingReady();

      when(
        () => mockDeleteStudyNoteUseCase(noteId: any(named: 'noteId')),
      ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.deleteNote();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>()
          .having(
            (s) => s.actionStatus,
            'actionStatus',
            EditNoteActionStatus.deleting,
          ),
      isA<EditNoteState>()
          .having(
            (s) => s.actionStatus,
            'actionStatus',
            EditNoteActionStatus.deleteSuccess,
          ),
    ],
    verify: (_) {
      verify(
        () => mockDeleteStudyNoteUseCase(noteId: tStudyNoteId),
      ).called(1);
    },
  );

  blocTest<EditNoteCubit, EditNoteState>(
    'deleteNote emits delete failure when the use case fails',
    setUp: () {
      stubEverythingReady();

      when(
        () => mockDeleteStudyNoteUseCase(noteId: any(named: 'noteId')),
      ).thenAnswer(
        (_) async => Left<AppErrorModel, Unit>(
          AppErrorModel(
            code: 'delete-failed',
            message: 'delete failed',
            type: AppErrorType.unknown,
            isRetryable: true,
          ),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.deleteNote();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<EditNoteState>(),
      isA<EditNoteState>(),
      isA<EditNoteState>()
          .having(
            (s) => s.actionStatus,
            'actionStatus',
            EditNoteActionStatus.deleting,
          ),
      isA<EditNoteState>()
          .having(
            (s) => s.actionStatus,
            'actionStatus',
            EditNoteActionStatus.deleteFailure,
          )
          .having((s) => s.actionError?.message, 'actionError', 'delete failed'),
    ],
  );

  test(
    'consumeActionResult resets action status when no action is in progress',
    () async {
      final cubit = buildCubit();

      cubit.consumeActionResult();

      expect(cubit.state.actionStatus, equals(EditNoteActionStatus.idle));

      await cubit.close();
    },
  );
}
