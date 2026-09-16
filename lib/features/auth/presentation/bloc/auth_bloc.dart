import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/network/api_response.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/core/services/notification_service.dart';
import 'package:rsc_rider/core/services/socket_event_handler.dart';
import 'package:rsc_rider/core/services/socket_service.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:rsc_rider/features/auth/domain/usecases/login_use_case.dart';
import 'package:rsc_rider/features/auth/domain/usecases/logout_use_case.dart';
import 'package:rsc_rider/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_event.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_state.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/features/notifications/presentation/cubit/notifications_cubit.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUseCase,
    required this._logoutUseCase,
    required this._forgotPasswordUseCase,
    required this._resetPasswordUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

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
      await _connectSocketForRider();
      emit(AuthAuthenticated(rider));
    } catch (e) {
      emit(AuthFailure(_messageOf(e)));
    }
  }

  // Connects the realtime socket, subscribes to this rider's room, and starts
  // the order:status_update listener. Never blocks/fails login.
  Future<void> _connectSocketForRider() async {
    try {
      GetIt.instance<SocketService>().connect();
      final riderId = await GetIt.instance<LocalStorage>().getRiderId();
      if (riderId != null) {
        GetIt.instance<SocketService>().subscribeToRoom('rider:$riderId');
        debugPrint('[DineOut NG Rider Socket] Subscribed to rider:$riderId');
      }
      GetIt.instance<SocketEventHandler>().initialize();
    } catch (e) {
      debugPrint('[DineOut NG Rider Socket] Failed to connect after login: $e');
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

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final identifier = event.identifier.trim();
    if (identifier.isEmpty) {
      emit(const AuthFailure(AppStrings.identifierHint));
      return;
    }
    emit(const AuthLoading());
    try {
      final otpExpiresInSeconds = await _forgotPasswordUseCase(identifier);
      emit(
        ForgotPasswordSuccess(
          otpExpiresInSeconds: otpExpiresInSeconds,
          identifier: identifier,
        ),
      );
    } catch (e) {
      emit(AuthFailure(_messageOf(e)));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.code.length != 6) {
      emit(const AuthFailure(AppStrings.enterSixDigitCode));
      return;
    }
    if (event.newPassword.length < 8) {
      emit(const AuthFailure(AppStrings.passwordMinLength));
      return;
    }
    emit(const AuthLoading());
    try {
      await _resetPasswordUseCase(
        identifier: event.identifier,
        code: event.code,
        newPassword: event.newPassword,
      );
      emit(const ResetPasswordSuccess());
    } catch (e) {
      emit(AuthFailure(_messageOf(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Stop broadcasting before the API call clears the session — never leave
    // the timer running against a logged-out session.
    GetIt.instance<LocationBroadcastingService>().stopBroadcasting();
    // ActiveOrdersCubit is also a singleton — reset it so the next rider to
    // log in on this app process doesn't inherit stale orders/active
    // delivery (which would leak this rider's masterOrderId into their
    // location broadcasts).
    GetIt.instance<ActiveOrdersCubit>().reset();
    // Read the rider id before the logout call clears secure storage — it's
    // needed to unsubscribe from the rider's socket room below.
    final riderId = await GetIt.instance<LocalStorage>().getRiderId();
    try {
      await _logoutUseCase();
    } finally {
      _disconnectSocketForRider(riderId);
      GetIt.instance<AuthNotifier>().onLogout();
      emit(const AuthUnauthenticated());
    }
  }

  void _disconnectSocketForRider(String? riderId) {
    try {
      if (riderId != null) {
        GetIt.instance<SocketService>().unsubscribeFromRoom('rider:$riderId');
      }
      GetIt.instance<SocketEventHandler>().dispose();
      GetIt.instance<SocketService>().disconnect();
    } catch (e) {
      debugPrint('[DineOut NG Rider Socket] Failed to disconnect after logout: $e');
    }
  }
}
