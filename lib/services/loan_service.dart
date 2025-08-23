import 'package:dio/dio.dart';

import '../models/loan_application_model.dart';
import 'api_client.dart';

class LoanService {
  LoanService._();
  static final LoanService I = LoanService._();

  /// Get all loans from API
  Future<List<LoanApplication>> getAllLoans() async {
    final res = await ApiClient.I.dio.get(
      '/loans/loans/all',
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );

    if (res.statusCode == 200 && res.data is List) {
      final raw = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
      return raw.map((j) => LoanApplication.fromJson(j)).toList();
    } else {
      throw Exception("Failed to load loans (HTTP ${res.statusCode})");
    }
  }

  /// Update loan status
  Future<void> updateLoanStatus({required int loanId, required String status}) async {
    final path = '/loans/loans/$loanId/status';
    final res = await ApiClient.I.dio.put(
      path,
      queryParameters: {'status': status},
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );

    final sc = res.statusCode ?? 0;
    if (sc < 200 || sc >= 300) {
      throw Exception("HTTP $sc: ${res.data}");
    }
  }
}
