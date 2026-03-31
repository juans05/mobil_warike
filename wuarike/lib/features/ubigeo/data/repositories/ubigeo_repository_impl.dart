import '../domain/entities/district_entity.dart';
import '../domain/repositories/ubigeo_repository.dart';
import '../data/datasources/ubigeo_remote_datasource.dart';

class UbigeoRepositoryImpl implements UbigeoRepository {
  final UbigeoRemoteDataSource _remoteDataSource;

  const UbigeoRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DistrictEntity>> getDistricts() async {
    return _remoteDataSource.getLimaDistricts();
  }
}
