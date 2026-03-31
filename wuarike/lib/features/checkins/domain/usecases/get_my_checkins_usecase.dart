import '../entities/checkin_entity.dart';
import '../repositories/checkin_repository.dart';

class GetMyCheckInsUseCase {
  final CheckInRepository _repository;
  GetMyCheckInsUseCase(this._repository);

  Future<List<CheckInEntity>> call() => _repository.getMyCheckIns();
}