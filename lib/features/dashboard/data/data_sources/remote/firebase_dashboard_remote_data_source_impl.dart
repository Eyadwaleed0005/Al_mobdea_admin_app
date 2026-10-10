import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/errors/handlers/firebase_error_handler.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/data/models/dashboard_students_summary_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDashboardRemoteDataSourceImpl
    implements DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebaseDashboardRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<DashboardStudentsSummaryModel> getStudentsSummary() {
    return _execute(() async {
      final studentsCollection = _firestore.collection(
        FirestoreCollections.students,
      );

      final results = await Future.wait([
        studentsCollection.count().get(),
        studentsCollection
            .where(FirestoreFields.isActive, isEqualTo: false)
            .count()
            .get(),
      ]);

      final totalStudents = results[0].count ?? 0;
      final inactiveStudents = results[1].count ?? 0;

      return DashboardStudentsSummaryModel(
        totalStudents: totalStudents,
        expiredSubscriptions: inactiveStudents,
      );
    });
  }

  Future<T> _execute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      if (error is FirebaseRemoteException) {
        Error.throwWithStackTrace(error, stackTrace);
      }

      final remoteException = FirebaseRemoteException(
        errorModel: FirebaseErrorHandler.handle(error),
      );

      Error.throwWithStackTrace(remoteException, stackTrace);
    }
  }
}
