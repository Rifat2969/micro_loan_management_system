import '../models/UserModel.dart';

/// Adapter converts raw API JSON into a [UserModel]
/// This separates data-format concerns from your domain model.
class UserAdapter {
  static UserModel fromApi(Map<String, dynamic> j) {
    return UserModel(
      userId: _asInt(j['user_id']),
      name: (j['name'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      passwordHash: (j['password_hash'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      balance: _asInt(j['balance']),
      createdAt: j['created_at'] == null ? null : DateTime.tryParse(j['created_at'].toString()),
    );
  }
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
