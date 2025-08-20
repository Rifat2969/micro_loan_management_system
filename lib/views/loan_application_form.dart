// lib/views/loan_application_form.dart
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'application_overview_page.dart';

class LoanApplicationForm extends StatefulWidget {
  const LoanApplicationForm({super.key});

  @override
  State<LoanApplicationForm> createState() => _LoanApplicationFormState();
}

class _LoanApplicationFormState extends State<LoanApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _fatherController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  final _amountController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _fatherController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    _amountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.I.currentUser; // read-only display (if you want)
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Application')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (user != null) ...[
                Text('Logged in as: ${user.name} (ID: ${user.userId})', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _fatherController,
                decoration: const InputDecoration(labelText: "Father's Name"),
                validator: (v) => v == null || v.isEmpty ? "Enter father's name" : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v == null || v.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Reason for the loan'),
                validator: (v) => v == null || v.isEmpty ? 'Enter reason' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount of loan'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Amount must be a positive number';
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (months)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter duration';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Duration must be a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _showOverviewPage,
                child: const Text('Overview Application Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOverviewPage() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoanApplicationOverviewPage(
            fatherName: _fatherController.text,
            address: _addressController.text,
            reason: _reasonController.text,
            amount: _amountController.text,
            duration: _durationController.text,
          ),
        ),
      );
    }
  }
}
