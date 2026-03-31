import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../network/token_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/social_login_usecase.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Hive ─────────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  await Hive.openBox('cache');

  // ─── Core ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<TokenStorage>()));

  // ─── Auth ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SocialLoginUseCase>(
    () => SocialLoginUseCase(sl<AuthRepository>()),
  );
}