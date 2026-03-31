import '../../../../core/network/dio_client.dart';
import '../models/district_model.dart';
import '../../../../core/network/api_exception.dart';
import 'package:dio/dio.dart';

abstract class UbigeoRemoteDataSource {
  Future<List<DistrictModel>> getLimaDistricts();
}

class UbigeoRemoteDataSourceImpl implements UbigeoRemoteDataSource {
  final DioClient _client;

  const UbigeoRemoteDataSourceImpl(this._client);

  @override
  Future<List<DistrictModel>> getLimaDistricts() async {
    try {
      final response = await _client.dio.get(
        '/ubigeo/districts',
        queryParameters: {
          'department': 'LIMA',
          'province': 'LIMA',
        },
      );
      final list = (response.data as List<dynamic>)
          .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
