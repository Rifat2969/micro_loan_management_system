// lib/views/application_overview_page.dart
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
  final String amount; // string, will be parsed to int
  final String duration; // string, will be parsed to int

  const LoanApplicationOverviewPage({
    super.key,
    required this.fatherName,
    required this.address,
    required this.reason,
    required this.amount,
    required this.duration,
  });

  Future<void> _submitToApi(BuildContext context) async {
    _showLoading(context);

    try {
      final user = AuthService.I.currentUser;
      if (user == null) {
        throw Exception("Please login first.");
      }

      final payload = LoanApplication(
        userId: user.userId,
        fatherName: fatherName,
        address: address,
        reason: reason,
        amount: int.tryParse(amount) ?? 0,
        duration: int.tryParse(duration) ?? 0,
        nidDocument: "",
        status: "submitted",
      );

      final res = await ApiClient.I.dio.post(
        '/loans/loans/',
        data: payload.toJson(),
        options: Options(validateStatus: (s) => s != null && s < 600),
      );

      Navigator.of(context).pop(); // close loading dialog

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ApplicationSubmittedPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: HTTP ${res.statusCode}")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showLoading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(width: 16),
              Text("Submitting..."),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAndSubmit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: const Text("Do you want to submit this loan application?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _submitToApi(context);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Overview Application")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
To,
The Manager
MicroLoan Bank

Subject: Loan Application

Sir,

I am applying for a loan.

Father's Name: $fatherName
Address: $address
Reason: $reason
Amount: $amount BDT
Duration: $duration months

Yours faithfully,
${AuthService.I.currentUser?.name ?? "User"}
''',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Edit"),
                ),
                const Spacer(),
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
