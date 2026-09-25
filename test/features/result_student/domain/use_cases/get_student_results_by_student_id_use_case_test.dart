import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_results_overview_entity.dart';
import 'package:al_mobdea_admin/features/result_student/domain/use_cases/get_student_results_by_student_id_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentExamResultsRepository repository;
  late GetStudentExamResultsByStudentIdUseCase useCase;

  setUp(() {
    repository = MockStudentExamResultsRepository();
    useCase = GetStudentExamResultsByStudentIdUseCase(
      studentExamResultsRepository: repository,
    );
  });

  group('call', () {
    test(
      'calls repository.getStudentExamResultsByStudentId with the given studentId and returns the result',
      () async {
        when(
          () => repository.getStudentExamResultsByStudentId(
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer(
          (_) async => Right<AppErrorModel, StudentExamResultsOverviewEntity>(
            tStudentExamResultsOverviewEntity,
          ),
        );

        final Either<AppErrorModel, StudentExamResultsOverviewEntity> result =
            await useCase.call(studentId: tResultStudentId);

        expect(result.isRight(), isTrue);

        result.fold((_) => fail('expected Right'), (overview) {
          expect(overview.studentId, tResultStudentId);
          expect(overview.studentFullName, tStudentName);
          expect(overview.highestResultPercentage, 90);
          expect(overview.averageResultPercentage, closeTo(85, 0.001));
          expect(overview.studentExamResults, hasLength(2));
        });

        verify(
          () => repository.getStudentExamResultsByStudentId(
            studentId: tResultStudentId,
          ),
        ).called(1);
      },
    );

    test(
      'returns the repository Left(errorModel) unchanged',
      () async {
        const AppErrorModel tAppError = AppErrorModel(
          code: 'not-found',
          message: 'Student not found',
          type: AppErrorType.notFound,
          isRetryable: false,
        );

        when(
          () => repository.getStudentExamResultsByStudentId(
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer(
          (_) async => Left<AppErrorModel, StudentExamResultsOverviewEntity>(tAppError),
        );

        final Either<AppErrorModel, StudentExamResultsOverviewEntity> result =
            await useCase.call(studentId: tResultStudentId);

        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (_) => null), tAppError);
      },
    );
  });
}
