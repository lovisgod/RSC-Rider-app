class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({required this.identifier});

  final String identifier;

  Map<String, dynamic> toJson() => {'identifier': identifier};
}
