class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.identifier,
    required this.code,
    required this.newPassword,
  });

  final String identifier;
  final String code;
  final String newPassword;

  // The backend accepts the OTP in either phoneCode or emailCode — always
  // send it as phoneCode, same approach as the customer app.
  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'phoneCode': code,
        'newPassword': newPassword,
      };
}
