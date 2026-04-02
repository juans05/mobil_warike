import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/resend_code_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

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
  final VerifyEmailUseCase _verifyEmailUseCase;
  final ResendCodeUseCase _resendCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required VerifyEmailUseCase verifyEmailUseCase,
    required ResendCodeUseCase resendCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _socialLoginUseCase = socialLoginUseCase,
       _verifyEmailUseCase = verifyEmailUseCase,
       _resendCodeUseCase = resendCodeUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
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
    try {
      final auth = await _loginUseCase(email: email, password: password);
      state = state.copyWith(user: AsyncValue.data(auth.user));
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Registers a new account (sends verification email, does not create session).
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _registerUseCase(name: name, email: email, password: password);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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

  /// Verifies email with 6-digit code.
  Future<void> verifyEmail({required String email, required String code}) async {
    state = state.copyWith(user: const AsyncValue.loading(), errorMessage: null);
    try {
      await _verifyEmailUseCase(email: email, code: code);
      // Once verified, we usually need to fetch the updated user info or re-login
      await checkSession();
    } catch (e) {
      state = state.copyWith(
        user: const AsyncValue.data(null),
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Resends verification code.
  Future<void> resendCode({required String email}) async {
    try {
      await _resendCodeUseCase(email: email);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Requests a password reset code.
  Future<void> forgotPassword({required String email}) async {
    try {
      await _forgotPasswordUseCase(email: email);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Resets password with code and new password.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      await _resetPasswordUseCase(
        email: email,
        code: code,
        password: password,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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
    verifyEmailUseCase: sl<VerifyEmailUseCase>(),
    resendCodeUseCase: sl<ResendCodeUseCase>(),
    resetPasswordUseCase: sl<ResetPasswordUseCase>(),
    forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
  );
});
