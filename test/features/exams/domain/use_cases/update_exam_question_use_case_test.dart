import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/update_exam_question_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRepository repository;
  late UpdateExamQuestionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tExamQuestionImageFile);
    registerFallbackValue(tExamQuestionEntity);
  });

  setUp(() {
    repository = MockExamsRepository();
    useCase = UpdateExamQuestionUseCase(examsRepository: repository);
  });

  test('forwards the question, new image, and removal flag', () async {
    when(
      () => repository.updateQuestion(
        question: any(named: 'question'),
        newImage: any(named: 'newImage'),
        removeCurrentImage: any(named: 'removeCurrentImage'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase(
      question: tExamQuestionEntity,
      newImage: tExamQuestionImageFile,
      removeCurrentImage: false,
    );

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));

    verify(
      () => repository.updateQuestion(
        question: tExamQuestionEntity,
        newImage: tExamQuestionImageFile,
        removeCurrentImage: false,
      ),
    ).called(1);
  });

  test('forwards removeCurrentImage without an image', () async {
    when(
      () => repository.updateQuestion(
        question: any(named: 'question'),
        newImage: any(named: 'newImage'),
        removeCurrentImage: any(named: 'removeCurrentImage'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    await useCase(
      question: tExamQuestionEntity,
      removeCurrentImage: true,
    );

    verify(
      () => repository.updateQuestion(
        question: tExamQuestionEntity,
        newImage: null,
        removeCurrentImage: true,
      ),
    ).called(1);
  });
}
