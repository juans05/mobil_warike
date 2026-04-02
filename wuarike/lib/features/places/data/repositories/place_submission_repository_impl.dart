import '../../domain/entities/place_submission_entity.dart';
import '../../domain/repositories/place_submission_repository.dart';
import '../datasources/places_remote_datasource.dart';
import '../models/place_submission_model.dart';

class PlaceSubmissionRepositoryImpl implements PlaceSubmissionRepository {
  final PlacesRemoteDataSource _remoteDataSource;

  const PlaceSubmissionRepositoryImpl(this._remoteDataSource);

  @override
  Future<PlaceSubmissionEntity> createSubmission(PlaceSubmissionEntity submission) async {
    // 1. Upload image if it's a local file path
    String imageUrl = submission.coverImageUrl;
    if (!imageUrl.startsWith('http')) {
      imageUrl = await _remoteDataSource.uploadPlaceImage(imageUrl);
    }

    // 2. Map to model and submit
    final model = PlaceSubmissionModel.fromEntity(submission).copyWith(
      coverImageUrl: imageUrl,
    );
    
    return await _remoteDataSource.submitPlace(model.toJson());
  }
}

extension on PlaceSubmissionModel {
  PlaceSubmissionModel copyWith({String? coverImageUrl}) {
    return PlaceSubmissionModel(
      id: id,
      name: name,
      categoryId: categoryId,
      district: district,
      address: address,
      description: description,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      website: website,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status,
      createdAt: createdAt,
    );
  }
}
