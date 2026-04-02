import '../repositories/admin_repository.dart';

class RejectSubmissionUseCase {
  final AdminRepository _repository;

  const RejectSubmissionUseCase(this._repository);

  Future<void> call(String id, String reason) => _repository.rejectSubmission(id, reason);
}
