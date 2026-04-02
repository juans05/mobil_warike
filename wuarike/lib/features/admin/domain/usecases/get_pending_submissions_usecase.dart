import '../../../places/domain/entities/place_submission_entity.dart';
import '../repositories/admin_repository.dart';

class GetPendingSubmissionsUseCase {
  final AdminRepository _repository;

  const GetPendingSubmissionsUseCase(this._repository);

  Future<List<PlaceSubmissionEntity>> call() => _repository.getPendingSubmissions();
}
