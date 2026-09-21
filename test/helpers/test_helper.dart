import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/cache/dashboard_local_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/use_cases/get_dashboard_students_summary_use_case.dart';
import 'package:al_mobdea_admin/features/students/data/data_sources/auth/student_auth_remote_data_source.dart';
import 'package:al_mobdea_admin/features/students/data/data_sources/firestore/students_remote_data_source.dart';
import 'package:al_mobdea_admin/features/students/domain/repositories/student_auth_repository.dart';
import 'package:al_mobdea_admin/features/students/domain/repositories/students_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mocktail/mocktail.dart';

// Core mocks
class MockFirestoreService extends Mock implements FirestoreService {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// Students feature mocks
class MockStudentsRemoteDataSource extends Mock
    implements StudentsRemoteDataSource {}

class MockStudentAuthRemoteDataSource extends Mock
    implements StudentAuthRemoteDataSource {}

class MockStudentsRepository extends Mock implements StudentsRepository {}

class MockStudentAuthRepository extends Mock
    implements StudentAuthRepository {}

// Dashboard feature mocks
class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

class MockDashboardLocalDataSource extends Mock
    implements DashboardLocalDataSource {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockGetDashboardStudentsSummaryUseCase extends Mock
    implements GetDashboardStudentsSummaryUseCase {}
