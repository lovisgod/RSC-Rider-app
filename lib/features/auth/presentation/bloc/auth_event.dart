import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.identifier, required this.password});

  final String identifier;
  final String password;

  @override
  List<Object> get props => [identifier, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class ForgotPasswordSubmitted extends AuthEvent {
  const ForgotPasswordSubmitted(this.identifier);

  final String identifier;

  @override
  List<Object> get props => [identifier];
}

final class ResetPasswordSubmitted extends AuthEvent {
  const ResetPasswordSubmitted({
    required this.identifier,
    required this.code,
    required this.newPassword,
  });

  final String identifier;
  final String code;
  final String newPassword;

  @override
  List<Object> get props => [identifier, code, newPassword];
}
