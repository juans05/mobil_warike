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
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/resend_code_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../services/location_service.dart';
import '../../features/places/domain/repositories/place_submission_repository.dart';
import '../../features/places/data/repositories/place_submission_repository_impl.dart';
import '../../features/places/domain/usecases/create_place_submission_usecase.dart';
import '../../features/places/data/datasources/places_remote_datasource.dart';

import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/get_pending_submissions_usecase.dart';
import '../../features/admin/domain/usecases/approve_submission_usecase.dart';
import '../../features/admin/domain/usecases/reject_submission_usecase.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Hive ─────────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  await Hive.openBox('cache');

  // ─── Core ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<TokenStorage>()));
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // ─── Places Extra ────────────────────────────────────────────────────────
  sl.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PlaceSubmissionRepository>(
    () => PlaceSubmissionRepositoryImpl(sl<PlacesRemoteDataSource>()),
  );
  sl.registerLazySingleton<CreatePlaceSubmissionUseCase>(
    () => CreatePlaceSubmissionUseCase(sl<PlaceSubmissionRepository>()),
  );

  // ─── Admin ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetPendingSubmissionsUseCase>(
    () => GetPendingSubmissionsUseCase(sl<AdminRepository>()),
  );
  sl.registerLazySingleton<ApproveSubmissionUseCase>(
    () => ApproveSubmissionUseCase(sl<AdminRepository>()),
  );
  sl.registerLazySingleton<RejectSubmissionUseCase>(
    () => RejectSubmissionUseCase(sl<AdminRepository>()),
  );

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
  sl.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResendCodeUseCase>(
    () => ResendCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );
}