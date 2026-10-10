import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/exam_questions_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/exam_questions_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGetExamByIdUseCase mockGetExamByIdUseCase;
  late MockCreateExamUseCase mockCreateExamUseCase;
  late MockCreateExamQuestionUseCase mockCreateExamQuestionUseCase;
  late MockUpdateExamQuestionUseCase mockUpdateExamQuestionUseCase;
  late MockDeleteExamQuestionUseCase mockDeleteExamQuestionUseCase;

  final AppErrorModel tError = AppErrorModel(
    code: 'firestore-error',
    message: 'question operation failed',
    type: AppErrorType.unknown,
    isRetryable: true,
  );

  const String tLocalQuestionId = 'draft-question-1';

  const ExamDraftEntity tExamDraft = ExamDraftEntity(
    examName: tExamName,
    gradeId: tGradeId,
    durationMinutes: tExamDurationMinutes,
    status: ExamStatus.unpublished,
  );

  final ExamQuestionEntity tLocalQuestion = ExamQuestionEntity(
    questionId: tLocalQuestionId,
    examId: '',
    questionText: 'ما نوع الخبر؟',
    degree: 2,
    choices: const ['خبر مفرد', 'خبر جملة', 'خبر شبه جملة', 'خبر فعلي'],
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(tExamDraft);
    registerFallbackValue(tExamQuestionEntity);
    registerFallbackValue(tExamQuestionImageFile);
  });

  setUp(() {
    mockGetExamByIdUseCase = MockGetExamByIdUseCase();
    mockCreateExamUseCase = MockCreateExamUseCase();
    mockCreateExamQuestionUseCase = MockCreateExamQuestionUseCase();
    mockUpdateExamQuestionUseCase = MockUpdateExamQuestionUseCase();
    mockDeleteExamQuestionUseCase = MockDeleteExamQuestionUseCase();
  });

  ExamQuestionsCubit buildCubit({String? examId, ExamDraftEntity? examDraft}) {
    return ExamQuestionsCubit(
      examId: examId,
      examDraft: examDraft,
      getExamByIdUseCase: mockGetExamByIdUseCase,
      createExamUseCase: mockCreateExamUseCase,
      createExamQuestionUseCase: mockCreateExamQuestionUseCase,
      updateExamQuestionUseCase: mockUpdateExamQuestionUseCase,
      deleteExamQuestionUseCase: mockDeleteExamQuestionUseCase,
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

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'initialize emits empty while creating a new exam',
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) => cubit.initialize(),
    expect: () => [isA<ExamQuestionsEmpty>()],
    verify: (_) {
      verifyNever(
        () => mockGetExamByIdUseCase(examId: any(named: 'examId')),
      );
    },
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'initialize loads the saved exam and its questions',
    setUp: stubExamSuccess,
    build: () => buildCubit(examId: tExamId),
    act: (cubit) => cubit.initialize(),
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>()
          .having((state) => state.questions.length, 'questions count', 1)
          .having((state) => state.isCreatingExam, 'is creating exam', isFalse)
          .having((state) => state.canEdit, 'can edit', isTrue)
          .having(
            (state) => state.selectedChoiceIndexes[tExamQuestionId],
            'selected choice',
            tExamCorrectChoiceIndex,
          )
          .having((state) => state.totalDegrees, 'total degrees', 5),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'initialize emits error when the exam cannot be loaded',
    setUp: stubExamFailure,
    build: () => buildCubit(examId: tExamId),
    act: (cubit) => cubit.initialize(),
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsError>().having(
        (state) => state.error.message,
        'error message',
        tError.message,
      ),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'addQuestion appends a local question and updates the totals',
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);
    },
    expect: () => [
      isA<ExamQuestionsEmpty>(),
      isA<ExamQuestionsSuccess>()
          .having((state) => state.questions.length, 'questions count', 1)
          .having((state) => state.totalDegrees, 'total degrees', 2)
          .having(
            (state) => state.canSaveExam,
            'can save exam',
            isFalse,
          ),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'addQuestion ignores a question that is already added',
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);

      cubit.addQuestion(question: tLocalQuestion);
    },
    expect: () => [
      isA<ExamQuestionsEmpty>(),
      isA<ExamQuestionsSuccess>(),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'selectCorrectChoice enables saving the exam once every question has an answer',
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);

      cubit.selectCorrectChoice(
        questionId: tLocalQuestionId,
        choiceIndex: 2,
      );
    },
    expect: () => [
      isA<ExamQuestionsEmpty>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>()
          .having(
            (state) => state.selectedChoiceIndexes[tLocalQuestionId],
            'selected choice',
            2,
          )
          .having((state) => state.canSaveExam, 'can save exam', isTrue),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'selectCorrectChoice ignores an out of range choice',
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);

      cubit.selectCorrectChoice(questionId: tLocalQuestionId, choiceIndex: 9);
    },
    expect: () => [isA<ExamQuestionsEmpty>(), isA<ExamQuestionsSuccess>()],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'saveExam creates the exam with its questions and images',
    setUp: () {
      when(
        () => mockCreateExamUseCase(
          examDraft: any(named: 'examDraft'),
          questions: any(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      ).thenAnswer((_) async => const Right(tExamId));
    },
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion, image: tExamQuestionImageFile);

      cubit.selectCorrectChoice(questionId: tLocalQuestionId, choiceIndex: 0);

      await cubit.saveExam();
    },
    expect: () => [
      isA<ExamQuestionsEmpty>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operation,
        'operation',
        ExamQuestionsOperation.createExam,
      ),
      isA<ExamQuestionsSuccess>()
          .having((state) => state.operationSucceeded, 'succeeded', isTrue)
          .having((state) => state.savedExamId, 'saved exam id', tExamId),
    ],
    verify: (_) {
      verify(
        () => mockCreateExamUseCase(
          examDraft: tExamDraft,
          questions: any(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      ).called(1);
    },
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'saveExam emits the operation error when creating the exam fails',
    setUp: () {
      when(
        () => mockCreateExamUseCase(
          examDraft: any(named: 'examDraft'),
          questions: any(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      ).thenAnswer((_) async => Left(tError));
    },
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);

      cubit.selectCorrectChoice(questionId: tLocalQuestionId, choiceIndex: 1);

      await cubit.saveExam();
    },
    expect: () => [
      isA<ExamQuestionsEmpty>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operation,
        'operation',
        ExamQuestionsOperation.createExam,
      ),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operationError?.message,
        'operation error',
        tError.message,
      ),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'saveExam is ignored until every question has a correct choice',
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);

      await cubit.saveExam();
    },
    expect: () => [isA<ExamQuestionsEmpty>(), isA<ExamQuestionsSuccess>()],
    verify: (_) {
      verifyNever(
        () => mockCreateExamUseCase(
          examDraft: any(named: 'examDraft'),
          questions: any(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      );
    },
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'selectCorrectChoice marks a saved question as dirty',
    setUp: stubExamSuccess,
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      cubit.selectCorrectChoice(questionId: tExamQuestionId, choiceIndex: 0);
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>()
          .having(
            (state) => state.hasUnsavedChanges,
            'has unsaved changes',
            isTrue,
          )
          .having((state) => state.canSaveChanges, 'can save changes', isTrue),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'selectCorrectChoice clears the dirty flag when the original choice is restored',
    setUp: stubExamSuccess,
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      cubit.selectCorrectChoice(questionId: tExamQuestionId, choiceIndex: 0);

      cubit.selectCorrectChoice(
        questionId: tExamQuestionId,
        choiceIndex: tExamCorrectChoiceIndex,
      );
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.hasUnsavedChanges,
        'has unsaved changes',
        isFalse,
      ),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'updateQuestion saves a stored question through the use case',
    setUp: () {
      stubExamSuccess();

      when(
        () => mockUpdateExamQuestionUseCase(
          question: any(named: 'question'),
          newImage: any(named: 'newImage'),
          removeCurrentImage: any(named: 'removeCurrentImage'),
        ),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      await cubit.updateQuestion(
        question: tExamQuestionEntity.copyWith(questionText: 'نص محدث'),
      );
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operation,
        'operation',
        ExamQuestionsOperation.updateQuestion,
      ),
      isA<ExamQuestionsSuccess>()
          .having((state) => state.operationSucceeded, 'succeeded', isTrue)
          .having(
            (state) => state.questions.first.questionText,
            'question text',
            'نص محدث',
          ),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'updateQuestion emits the operation error when the update fails',
    setUp: () {
      stubExamSuccess();

      when(
        () => mockUpdateExamQuestionUseCase(
          question: any(named: 'question'),
          newImage: any(named: 'newImage'),
          removeCurrentImage: any(named: 'removeCurrentImage'),
        ),
      ).thenAnswer((_) async => Left(tError));
    },
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      await cubit.updateQuestion(question: tExamQuestionEntity);
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operation,
        'operation',
        ExamQuestionsOperation.updateQuestion,
      ),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operationError?.message,
        'operation error',
        tError.message,
      ),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'deleteQuestion deletes a local question without calling the use case',
    build: () => buildCubit(examDraft: tExamDraft),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);

      await cubit.deleteQuestion(questionId: tLocalQuestionId);
    },
    expect: () => [
      isA<ExamQuestionsEmpty>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsEmpty>(),
    ],
    verify: (_) {
      verifyNever(
        () => mockDeleteExamQuestionUseCase(
          examId: any(named: 'examId'),
          questionId: any(named: 'questionId'),
        ),
      );
    },
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'deleteQuestion deletes a stored question through the use case',
    setUp: () {
      stubExamSuccess();

      when(
        () => mockDeleteExamQuestionUseCase(
          examId: any(named: 'examId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      await cubit.deleteQuestion(questionId: tExamQuestionId);
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operation,
        'operation',
        ExamQuestionsOperation.deleteQuestion,
      ),
      isA<ExamQuestionsSuccess>()
          .having((state) => state.operationSucceeded, 'succeeded', isTrue)
          .having(
            (state) => state.questions,
            'questions',
            isEmpty,
          ),
    ],
    verify: (_) {
      verify(
        () => mockDeleteExamQuestionUseCase(
          examId: tExamId,
          questionId: tExamQuestionId,
        ),
      ).called(1);
    },
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'deleteQuestion emits the operation error when deleting fails',
    setUp: () {
      stubExamSuccess();

      when(
        () => mockDeleteExamQuestionUseCase(
          examId: any(named: 'examId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => Left(tError));
    },
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      await cubit.deleteQuestion(questionId: tExamQuestionId);
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operation,
        'operation',
        ExamQuestionsOperation.deleteQuestion,
      ),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operationError?.message,
        'operation error',
        tError.message,
      ),
    ],
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'saveChanges creates new questions then saves the dirty answers',
    setUp: () {
      stubExamSuccess();

      when(
        () => mockCreateExamQuestionUseCase(
          examId: any(named: 'examId'),
          question: any(named: 'question'),
          image: any(named: 'image'),
        ),
      ).thenAnswer(
        (_) async => Right(
          tExamQuestionEntity.copyWith(
            questionId: tSecondExamQuestionId,
            imageUrl: null,
            imageStoragePath: null,
          ),
        ),
      );

      when(
        () => mockUpdateExamQuestionUseCase(
          question: any(named: 'question'),
          newImage: any(named: 'newImage'),
          removeCurrentImage: any(named: 'removeCurrentImage'),
        ),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      cubit.addQuestion(question: tLocalQuestion);

      cubit.selectCorrectChoice(questionId: tLocalQuestionId, choiceIndex: 1);

      cubit.selectCorrectChoice(questionId: tExamQuestionId, choiceIndex: 0);

      await cubit.saveChanges();
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>(),
      isA<ExamQuestionsSuccess>().having(
        (state) => state.operation,
        'operation',
        ExamQuestionsOperation.saveQuestionChanges,
      ),
      isA<ExamQuestionsSuccess>()
          .having((state) => state.operationSucceeded, 'succeeded', isTrue)
          .having(
            (state) => state.hasUnsavedChanges,
            'has unsaved changes',
            isFalse,
          ),
    ],
    verify: (_) {
      verify(
        () => mockCreateExamQuestionUseCase(
          examId: tExamId,
          question: any(named: 'question'),
          image: any(named: 'image'),
        ),
      ).called(1);

      verify(
        () => mockUpdateExamQuestionUseCase(
          question: any(named: 'question'),
          newImage: any(named: 'newImage'),
          removeCurrentImage: any(named: 'removeCurrentImage'),
        ),
      ).called(1);
    },
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'saveQuestionChanges is ignored when there is nothing to save',
    setUp: stubExamSuccess,
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      await cubit.saveQuestionChanges();
    },
    expect: () => [isA<ExamQuestionsLoading>(), isA<ExamQuestionsSuccess>()],
    verify: (_) {
      verifyNever(
        () => mockCreateExamQuestionUseCase(
          examId: any(named: 'examId'),
          question: any(named: 'question'),
          image: any(named: 'image'),
        ),
      );
    },
  );

  blocTest<ExamQuestionsCubit, ExamQuestionsState>(
    'retry reloads the saved exam after a failure',
    setUp: stubExamFailure,
    build: () => buildCubit(examId: tExamId),
    act: (cubit) async {
      await cubit.initialize();

      stubExamSuccess();

      await cubit.retry();
    },
    expect: () => [
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsError>(),
      isA<ExamQuestionsLoading>(),
      isA<ExamQuestionsSuccess>(),
    ],
  );

  test('currentExamDraft is null for an ended exam', () async {
    stubExamSuccess(exam: tEndedExamEntity);

    final cubit = buildCubit(examId: tExamId);

    await cubit.initialize();

    expect(cubit.currentExamDraft, isNull);

    await cubit.close();
  });

  test('close cancels pending work', () async {
    stubExamSuccess();

    final cubit = buildCubit(examId: tExamId);

    await cubit.initialize();

    await cubit.close();

    expect(cubit.isClosed, isTrue);
  });
}
