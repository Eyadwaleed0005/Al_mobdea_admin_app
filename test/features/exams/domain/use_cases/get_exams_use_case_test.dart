import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/get_exams_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRepository repository;
  late GetExamsUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = GetExamsUseCase(examsRepository: repository);
  });

  test('calls repository.getExams without filters', () async {
    when(
      () => repository.getExams(
        gradeId: any(named: 'gradeId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right([tExamEntity]));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    expect(
      result.fold((_) => null, (exams) => exams.single.examId),
      tExamId,
    );
    verify(
      () => repository.getExams(gradeId: null, status: null),
    ).called(1);
  });

  test('forwards the grade and status filters', () async {
    when(
      () => repository.getExams(
        gradeId: any(named: 'gradeId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right([tExamEntity]));

    await useCase(gradeId: tGradeId, status: ExamStatus.published);

    verify(
      () => repository.getExams(
        gradeId: tGradeId,
        status: ExamStatus.published,
      ),
    ).called(1);
  });
}
