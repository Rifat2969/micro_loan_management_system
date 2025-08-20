// lib/services/auth_service.dart
// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';

import '../models/AdminModel.dart';
import '../models/UserModel.dart';
import '../models/user_create_request.dart';
import 'api_client.dart';

class AuthService {
  // ---- Singleton ----
  AuthService._();
  static final AuthService I = AuthService._();

  // ---- Endpoints ----
  static const String REGISTER_PATH = '/users/users/'; // POST
  static const String USERS_ALL_PATH = '/users/users/all'; // GET
  static const String ADMINS_ALL_PATH = '/admins/admins/admins'; // GET
  static const String LOANS_PATH = '/loans/loans/'; // POST

  UserModel? _currentUser;
  AdminModel? _currentAdmin;

  UserModel? get currentUser => _currentUser;
  AdminModel? get currentAdmin => _currentAdmin;

  // ---------- Register ----------
  Future<UserModel?> register(UserCreateRequest req) async {
    final res = await ApiClient.I.dio.post(
      REGISTER_PATH,
      data: req.toJson(),
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (res.data is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(res.data as Map<String, dynamic>);
        await ApiClient.I.saveToken('user_session_${_currentUser!.phone}');
        return _currentUser;
      }
    }
    throw Exception('Registration failed (HTTP ${res.statusCode})');
  }

  // ---------- User Login ----------
  Future<UserModel?> login({required String phone, required String password}) async {
    final res = await ApiClient.I.dio.get(
      USERS_ALL_PATH,
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    if (res.statusCode == 200 && res.data is List) {
      final list = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
      final match = list.firstWhere(
        (u) => (u['phone']?.toString() ?? '') == phone && (u['password_hash']?.toString() ?? '') == password,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        _currentUser = UserModel.fromJson(match);
        await ApiClient.I.saveToken('user_session_${_currentUser!.phone}');
        return _currentUser;
      }
      throw Exception('Invalid phone or password');
    }
    throw Exception('Login failed (HTTP ${res.statusCode})');
  }

  // ---------- Admin Login ----------
  Future<AdminModel?> adminLogin({required String username, required String password}) async {
    final res = await ApiClient.I.dio.get(
      ADMINS_ALL_PATH,
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    if (res.statusCode == 200 && res.data is List) {
      final list = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
      final match = list.firstWhere(
        (a) => (a['name']?.toString() ?? '') == username && (a['password']?.toString() ?? '') == password,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        _currentAdmin = AdminModel.fromJson(match);
        await ApiClient.I.saveToken('admin_session_${_currentAdmin!.name}');
        return _currentAdmin;
      }
      throw Exception('Invalid admin credentials');
    }
    throw Exception('Admin login failed (HTTP ${res.statusCode})');
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentAdmin = null;
    await ApiClient.I.clearToken();
  }
}
