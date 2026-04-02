import '../../../places/domain/entities/place_submission_entity.dart';

abstract class AdminRepository {
  Future<List<PlaceSubmissionEntity>> getPendingSubmissions();
  Future<void> approveSubmission(String id);
  Future<void> rejectSubmission(String id, String reason);
}
