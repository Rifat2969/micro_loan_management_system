import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/loan_application_model.dart';
import '../services/api_client.dart';

class LoanDecorator {
  final LoanApplication loan;
  final String userName;

  LoanDecorator(this.loan, {required this.userName});

  String get amountDisplay => "${loan.amount} BDT";
  String get durationDisplay => "${loan.duration} months";
  String get reasonDisplay => loan.reason ?? "No reason given";

  String get statusDisplay => "Status: ${loan.status}";
  String get userNameDisplay => "User Name: $userName";
  String get fatherNameDisplay => "User's Father Name: ${loan.fatherName}";
  String get addressDisplay => "User's Address: ${loan.address}";
}

class HighValueLoanDecorator extends LoanDecorator {
  HighValueLoanDecorator(LoanApplication loan, {required String userName}) : super(loan, userName: userName);

  bool get isHighValue => loan.amount >= 100000;

  @override
  String get amountDisplay {
    if (isHighValue) {
      return "🔥 HIGH VALUE: ${loan.amount} BDT";
    }
    return super.amountDisplay;
  }
}

class AdminUserLoansScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const AdminUserLoansScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminUserLoansScreen> createState() => _AdminUserLoansScreenState();
}

class _AdminUserLoansScreenState extends State<AdminUserLoansScreen> {
  List<LoanApplication> _loans = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLoans();
  }

  Future<void> _fetchLoans() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.I.dio.get(
        '/loans/loans/all',
        options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
      );

      if (res.statusCode == 200 && res.data is List) {
        final raw = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
        final all = raw.map((j) => LoanApplication.fromJson(j)).toList();
        final mine = all.where((l) => l.userId == widget.userId).toList();
        setState(() => _loans = mine);
      } else {
        setState(() => _error = 'Failed to load loans (HTTP ${res.statusCode})');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _canTransition(String status) {
    final s = status.toLowerCase().trim();
    return s == 'submitted' || s == 'pending';
  }

  Future<void> _updateStatus(LoanApplication l, String status) async {
    if (l.loanId == null || l.loanId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing loan ID.')),
      );
      return;
    }

    if (!_canTransition(l.status)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot change status from "${l.status}".')),
      );
      return;
    }

    try {
      final path = '/loans/loans/${l.loanId}/status';
      final res = await ApiClient.I.dio.put(
        path,
        queryParameters: {'status': status},
        options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
      );
      final sc = res.statusCode ?? 0;
      if (sc < 200 || sc >= 300) {
        throw Exception('HTTP $sc: ${res.data}');
      }

      if (status == 'approved') {
        try {
          await ApiClient.I.dio.put(
            '/users/users/${l.userId}/balance',
            queryParameters: {'amount': l.amount},
            options: Options(validateStatus: (s) => s != null && s < 600),
          );
        } catch (_) {}
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status set to $status')),
      );
      _fetchLoans();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.userName} — Applications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : (_loans.isEmpty
                  ? const Center(child: Text('No applications for loan'))
                  : ListView.separated(
                      itemCount: _loans.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final l = _loans[i];
                        final decorated = HighValueLoanDecorator(l, userName: widget.userName);
                        final can = _canTransition(l.status);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount: ${decorated.amountDisplay}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('Duration: ${decorated.durationDisplay}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('Reason for asking loan: ${decorated.reasonDisplay}',
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 6),
                                Text(decorated.userNameDisplay, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 6),
                                Text(decorated.fatherNameDisplay, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 6),
                                Text(decorated.addressDisplay, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: can ? () => _updateStatus(l, 'rejected') : null,
                                      child: const Text('Reject'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: can ? () => _updateStatus(l, 'approved') : null,
                                      child: const Text('Approve'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
    );
  }
}
