import '../repositories/admin_repository.dart';

class ApproveSubmissionUseCase {
  final AdminRepository _repository;

  const ApproveSubmissionUseCase(this._repository);

  Future<void> call(String id) => _repository.approveSubmission(id);
}
