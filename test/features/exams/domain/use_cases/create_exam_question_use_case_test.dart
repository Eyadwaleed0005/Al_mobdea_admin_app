import 'package:al_mobdea_admin/features/exams/domain/use_case/create_exam_question_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRepository repository;
  late CreateExamQuestionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tExamQuestionEntity);
    registerFallbackValue(tExamQuestionImageFile);
  });

  setUp(() {
    repository = MockExamsRepository();
    useCase = CreateExamQuestionUseCase(examsRepository: repository);
  });

  test('calls repository.createQuestion with the given arguments', () async {
    when(
      () => repository.createQuestion(
        examId: any(named: 'examId'),
        question: any(named: 'question'),
        image: any(named: 'image'),
      ),
    ).thenAnswer((_) async => Right(tExamQuestionEntity));

    final result = await useCase(
      examId: tExamId,
      question: tExamQuestionEntity,
      image: tExamQuestionImageFile,
    );

    expect(result.isRight(), isTrue);
    expect(
      result.fold((_) => null, (q) => q),
      tExamQuestionEntity,
    );

    verify(
      () => repository.createQuestion(
        examId: tExamId,
        question: tExamQuestionEntity,
        image: tExamQuestionImageFile,
      ),
    ).called(1);
  });

  test('forwards a null image when none is provided', () async {
    when(
      () => repository.createQuestion(
        examId: any(named: 'examId'),
        question: any(named: 'question'),
        image: any(named: 'image'),
      ),
    ).thenAnswer((_) async => Right(tExamQuestionEntityWithoutImage));

    await useCase(examId: tExamId, question: tExamQuestionEntity);

    verify(
      () => repository.createQuestion(
        examId: tExamId,
        question: tExamQuestionEntity,
        image: null,
      ),
    ).called(1);
  });
}
