import '../entities/place_submission_entity.dart';

abstract class PlaceSubmissionRepository {
  Future<PlaceSubmissionEntity> createSubmission(PlaceSubmissionEntity submission);
}
