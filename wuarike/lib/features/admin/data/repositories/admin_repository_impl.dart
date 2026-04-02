import '../datasources/admin_remote_datasource.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../places/domain/entities/place_submission_entity.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  const AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PlaceSubmissionEntity>> getPendingSubmissions() async {
    return await _remoteDataSource.getPendingSubmissions();
  }

  @override
  Future<void> approveSubmission(String id) async {
    await _remoteDataSource.approveSubmission(id);
  }

  @override
  Future<void> rejectSubmission(String id, String reason) async {
    await _remoteDataSource.rejectSubmission(id, reason);
  }
}
