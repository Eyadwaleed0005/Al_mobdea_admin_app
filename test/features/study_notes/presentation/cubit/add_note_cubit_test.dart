import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/add_note_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/add_note_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockCreateStudyNoteUseCase mockCreateStudyNoteUseCase;

  const tPdfFile = AddNotePdfFile(
    name: 'physics-summary.pdf',
    path: '/tmp/physics-summary.pdf',
    sizeInBytes: 4096,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
    registerFallbackValue(tStudyNoteEntity);
  });

  setUp(() {
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockCreateStudyNoteUseCase = MockCreateStudyNoteUseCase();
  });

  AddNoteCubit buildCubit() {
    return AddNoteCubit(
      streamGradesUseCase: mockStreamGradesUseCase,
      createStudyNoteUseCase: mockCreateStudyNoteUseCase,
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

  void stubCreateNoteSuccess() {
    when(
      () => mockCreateStudyNoteUseCase(
        note: any(named: 'note'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));
  }

  test('initial state has default AddNoteState values', () async {
    final cubit = buildCubit();

    expect(cubit.state.pageStatus, equals(AddNotePageStatus.initial));
    expect(cubit.state.submissionStatus, equals(AddNoteSubmissionStatus.idle));
    expect(cubit.state.grades, isEmpty);
    expect(cubit.state.canSubmit, isFalse);

    await cubit.close();
  });

  blocTest<AddNoteCubit, AddNoteState>(
    'watchGrades emits loading then ready with grades',
    setUp: () {
      stubGradesSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.watchGrades(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddNoteState>()
          .having((s) => s.isPageLoading, 'isPageLoading', isTrue),
      isA<AddNoteState>()
          .having((s) => s.isPageReady, 'isPageReady', isTrue)
          .having((s) => s.grades.length, 'grades', 1),
    ],
  );

  blocTest<AddNoteCubit, AddNoteState>(
    'watchGrades emits page failure when grades stream emits an error',
    setUp: () {
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
    },
    build: buildCubit,
    act: (cubit) => cubit.watchGrades(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddNoteState>()
          .having((s) => s.isPageLoading, 'isPageLoading', isTrue),
      isA<AddNoteState>()
          .having((s) => s.hasPageFailure, 'hasPageFailure', isTrue),
    ],
  );

  blocTest<AddNoteCubit, AddNoteState>(
    'retry re-watches grades',
    setUp: () {
      stubGradesSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.watchGrades();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
    ],
    verify: (_) {
      verify(
        () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
      ).called(2);
    },
  );

  test('form field changes update state and validation flags', () async {
    final cubit = buildCubit();

    cubit
      ..changeTitle('  ملزمة الجملة الاسمية  ')
      ..changeDescription('شرح مبسط')
      ..selectGrade(' grade-1 ')
      ..changePublicationStatus(true)
      ..selectPdf(tPdfFile);

    expect(cubit.state.title, equals('  ملزمة الجملة الاسمية  '));
    expect(cubit.state.description, equals('شرح مبسط'));
    expect(cubit.state.selectedGradeId, equals('grade-1'));
    expect(cubit.state.isPublished, isTrue);
    expect(cubit.state.selectedPdf, equals(tPdfFile));
    expect(cubit.state.hasTitle, isTrue);
    expect(cubit.state.hasDescription, isTrue);
    expect(cubit.state.hasSelectedGrade, isTrue);
    expect(cubit.state.hasSelectedPdf, isTrue);

    await cubit.close();
  });

  test('canSubmit is false until all requirements are met', () async {
    final cubit = buildCubit();

    cubit
      ..changeTitle('عنوان')
      ..changeDescription('وصف')
      ..selectGrade('grade-1');

    expect(cubit.state.canSubmit, isFalse);

    cubit.selectPdf(tPdfFile);

    // Page is not ready yet, so submission is still not possible.
    expect(cubit.state.canSubmit, isFalse);

    await cubit.close();
  });

  test('removePdf clears the selected PDF', () async {
    final cubit = buildCubit();

    cubit
      ..selectPdf(tPdfFile)
      ..removePdf();

    expect(cubit.state.selectedPdf, isNull);
    expect(cubit.state.hasSelectedPdf, isFalse);

    await cubit.close();
  });

  blocTest<AddNoteCubit, AddNoteState>(
    'changeTitle is ignored while submitting',
    setUp: () {
      stubGradesSuccess();
      stubCreateNoteSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.watchGrades();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit
        ..changeTitle('عنوان')
        ..changeDescription('وصف')
        ..selectGrade('grade-1')
        ..selectPdf(tPdfFile);

      final submission = cubit.createNote();

      cubit.changeTitle('عنوان آخر');

      await submission;
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>()
          .having(
            (s) => s.submissionStatus,
            'submissionStatus',
            AddNoteSubmissionStatus.loading,
          ),
      isA<AddNoteState>()
          .having(
            (s) => s.submissionStatus,
            'submissionStatus',
            AddNoteSubmissionStatus.success,
          )
          .having((s) => s.title, 'title', 'عنوان'),
    ],
  );

  test('createNote does nothing when canSubmit is false', () async {
    stubGradesSuccess();

    final cubit = buildCubit();

    await cubit.createNote();

    verifyNever(
      () => mockCreateStudyNoteUseCase(
        note: any(named: 'note'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    );

    await cubit.close();
  });

  blocTest<AddNoteCubit, AddNoteState>(
    'createNote submits the note with trimmed values and succeeds',
    setUp: () {
      stubGradesSuccess();
      stubCreateNoteSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.watchGrades();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit
        ..changeTitle('  ملزمة الجملة الاسمية  ')
        ..changeDescription('  شرح مبسط  ')
        ..selectGrade(' grade-1 ')
        ..changePublicationStatus(true)
        ..selectPdf(tPdfFile);

      await cubit.createNote();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>()
          .having(
            (s) => s.submissionStatus,
            'submissionStatus',
            AddNoteSubmissionStatus.loading,
          ),
      isA<AddNoteState>()
          .having(
            (s) => s.submissionStatus,
            'submissionStatus',
            AddNoteSubmissionStatus.success,
          ),
    ],
    verify: (_) {
      final captured = verify(
        () => mockCreateStudyNoteUseCase(
          note: captureAny(named: 'note'),
          localPdfFilePath: captureAny(named: 'localPdfFilePath'),
        ),
      ).captured;

      final submittedNote = captured[0] as StudyNoteEntity;
      final submittedPath = captured[1] as String;

      expect(submittedNote.name, equals('ملزمة الجملة الاسمية'));
      expect(submittedNote.description, equals('شرح مبسط'));
      expect(submittedNote.gradeId, equals('grade-1'));
      expect(submittedNote.isPublished, isTrue);
      expect(submittedNote.pdfFileName, equals('physics-summary.pdf'));
      expect(submittedNote.pdfFileSize, equals(4096));
      expect(submittedNote.noteId, startsWith('note_'));
      expect(submittedPath, equals('/tmp/physics-summary.pdf'));
    },
  );

  blocTest<AddNoteCubit, AddNoteState>(
    'createNote emits submission failure when the use case fails',
    setUp: () {
      stubGradesSuccess();

      when(
        () => mockCreateStudyNoteUseCase(
          note: any(named: 'note'),
          localPdfFilePath: any(named: 'localPdfFilePath'),
        ),
      ).thenAnswer(
        (_) async => Left(
          AppErrorModel(
            code: 'upload-failed',
            message: 'upload failed',
            type: AppErrorType.unknown,
            isRetryable: true,
          ),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.watchGrades();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit
        ..changeTitle('عنوان')
        ..changeDescription('وصف')
        ..selectGrade('grade-1')
        ..selectPdf(tPdfFile);

      await cubit.createNote();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>(),
      isA<AddNoteState>()
          .having(
            (s) => s.submissionStatus,
            'submissionStatus',
            AddNoteSubmissionStatus.loading,
          ),
      isA<AddNoteState>()
          .having(
            (s) => s.submissionStatus,
            'submissionStatus',
            AddNoteSubmissionStatus.failure,
          )
          .having((s) => s.error?.message, 'error', 'upload failed'),
    ],
  );

  test('consumeSubmissionResult resets submission status to idle', () async {
    final cubit = buildCubit();

    cubit.consumeSubmissionResult();

    expect(
      cubit.state.submissionStatus,
      equals(AddNoteSubmissionStatus.idle),
    );

    await cubit.close();
  });
}
