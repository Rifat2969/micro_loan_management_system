// lib/views/application_overview_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/loan_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'application_submitted_page.dart';

class LoanApplicationOverviewPage extends StatelessWidget {
  final String fatherName;
  final String address;
  final String reason;
  final String amount; // parsed to int on submit
  final String duration; // parsed to int on submit

  const LoanApplicationOverviewPage({
    super.key,
    required this.fatherName,
    required this.address,
    required this.reason,
    required this.amount,
    required this.duration,
  });

  Future<void> _submitToApi(BuildContext context) async {
    final user = AuthService.I.currentUser;
    final userId = user?.userId ?? 0;
    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before submitting.')),
      );
      return;
    }

    final amountInt = int.tryParse(amount.trim()) ?? 0;
    final durationInt = int.tryParse(duration.trim()) ?? 0;
    if (amountInt <= 0 || durationInt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount and Duration must be greater than zero.')),
      );
      return;
    }

    _showLoading(context);

    try {
      final payload = LoanApplication(
        userId: userId, // ✅ auto from logged-in user
        fatherName: fatherName.trim(),
        address: address.trim(),
        reason: reason.trim(),
        amount: amountInt,
        duration: durationInt,
        nidDocument: '', // not used now
        status: 'submitted',
      );

      final res = await ApiClient.I.dio.post(
        AuthService.LOANS_PATH, // '/loans/loans/'
        data: payload.toJson(),
        options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
      );

      if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // close loader

      final sc = res.statusCode ?? 0;
      if (sc == 200 || sc == 201 || sc == 204) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ApplicationSubmittedPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed (HTTP $sc)')),
        );
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _confirmAndSubmit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit this application?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitToApi(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 100),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Submitting...'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.I.currentUser; // for showing name only
    final displayName = user?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(title: const Text("Overview Application")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "To,\nThe Manager\nMicroLoan Bank\n\nSubject: Loan Application\n",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''Sir,

I hope this letter finds you in good health and spirits.

I am $displayName, son/daughter of $fatherName, residing at $address.
I am writing to apply for a loan of BDT $amount for a duration of $duration month(s).
The reason for seeking this loan is as follows:
$reason

I sincerely hope that you will look into my request and grant me the required loan. If you need any further information, please let me know.

Thank you for your time and consideration.

Yours faithfully,

$displayName
''',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Edit"),
                ),
                ElevatedButton(
                  onPressed: () => _confirmAndSubmit(context),
                  child: const Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
