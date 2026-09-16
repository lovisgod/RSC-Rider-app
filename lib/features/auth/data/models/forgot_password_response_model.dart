class ForgotPasswordResponseModel {
  const ForgotPasswordResponseModel({
    required this.sent,
    required this.otpExpiresInSeconds,
  });

  final bool sent;
  final int otpExpiresInSeconds;

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ForgotPasswordResponseModel(
      sent: data['sent'] as bool? ?? false,
      otpExpiresInSeconds: data['otpExpiresInSeconds'] as int? ?? 0,
    );
  }
}
