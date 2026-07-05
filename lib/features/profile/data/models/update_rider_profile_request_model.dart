class UpdateRiderProfileRequestModel {
  const UpdateRiderProfileRequestModel({
    required this.name,
    required this.phone,
    required this.email,
  });

  final String name;
  final String phone;
  final String email;

  // Never include avatarUrl — the backend rejects/ignores it here; avatar
  // updates go through the dedicated upload endpoint.
  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
      };
}
