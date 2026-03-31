import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class AuthState {
  final AsyncValue<UserEntity?> user;
  final String? errorMessage;

  const AuthState({this.user = const AsyncValue.data(null), this.errorMessage});

  AuthState copyWith({AsyncValue<UserEntity?>? user, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  final SocialLoginUseCase _socialLoginUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SocialLoginUseCase socialLoginUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _socialLoginUseCase = socialLoginUseCase,
       super(const AuthState());

  /// Checks existing session on app start.
  Future<void> checkSession() async {
    state = state.copyWith(user: const AsyncValue.loading());
    try {
      final user = await _getCurrentUserUseCase();
      state = state.copyWith(user: AsyncValue.data(user));
    } catch (_) {
      // No valid session — treat as unauthenticated (not an error state)
      state = state.copyWith(user: const AsyncValue.data(null));
    }
  }

  /// Signs in with email and password.
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      user: const AsyncValue.loading(),
      errorMessage: null,
    );
    try {
      final auth = await _loginUseCase(email: email, password: password);
      state = state.copyWith(user: AsyncValue.data(auth.user));
    } catch (e) {
      state = state.copyWith(
        user: const AsyncValue.data(null),
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Registers a new account.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      user: const AsyncValue.loading(),
      errorMessage: null,
    );
    try {
      final auth = await _registerUseCase(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(user: AsyncValue.data(auth.user));
    } catch (e) {
      state = state.copyWith(
        user: const AsyncValue.data(null),
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Signs in with a social provider (Google/Apple).
  Future<void> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? name,
    String? photoUrl,
  }) async {
    state = state.copyWith(
      user: const AsyncValue.loading(),
      errorMessage: null,
    );
    try {
      final auth = await _socialLoginUseCase(
        provider: provider,
        token: token,
        email: email,
        name: name,
        photoUrl: photoUrl,
      );
      state = state.copyWith(user: AsyncValue.data(auth.user));
    } catch (e) {
      state = state.copyWith(
        user: const AsyncValue.data(null),
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final sl = GetIt.instance;
  return AuthNotifier(
    loginUseCase: sl<LoginUseCase>(),
    registerUseCase: sl<RegisterUseCase>(),
    logoutUseCase: sl<LogoutUseCase>(),
    getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    socialLoginUseCase: sl<SocialLoginUseCase>(),
  );
});
