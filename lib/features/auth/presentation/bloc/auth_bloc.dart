import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/features/auth/domain/usecases/login_use_case.dart';
import 'package:rsc_rider/features/auth/domain/usecases/logout_use_case.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_event.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ignore: prefer_initializing_formals — named params need public names for DI callers.
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final rider = await _loginUseCase(
        email: event.email,
        password: event.password,
      );
      // Notifies go_router's refreshListenable to trigger a redirect.
      GetIt.instance<AuthNotifier>().onLogin();
      emit(AuthAuthenticated(rider));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _logoutUseCase();
    } finally {
      GetIt.instance<AuthNotifier>().onLogout();
      emit(const AuthUnauthenticated());
    }
  }
}
