import '../entities/place_submission_entity.dart';
import '../repositories/place_submission_repository.dart';

class CreatePlaceSubmissionUseCase {
  final PlaceSubmissionRepository _repository;

  const CreatePlaceSubmissionUseCase(this._repository);

  Future<PlaceSubmissionEntity> call(PlaceSubmissionEntity submission) =>
      _repository.createSubmission(submission);
}
