import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/cache/dashboard_local_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/data/models/dashboard_students_summary_model.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/entities/dashboard_students_summary_entity.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final DashboardLocalDataSource _cacheDataSource;

  const DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
    required DashboardLocalDataSource cacheDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _cacheDataSource = cacheDataSource;

  @override
  Future<Either<AppErrorModel, DashboardStudentsSummaryEntity>>
  getStudentsSummary() async {
    try {
      final remoteModel = await _remoteDataSource
          .getStudentsSummary();

      await _cacheSummarySafely(remoteModel);

      return Right<
        AppErrorModel,
        DashboardStudentsSummaryEntity
      >(_mapToEntity(remoteModel));
    } on FirebaseRemoteException {
      final cachedModel = await _getCachedSummarySafely();

      if (cachedModel != null) {
        return Right<
          AppErrorModel,
          DashboardStudentsSummaryEntity
        >(_mapToEntity(cachedModel));
      }

      return Right<
        AppErrorModel,
        DashboardStudentsSummaryEntity
      >(
        const DashboardStudentsSummaryEntity(
          totalStudents: 0,
          expiredSubscriptions: 0,
        ),
      );
    }
  }

  DashboardStudentsSummaryEntity _mapToEntity(
    DashboardStudentsSummaryModel model,
  ) {
    return DashboardStudentsSummaryEntity(
      totalStudents: model.totalStudents,
      expiredSubscriptions: model.expiredSubscriptions,
    );
  }

  Future<void> _cacheSummarySafely(
    DashboardStudentsSummaryModel summary,
  ) async {
    try {
      await _cacheDataSource.cacheStudentsSummary(
        summary: summary,
      );
    } catch (_) {}
  }

  Future<DashboardStudentsSummaryModel?>
  _getCachedSummarySafely() async {
    try {
      return await _cacheDataSource.getCachedStudentsSummary();
    } catch (_) {
      return null;
    }
  }
}
