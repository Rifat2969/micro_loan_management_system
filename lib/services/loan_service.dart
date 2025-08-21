// lib/services/loan_service.dart
import 'package:dio/dio.dart';

import '../models/loan_model.dart';
import 'api_client.dart';

class LoanService {
  LoanService._();
  static final LoanService I = LoanService._();

  static const String loansAllPath = '/loans/loans/all';

  Future<List<LoanApplication>> getAllLoans() async {
    final res = await ApiClient.I.dio.get(
      loansAllPath,
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    if (res.statusCode == 200 && res.data is List) {
      final list = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
      return list.map((e) => LoanApplication.fromJson(e)).toList();
    }
    throw Exception('Failed to load loans (HTTP ${res.statusCode})');
  }

  /// PUT /loans/loans/{loan_id}/status?status=approved|rejected
  Future<void> updateLoanStatus({required int loanId, required String status}) async {
    final path = '/loans/loans/$loanId/status';
    final res = await ApiClient.I.dio.put(
      path,
      queryParameters: {'status': status},
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    final sc = res.statusCode ?? 0;
    if (sc < 200 || sc >= 300) {
      throw Exception('Failed to update loan status (HTTP $sc): ${res.data}');
    }
  }

  /// POST /loans/loans/
  Future<LoanApplication> createLoan(LoanApplication payload) async {
    final res = await ApiClient.I.dio.post(
      '/loans/loans/',
      data: payload.toJson(),
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
    );
    if ((res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300) {
      if (res.data is Map) {
        return LoanApplication.fromJson((res.data as Map).cast<String, dynamic>());
      }
      // if server returns nothing, echo the payload
      return payload;
    }
    throw Exception('Create loan failed (HTTP ${res.statusCode}): ${res.data}');
  }
}
