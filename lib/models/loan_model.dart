// lib/models/loan_model.dart
class LoanApplication {
  final int userId;
  final String fatherName;
  final String address;
  final String reason;
  final int amount;
  final int duration;
  final String nidDocument;
  final String status;

  LoanApplication({
    required this.userId,
    required this.fatherName,
    required this.address,
    required this.reason,
    required this.amount,
    required this.duration,
    required this.nidDocument,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'father_name': fatherName,
        'address': address,
        'reason': reason,
        'amount': amount,
        'duration': duration,
        'nid_document': nidDocument,
        'status': status,
      };
}
