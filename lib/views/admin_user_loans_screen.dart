// lib/views/admin_user_loans_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/loan_application_model.dart';
import '../services/api_client.dart';

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

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
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
        SnackBar(content: Text('Cannot change status from \"${l.status}\".')),
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

      // Optional: credit balance on approve if your backend supports it
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
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/admin_home'); // back to AdminHome
          },
        ),
        title: Text('${widget.userName} — Applications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.separated(
                  itemCount: _loans.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final l = _loans[i];
                    final can = _canTransition(l.status);
                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text('Amount: ${l.amount} BDT • Duration: ${l.duration} mo'),
                      subtitle: Text(
                        'Status: ${l.status}\\nReason: ${l.reason}\\nSubmitted: ${_fmtDate(l.submittedAt)}',
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: can ? () => _updateStatus(l, 'rejected') : null,
                            child: const Text('Reject'),
                          ),
                          ElevatedButton(
                            onPressed: can ? () => _updateStatus(l, 'approved') : null,
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
