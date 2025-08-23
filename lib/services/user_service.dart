import 'package:dio/dio.dart';

import 'api_client.dart';

class UserService {
  UserService._();
  static final UserService I = UserService._();

  /// Credit balance for a user
  Future<void> creditBalance(int userId, int amount) async {
    final res = await ApiClient.I.dio.put(
      '/users/users/$userId/balance',
      queryParameters: {'amount': amount},
      options: Options(validateStatus: (s) => s != null && s < 600),
    );

    if (res.statusCode == null || res.statusCode! >= 400) {
      throw Exception("Balance update failed: ${res.data}");
    }
  }
}
