import '../models/loan_application_model.dart';
import 'loan_service.dart';
import 'user_service.dart';

class LoanFacade {
  LoanFacade._();
  static final LoanFacade I = LoanFacade._();

  Future<void> approveLoan(LoanApplication loan) async {
    if (loan.loanId == null || loan.loanId == 0) {
      throw Exception("Loan ID missing");
    }
    await LoanService.I.updateLoanStatus(
      loanId: loan.loanId!,
      status: "approved",
    );
    await UserService.I.creditBalance(
      loan.userId,
      loan.amount,
    );
  }

  Future<void> rejectLoan(LoanApplication loan) async {
    if (loan.loanId == null || loan.loanId == 0) {
      throw Exception("Loan ID missing");
    }
    await LoanService.I.updateLoanStatus(
      loanId: loan.loanId!,
      status: "rejected",
    );
  }
}
