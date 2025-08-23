class LoanApplication {
  final int? loanId; // server assigns
  final int userId;
  final String fatherName;
  final String address;
  final String reason;
  final int amount;
  final int duration;
  final String nidDocument;
  final String status; // submitted/pending/approved/rejected
  final DateTime? submittedAt;

  LoanApplication({
    this.loanId,
    required this.userId,
    required this.fatherName,
    required this.address,
    required this.reason,
    required this.amount,
    required this.duration,
    required this.nidDocument,
    required this.status,
    this.submittedAt,
  });

  factory LoanApplication.fromJson(Map<String, dynamic> j) => LoanApplication(
        loanId: _asIntOrNull(j['loan_id']),
        userId: _asInt(j['user_id']),
        fatherName: (j['father_name'] ?? '').toString(),
        address: (j['address'] ?? '').toString(),
        reason: (j['reason'] ?? '').toString(),
        amount: _asInt(j['amount']),
        duration: _asInt(j['duration']),
        nidDocument: (j['nid_document'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        submittedAt: j['submitted_at'] == null ? null : DateTime.tryParse(j['submitted_at'].toString()),
      );

  /// POST /loans/loans/  (server will set loan_id & submitted_at)
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

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

int? _asIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}
