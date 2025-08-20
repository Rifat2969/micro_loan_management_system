class UserCreateRequest {
  final String name;
  final String phone;
  final String address;
  final String passwordHash;

  UserCreateRequest({
    required this.name,
    required this.phone,
    required this.address,
    required this.passwordHash,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'password_hash': passwordHash,
        'address': address,
      };
}
