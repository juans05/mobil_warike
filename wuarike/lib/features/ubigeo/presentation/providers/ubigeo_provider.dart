import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/ubigeo_remote_datasource.dart';
import '../../data/repositories/ubigeo_repository_impl.dart';
import '../../domain/entities/district_entity.dart';
import '../../domain/repositories/ubigeo_repository.dart';

final ubigeoRemoteDataSourceProvider = Provider<UbigeoRemoteDataSource>(
  (ref) => UbigeoRemoteDataSourceImpl(sl()),
);

final ubigeoRepositoryProvider = Provider<UbigeoRepository>(
  (ref) => UbigeoRepositoryImpl(ref.watch(ubigeoRemoteDataSourceProvider)),
);

final districtsProvider = FutureProvider<List<DistrictEntity>>((ref) async {
  final repository = ref.watch(ubigeoRepositoryProvider);
  return repository.getDistricts();
});
