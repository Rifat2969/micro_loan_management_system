import '../models/loan_application_model.dart';
import 'loan_service.dart';

class LoanServiceProxy {
  final LoanService _realService = LoanService.I;
  List<LoanApplication>? _cachedLoans;

  Future<List<LoanApplication>> getAllLoans({bool forceRefresh = false}) async {
    if (_cachedLoans != null && !forceRefresh) {
      print("✅ Returning cached loans");
      return _cachedLoans!;
    }
    print("🌐 Fetching loans from server...");
    _cachedLoans = await _realService.getAllLoans();
    return _cachedLoans!;
  }

  Future<void> updateLoanStatus({required int loanId, required String status}) {
    // clear cache when loan status changes
    _cachedLoans = null;
    return _realService.updateLoanStatus(loanId: loanId, status: status);
  }
}
