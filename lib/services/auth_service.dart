// lib/services/auth_service.dart
import 'package:dio/dio.dart';

import '../models/AdminModel.dart';
import '../models/UserModel.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService I = AuthService._();

  // ✅ trailing slashes where backend expects them
  static const String REGISTER_PATH = '/users/users/';
  static const String USERS_ALL_PATH = '/users/users/all/';
  static const String ADMINS_ALL_PATH = '/admins/admins/admins/';

  UserModel? _currentUser;
  AdminModel? _currentAdmin;

  UserModel? get currentUser => _currentUser;
  AdminModel? get currentAdmin => _currentAdmin;

  Future<UserModel> register({
    required String name,
    required String phone,
    required String password, // mapped to password_hash
    required String address,
  }) async {
    final payload = {
      'name': name.trim(),
      'phone': phone.trim(),
      'password_hash': password,
      'address': address.trim(),
    };

    try {
      final res = await ApiClient.I.dio.post(
        REGISTER_PATH,
        data: payload,
        options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
      );
      final sc = res.statusCode ?? 0;
      if (sc >= 200 && sc < 300) {
        if (res.data is Map) {
          _currentUser = UserModel.fromJson((res.data as Map).cast<String, dynamic>());
        } else {
          _currentUser = UserModel(
            userId: 0,
            name: name,
            phone: phone,
            passwordHash: '',
            address: address,
            balance: 0,
          );
        }
        return _currentUser!;
      }
      throw Exception('Register failed (HTTP $sc): ${res.data}');
    } on DioException catch (e) {
      throw Exception('Register failed (HTTP ${e.response?.statusCode}): ${e.response?.data}');
    }
  }

  /// Login by fetching all users and matching phone + password_hash.
  Future<UserModel> login({required String phone, required String password}) async {
    final res = await ApiClient.I.dio.get(
      USERS_ALL_PATH,
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );

    if (res.statusCode == 200 && res.data is List) {
      final list = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
      final users = list.map((j) => UserModel.fromJson(j)).toList();

      final found = users.where((u) => u.phone.trim() == phone.trim() && u.passwordHash == password);
      if (found.isNotEmpty) {
        _currentUser = found.first;
        return _currentUser!;
      }
      throw Exception('Invalid phone or password.');
    }
    throw Exception('Login failed (HTTP ${res.statusCode})');
  }

  /// ADMIN login (name + password)
  Future<AdminModel> adminLogin({
    required String username,
    required String password,
  }) async {
    final res = await ApiClient.I.dio.get(
      ADMINS_ALL_PATH,
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    if (res.statusCode == 200 && res.data is List) {
      final list = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
      final admins = list.map((j) => AdminModel.fromJson(j)).toList();
      final found = admins.where((a) => a.name == username && a.password == password);
      if (found.isNotEmpty) {
        _currentAdmin = found.first;
        return _currentAdmin!;
      }
      throw Exception('Invalid admin credentials.');
    }
    throw Exception('Admin login failed (HTTP ${res.statusCode})');
  }

  /// 🔄 Pulls fresh user record (and balance) from /users/users/all/
  /// Uses user_id if available; falls back to phone.
  Future<UserModel> refreshCurrentUser() async {
    final me = _currentUser;
    if (me == null) throw Exception('Not logged in');

    final res = await ApiClient.I.dio.get(
      USERS_ALL_PATH,
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    if (res.statusCode == 200 && res.data is List) {
      final list = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
      UserModel? updated;
      // Prefer matching by user_id if present
      if (me.userId > 0) {
        for (final m in list) {
          final u = UserModel.fromJson(m);
          if (u.userId == me.userId) {
            updated = u;
            break;
          }
        }
      }
      // Fallback: match by phone
      updated ??= list.map((m) => UserModel.fromJson(m)).firstWhere((u) => u.phone == me.phone, orElse: () => me);

      _currentUser = updated;
      return updated!;
    }
    throw Exception('Failed to refresh user (HTTP ${res.statusCode})');
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentAdmin = null;
  }
}
