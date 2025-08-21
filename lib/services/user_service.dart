// lib/services/user_service.dart
import 'package:dio/dio.dart';

import 'api_client.dart';

class UserService {
  UserService._();
  static final UserService I = UserService._();

  /// PUT /users/users/{userId}/balance?amount=123
  Future<void> creditBalance(int userId, int amount) async {
    final res = await ApiClient.I.dio.put(
      '/users/users/$userId/balance',
      queryParameters: {'amount': amount},
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    final sc = res.statusCode ?? 0;
    if (sc < 200 || sc >= 300) {
      throw Exception('Credit failed (HTTP $sc): ${res.data}');
    }
  }
}
