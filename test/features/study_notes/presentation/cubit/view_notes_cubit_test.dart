import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/view_notes_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/view_notes_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockStreamStudyNotesUseCase mockStreamStudyNotesUseCase;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
  });

  setUp(() {
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockStreamStudyNotesUseCase = MockStreamStudyNotesUseCase();
  });

  ViewNotesCubit buildCubit() {
    return ViewNotesCubit(
      streamGradesUseCase: mockStreamGradesUseCase,
      streamStudyNotesUseCase: mockStreamStudyNotesUseCase,
    );
  }

  void stubGradesSuccess({List<GradeEntity>? grades}) {
    final effectiveGrades = grades ?? [tGradeEntity];

    when(() => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly'))).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(Right(effectiveGrades)),
    );
  }

  void stubNotesSuccess({List<StudyNoteEntity>? notes}) {
    final effectiveNotes = notes ?? [tStudyNoteEntity];

    when(() => mockStreamStudyNotesUseCase()).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<StudyNoteEntity>>>.value(Right(effectiveNotes)),
    );
  }

  void stubGradesFailure() {
    when(() => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly'))).thenAnswer(
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

  test('initial state is ViewNotesInitial', () async {
    final cubit = buildCubit();

    expect(cubit.state, isA<ViewNotesInitial>());

    await cubit.close();
  });

  blocTest<ViewNotesCubit, ViewNotesState>(
    'initialize emits loading then data success when both streams emit',
    setUp: () {
      stubGradesSuccess();
      stubNotesSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewNotesLoading>(),
      isA<ViewNotesDataSuccess>()
          .having((s) => s.grades.map((g) => g.gradeId), 'grades', ['grade-1'])
          .having((s) => s.notes.map((n) => n.noteId), 'notes', [tStudyNoteId]),
    ],
    verify: (_) {
      verify(() => mockStreamGradesUseCase(activeOnly: true)).called(1);
      verify(() => mockStreamStudyNotesUseCase()).called(1);
    },
  );

  blocTest<ViewNotesCubit, ViewNotesState>(
    'initialize emits failure when grades stream emits an error',
    setUp: () {
      stubGradesFailure();
      stubNotesSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<ViewNotesLoading>(), isA<ViewNotesFailure>()],
  );

  blocTest<ViewNotesCubit, ViewNotesState>(
    'initialize emits failure when notes stream emits an error',
    setUp: () {
      stubGradesSuccess();
      when(() => mockStreamStudyNotesUseCase()).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<StudyNoteEntity>>>.value(
          Left(
            AppErrorModel(
              code: 'firestore-error',
              message: 'notes stream failed',
              type: AppErrorType.unknown,
              isRetryable: true,
            ),
          ),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<ViewNotesLoading>(), isA<ViewNotesFailure>()],
  );

  blocTest<ViewNotesCubit, ViewNotesState>(
    'searchNotes updates search query',
    setUp: () {
      stubGradesSuccess();
      stubNotesSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.searchNotes('ملزمة');
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewNotesLoading>(),
      isA<ViewNotesDataSuccess>(),
      isA<ViewNotesDataSuccess>().having((s) => s.searchQuery, 'searchQuery', 'ملزمة'),
    ],
  );

  test('searchNotes is ignored when state is not data success', () async {
    final cubit = buildCubit();

    cubit.searchNotes('anything');

    expect(cubit.state, isA<ViewNotesInitial>());

    await cubit.close();
  });

  test('selectGrade is ignored when state is not data success', () async {
    final cubit = buildCubit();

    cubit.selectGrade(tGradeId);

    expect(cubit.state, isA<ViewNotesInitial>());

    await cubit.close();
  });

  test('selectPublicationFilter is ignored when state is not data success', () async {
    final cubit = buildCubit();

    cubit.selectPublicationFilter(NotePublicationFilter.published);

    expect(cubit.state, isA<ViewNotesInitial>());

    await cubit.close();
  });

  test('filteredNotes filters by search query', () {
    final noteA = StudyNoteEntity(
      noteId: 'note-a',
      name: 'ملزمة الجملة الاسمية',
      description: 'وصف',
      gradeId: tGradeId,
      isPublished: true,
    );

    final noteB = StudyNoteEntity(
      noteId: 'note-b',
      name: 'مراجعة الباب الأول',
      description: 'وصف',
      gradeId: tGradeId,
      isPublished: false,
    );

    final state = ViewNotesDataSuccess(
      grades: [tGradeEntity],
      notes: [noteA, noteB],
      searchQuery: 'الجملة',
    );

    expect(state.filteredNotes.map((n) => n.noteId), ['note-a']);
    expect(state.hasNoSearchResults, isFalse);
    expect(state.hasActiveFilters, isTrue);

    final noMatchState = ViewNotesDataSuccess(
      grades: [tGradeEntity],
      notes: [noteA, noteB],
      searchQuery: 'لا يوجد',
    );

    expect(noMatchState.filteredNotes, isEmpty);
    expect(noMatchState.hasNoSearchResults, isTrue);
  });

  test('filteredNotes filters by grade', () {
    final noteA = StudyNoteEntity(
      noteId: 'note-a',
      name: 'ملزمة',
      description: 'وصف',
      gradeId: 'grade-1',
      isPublished: true,
    );

    final noteB = StudyNoteEntity(
      noteId: 'note-b',
      name: 'مذكرة',
      description: 'وصف',
      gradeId: 'grade-2',
      isPublished: true,
    );

    final state = ViewNotesDataSuccess(
      grades: [tGradeEntity],
      notes: [noteA, noteB],
      selectedGradeId: 'grade-2',
    );

    expect(state.filteredNotes.map((n) => n.noteId), ['note-b']);
  });

  test('filteredNotes filters by publication status', () {
    final noteA = StudyNoteEntity(
      noteId: 'note-a',
      name: 'ملزمة',
      description: 'وصف',
      gradeId: tGradeId,
      isPublished: true,
    );

    final noteB = StudyNoteEntity(
      noteId: 'note-b',
      name: 'مذكرة',
      description: 'وصف',
      gradeId: tGradeId,
      isPublished: false,
    );

    final publishedState = ViewNotesDataSuccess(
      grades: [tGradeEntity],
      notes: [noteA, noteB],
      selectedPublicationFilter: NotePublicationFilter.published,
    );

    final unpublishedState = ViewNotesDataSuccess(
      grades: [tGradeEntity],
      notes: [noteA, noteB],
      selectedPublicationFilter: NotePublicationFilter.unpublished,
    );

    expect(publishedState.filteredNotes.map((n) => n.noteId), ['note-a']);
    expect(unpublishedState.filteredNotes.map((n) => n.noteId), ['note-b']);
    expect(unpublishedState.hasActiveFilters, isTrue);
  });

  blocTest<ViewNotesCubit, ViewNotesState>(
    'selected grade is reset when it no longer exists in grades stream',
    setUp: () {
      stubGradesSuccess();
      stubNotesSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.selectGrade('grade-9');

      // Grades re-emit without the selected grade.
      when(() => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly'))).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(Right([tSecondGradeEntity])),
      );

      when(() => mockStreamStudyNotesUseCase()).thenAnswer(
        (_) =>
            Stream<Either<AppErrorModel, List<StudyNoteEntity>>>.value(Right([tStudyNoteEntity])),
      );

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewNotesLoading>(),
      isA<ViewNotesDataSuccess>(),
      isA<ViewNotesDataSuccess>(),
      isA<ViewNotesLoading>(),
      isA<ViewNotesDataSuccess>().having((s) => s.selectedGradeId, 'selectedGradeId', ''),
    ],
  );

  blocTest<ViewNotesCubit, ViewNotesState>(
    'retry re-initializes and re-subscribes to streams',
    setUp: () {
      stubGradesSuccess();
      stubNotesSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewNotesLoading>(),
      isA<ViewNotesDataSuccess>(),
      isA<ViewNotesLoading>(),
      isA<ViewNotesDataSuccess>(),
    ],
    verify: (_) {
      verify(() => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly'))).called(2);
      verify(() => mockStreamStudyNotesUseCase()).called(2);
    },
  );

  test('close does not throw after initialize', () async {
    stubGradesSuccess();
    stubNotesSuccess();

    final cubit = buildCubit();

    await cubit.initialize();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await expectLater(cubit.close(), completes);
  });
}
