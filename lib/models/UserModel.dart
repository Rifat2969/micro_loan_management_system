class UserModel {
  final String? id;
  final int? userId;
  final String name;
  final String phone;
  final String passwordHash;
  final String address;
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.userId,
    required this.name,
    required this.phone,
    required this.passwordHash,
    required this.address,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    DateTime? created;
    final rawCreated = j['created_at']?.toString();
    if (rawCreated != null && rawCreated.isNotEmpty) {
      created = DateTime.tryParse(rawCreated);
    }

    return UserModel(
      id: j['id']?.toString() ?? j['_id']?.toString(),
      userId: j['user_id'] is int ? j['user_id'] as int : int.tryParse(j['user_id']?.toString() ?? ''),
      name: j['name']?.toString() ?? '',
      phone: j['phone']?.toString() ?? '',
      passwordHash: j['password_hash']?.toString() ?? '',
      address: j['address']?.toString() ?? '',
      createdAt: created,
    );
  }
}
