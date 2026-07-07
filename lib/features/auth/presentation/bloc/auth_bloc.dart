import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/network/api_response.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/core/services/notification_service.dart';
import 'package:rsc_rider/features/auth/domain/usecases/login_use_case.dart';
import 'package:rsc_rider/features/auth/domain/usecases/logout_use_case.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_event.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_state.dart';
import 'package:rsc_rider/features/notifications/presentation/cubit/notifications_cubit.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUseCase,
    required this._logoutUseCase,
  }) : super(const AuthInitial()) {
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
        identifier: event.identifier,
        password: event.password,
      );
      // Notifies go_router's refreshListenable to trigger a redirect.
      GetIt.instance<AuthNotifier>().onLogin();
      // Fire-and-forget — so the unread badge is ready by the time the
      // rider reaches the dashboard.
      unawaited(GetIt.instance<NotificationsCubit>().loadNotifications());
      // Re-registers the FCM token so it's associated with this rider's
      // session. Fire-and-forget — a failure here must never block login.
      if (GetIt.instance.isRegistered<NotificationService>()) {
        unawaited(GetIt.instance<NotificationService>().refreshAndSaveToken());
      }
      emit(AuthAuthenticated(rider));
    } catch (e) {
      emit(AuthFailure(_messageOf(e)));
    }
  }

  String _messageOf(Object error) {
    if (error is DioException && error.error is ApiFailure) {
      return (error.error! as ApiFailure).message;
    }
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.contains('not a rider')
        ? AppStrings.notARiderAccount
        : message;
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Stop broadcasting before the API call clears the session — never leave
    // the timer running against a logged-out session.
    GetIt.instance<LocationBroadcastingService>().stopBroadcasting();
    try {
      await _logoutUseCase();
    } finally {
      GetIt.instance<AuthNotifier>().onLogout();
      emit(const AuthUnauthenticated());
    }
  }
}
