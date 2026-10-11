import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/view_lessons_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/view_lessons_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockStreamLessonsUseCase mockStreamLessonsUseCase;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
  });

  setUp(() {
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockStreamLessonsUseCase = MockStreamLessonsUseCase();
  });

  ViewLessonsCubit buildCubit() {
    return ViewLessonsCubit(
      streamGradesUseCase: mockStreamGradesUseCase,
      streamLessonsUseCase: mockStreamLessonsUseCase,
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

  void stubLessonsSuccess({List<LessonEntity>? lessons}) {
    final effectiveLessons = lessons ?? [tLessonEntity];

    when(() => mockStreamLessonsUseCase()).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<LessonEntity>>>.value(
        Right(effectiveLessons),
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

  test('initial state is ViewLessonsInitial', () async {
    final cubit = buildCubit();

    expect(cubit.state, isA<ViewLessonsInitial>());

    await cubit.close();
  });

  blocTest<ViewLessonsCubit, ViewLessonsState>(
    'initialize emits loading then data success when both streams emit',
    setUp: () {
      stubGradesSuccess();
      stubLessonsSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewLessonsLoading>(),
      isA<ViewLessonsDataSuccess>()
          .having((s) => s.grades.map((grade) => grade.gradeId), 'grades', [
            tGradeId,
          ])
          .having((s) => s.lessons.map((lesson) => lesson.lessonId), 'lessons', [
            tLessonId,
          ]),
    ],
    verify: (_) {
      verify(() => mockStreamGradesUseCase(activeOnly: true)).called(1);
      verify(() => mockStreamLessonsUseCase()).called(1);
    },
  );

  blocTest<ViewLessonsCubit, ViewLessonsState>(
    'initialize emits failure when grades stream emits an error',
    setUp: () {
      stubGradesFailure();
      stubLessonsSuccess();
    },
    build: buildCubit,
    act: (cubit) => cubit.initialize(),
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<ViewLessonsLoading>(), isA<ViewLessonsFailure>()],
  );

  blocTest<ViewLessonsCubit, ViewLessonsState>(
    'initialize emits failure when lessons stream emits an error',
    setUp: () {
      stubGradesSuccess();

      when(() => mockStreamLessonsUseCase()).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<LessonEntity>>>.value(
          Left(
            AppErrorModel(
              code: 'firestore-error',
              message: 'lessons stream failed',
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
    expect: () => [isA<ViewLessonsLoading>(), isA<ViewLessonsFailure>()],
  );

  blocTest<ViewLessonsCubit, ViewLessonsState>(
    'searchLessons updates the search query',
    setUp: () {
      stubGradesSuccess();
      stubLessonsSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.searchLessons('الجملة');
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewLessonsLoading>(),
      isA<ViewLessonsDataSuccess>(),
      isA<ViewLessonsDataSuccess>().having(
        (s) => s.searchQuery,
        'searchQuery',
        'الجملة',
      ),
    ],
  );

  test('searchLessons is ignored when state is not data success', () async {
    final cubit = buildCubit();

    cubit.searchLessons('anything');

    expect(cubit.state, isA<ViewLessonsInitial>());

    await cubit.close();
  });

  test('selectGrade is ignored when state is not data success', () async {
    final cubit = buildCubit();

    cubit.selectGrade(tGradeId);

    expect(cubit.state, isA<ViewLessonsInitial>());

    await cubit.close();
  });

  test('selectPublicationFilter is ignored when state is not data success', () async {
    final cubit = buildCubit();

    cubit.selectPublicationFilter(LessonPublicationFilter.published);

    expect(cubit.state, isA<ViewLessonsInitial>());

    await cubit.close();
  });

  test('clearFilters is ignored when state is not data success', () async {
    final cubit = buildCubit();

    cubit.clearFilters();

    expect(cubit.state, isA<ViewLessonsInitial>());

    await cubit.close();
  });

  test('filteredLessons filters by search query', () {
    final lessonA = LessonEntity(
      lessonId: 'lesson-a',
      gradeId: tGradeId,
      title: 'الجملة الاسمية',
      subtitle: 'المبتدأ والخبر',
      isPublished: true,
    );

    final lessonB = LessonEntity(
      lessonId: 'lesson-b',
      gradeId: tGradeId,
      title: 'النحو والصرف',
      subtitle: 'مراجعة القواعد',
      isPublished: true,
    );

    final state = ViewLessonsDataSuccess(
      grades: [tGradeEntity],
      lessons: [lessonA, lessonB],
      searchQuery: 'الجملة',
    );

    expect(state.filteredLessons.map((lesson) => lesson.lessonId), ['lesson-a']);
    expect(state.hasNoSearchResults, isFalse);
    expect(state.hasActiveFilters, isTrue);

    final subtitleMatchState = ViewLessonsDataSuccess(
      grades: [tGradeEntity],
      lessons: [lessonA, lessonB],
      searchQuery: 'القواعد',
    );

    expect(subtitleMatchState.filteredLessons.map((l) => l.lessonId), [
      'lesson-b',
    ]);

    final noMatchState = ViewLessonsDataSuccess(
      grades: [tGradeEntity],
      lessons: [lessonA, lessonB],
      searchQuery: 'لا يوجد',
    );

    expect(noMatchState.filteredLessons, isEmpty);
    expect(noMatchState.hasNoSearchResults, isTrue);
  });

  test('filteredLessons filters by grade', () {
    final lessonA = LessonEntity(
      lessonId: 'lesson-a',
      gradeId: 'grade-1',
      title: 'درس',
      subtitle: 'وصف',
      isPublished: true,
    );

    final lessonB = LessonEntity(
      lessonId: 'lesson-b',
      gradeId: 'grade-2',
      title: 'درس آخر',
      subtitle: 'وصف',
      isPublished: true,
    );

    final state = ViewLessonsDataSuccess(
      grades: [tGradeEntity],
      lessons: [lessonA, lessonB],
      selectedGradeId: 'grade-2',
    );

    expect(state.filteredLessons.map((lesson) => lesson.lessonId), ['lesson-b']);
  });

  test('filteredLessons filters by publication status', () {
    final publishedLesson = LessonEntity(
      lessonId: 'lesson-a',
      gradeId: tGradeId,
      title: 'درس',
      subtitle: 'وصف',
      isPublished: true,
    );

    final unpublishedLesson = LessonEntity(
      lessonId: 'lesson-b',
      gradeId: tGradeId,
      title: 'درس آخر',
      subtitle: 'وصف',
      isPublished: false,
    );

    final publishedState = ViewLessonsDataSuccess(
      grades: [tGradeEntity],
      lessons: [publishedLesson, unpublishedLesson],
      selectedPublicationFilter: LessonPublicationFilter.published,
    );

    final unpublishedState = ViewLessonsDataSuccess(
      grades: [tGradeEntity],
      lessons: [publishedLesson, unpublishedLesson],
      selectedPublicationFilter: LessonPublicationFilter.unpublished,
    );

    expect(publishedState.filteredLessons.map((l) => l.lessonId), ['lesson-a']);
    expect(unpublishedState.filteredLessons.map((l) => l.lessonId), [
      'lesson-b',
    ]);
    expect(unpublishedState.hasActiveFilters, isTrue);
  });

  test('findGradeById returns the matching grade and null otherwise', () {
    final stateWithGrades = ViewLessonsDataSuccess(
      grades: [tGradeEntity],
      lessons: const [],
    );

    expect(stateWithGrades.findGradeById(tGradeId)?.gradeId, tGradeId);
    expect(stateWithGrades.findGradeById('missing-grade'), isNull);
  });

  blocTest<ViewLessonsCubit, ViewLessonsState>(
    'selected grade is reset when it no longer exists in the grades stream',
    setUp: () {
      stubGradesSuccess();
      stubLessonsSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      cubit.selectGrade('grade-9');

      when(
        () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
          Right([tSecondGradeEntity]),
        ),
      );

      when(() => mockStreamLessonsUseCase()).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<LessonEntity>>>.value(
          Right([tLessonEntity]),
        ),
      );

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewLessonsLoading>(),
      isA<ViewLessonsDataSuccess>(),
      isA<ViewLessonsDataSuccess>(),
      isA<ViewLessonsLoading>(),
      isA<ViewLessonsDataSuccess>().having(
        (s) => s.selectedGradeId,
        'selectedGradeId',
        '',
      ),
    ],
  );

  blocTest<ViewLessonsCubit, ViewLessonsState>(
    'retry re-initializes and re-subscribes to the streams',
    setUp: () {
      stubGradesSuccess();
      stubLessonsSuccess();
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await cubit.retry();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<ViewLessonsLoading>(),
      isA<ViewLessonsDataSuccess>(),
      isA<ViewLessonsLoading>(),
      isA<ViewLessonsDataSuccess>(),
    ],
    verify: (_) {
      verify(
        () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
      ).called(2);

      verify(() => mockStreamLessonsUseCase()).called(2);
    },
  );

  test('close does not throw after initialize', () async {
    stubGradesSuccess();
    stubLessonsSuccess();

    final cubit = buildCubit();

    await cubit.initialize();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await expectLater(cubit.close(), completes);
  });
}
