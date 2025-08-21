// lib/models/user_model.dart
class UserModel {
  final int userId;
  final String name;
  final String phone;
  final String passwordHash; // never show in UI
  final String address;
  final int balance;
  final DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.passwordHash,
    required this.address,
    required this.balance,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        userId: _asInt(j['user_id']),
        name: (j['name'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        passwordHash: (j['password_hash'] ?? '').toString(),
        address: (j['address'] ?? '').toString(),
        balance: _asInt(j['balance']),
        createdAt: j['created_at'] == null ? null : DateTime.tryParse(j['created_at'].toString()),
      );
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
