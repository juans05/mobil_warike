import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../domain/entities/profile_entity.dart';

final _profileDsProvider = Provider<ProfileDataSource>(
  (ref) => ProfileDataSourceImpl(sl<DioClient>()),
);

final profileProvider =
    FutureProvider<ProfileEntity>((ref) async {
  return ref.watch(_profileDsProvider).getProfile();
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity?>> {
  final ProfileDataSource _ds;
  final Ref _ref;

  ProfileNotifier(this._ds, this._ref)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _ds.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update({String? name, String? bio}) async {
    try {
      final updated = await _ds.updateProfile(name: name, bio: bio);
      state = AsyncValue.data(updated);
      _ref.invalidate(profileProvider);
    } catch (_) {}
  }

  Future<void> logout() async {
    await sl<TokenStorage>().clearTokens();
    state = const AsyncValue.data(null);
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier,
    AsyncValue<ProfileEntity?>>((ref) {
  return ProfileNotifier(ref.watch(_profileDsProvider), ref);
});