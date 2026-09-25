import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/result_student/data/repository/student_exam_results_repository_impl.dart';
import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_results_overview_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentExamResultsRemoteDataSource remoteDataSource;
  late StudentExamResultsRepositoryImpl repository;

  const AppErrorModel tAppError = AppErrorModel(
    code: 'not-found',
    message: 'Student not found',
    type: AppErrorType.notFound,
    isRetryable: false,
  );

  final FirebaseRemoteException tRemoteException = FirebaseRemoteException(
    errorModel: tAppError,
  );

  setUp(() {
    remoteDataSource = MockStudentExamResultsRemoteDataSource();
    repository = StudentExamResultsRepositoryImpl(
      studentExamResultsRemoteDataSource: remoteDataSource,
    );
  });

  group('getStudentExamResultsByStudentId', () {
    test(
      'returns Right(overview) when the datasource succeeds',
      () async {
        when(
          () => remoteDataSource.getStudentExamResultsByStudentId(
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer((_) async => tStudentExamResultsOverviewModel);

        final Either<AppErrorModel, StudentExamResultsOverviewEntity> result =
            await repository.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(result.isRight(), isTrue);

        result.fold((_) => fail('expected Right'), (overview) {
          expect(overview, isA<StudentExamResultsOverviewEntity>());
          expect(overview.studentId, tResultStudentId);
          expect(overview.studentFullName, tStudentName);
          expect(overview.studentGradeId, tGradeId);
          expect(overview.studentGradeName, tGradeName);
          expect(overview.isStudentAccountActive, isTrue);
          expect(overview.completedExamsCount, 2);
          expect(overview.totalExamsCount, 4);
          expect(overview.studentExamResults, hasLength(2));
        });

        verify(
          () => remoteDataSource.getStudentExamResultsByStudentId(
            studentId: tResultStudentId,
          ),
        ).called(1);
      },
    );

    test(
      'returns Left(errorModel) when the datasource throws FirebaseRemoteException',
      () async {
        when(
          () => remoteDataSource.getStudentExamResultsByStudentId(
            studentId: any(named: 'studentId'),
          ),
        ).thenThrow(tRemoteException);

        final Either<AppErrorModel, StudentExamResultsOverviewEntity> result =
            await repository.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (_) => null), tAppError);
      },
    );

    test(
      'returns Left(errorModel) when the datasource future fails',
      () async {
        when(
          () => remoteDataSource.getStudentExamResultsByStudentId(
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer((_) => Future.error(tRemoteException));

        final Either<AppErrorModel, StudentExamResultsOverviewEntity> result =
            await repository.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (_) => null), tAppError);
      },
    );

    test(
      'forwards the exact studentId to the datasource',
      () async {
        when(
          () => remoteDataSource.getStudentExamResultsByStudentId(
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer((_) async => tStudentExamResultsOverviewModel);

        await repository.getStudentExamResultsByStudentId(
          studentId: '  $tResultStudentId  ',
        );

        verify(
          () => remoteDataSource.getStudentExamResultsByStudentId(
            studentId: '  $tResultStudentId  ',
          ),
        ).called(1);
      },
    );
  });
}
