import '../entities/district_entity.dart';

abstract class UbigeoRepository {
  Future<List<DistrictEntity>> getDistricts();
}
