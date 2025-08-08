class LoanApplication {
  final String name;
  final double amount;
  final int term;
  final String documents;
  String status;

  LoanApplication({
    required this.name,
    required this.amount,
    required this.term,
    required this.documents,
    this.status = 'Pending',
  });
}