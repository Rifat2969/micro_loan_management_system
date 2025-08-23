class LoanApplication {
  final int? loanId;
  final int userId;
  final int amount;
  final int duration; // in months
  final String status;
  final String? reason;
  final String fatherName;
  final String address;
  final DateTime? createdAt;

  LoanApplication({
    this.loanId,
    required this.userId,
    required this.amount,
    required this.duration,
    required this.status,
    this.reason,
    required this.fatherName,
    required this.address,
    this.createdAt,
  });

  factory LoanApplication.fromJson(Map<String, dynamic> j) => LoanApplication(
        loanId: _asInt(j['loan_id']),
        userId: _asInt(j['user_id']),
        amount: _asInt(j['amount']),
        duration: _asInt(j['duration']),
        status: (j['status'] ?? '').toString(),
        reason: j['reason']?.toString(),
        fatherName: (j['father_name'] ?? '').toString(),
        address: (j['address'] ?? '').toString(),
        createdAt: j['created_at'] == null ? null : DateTime.tryParse(j['created_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'loan_id': loanId,
        'user_id': userId,
        'amount': amount,
        'duration': duration,
        'status': status,
        'reason': reason,
        'father_name': fatherName,
        'address': address,
        'created_at': createdAt?.toIso8601String(),
      };
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
