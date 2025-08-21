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
  late final TextEditingController _nameController;
  late final TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    final user = AuthService.I.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _userIdController = TextEditingController(text: (user?.userId ?? 0).toString());
  }

  @override
  void dispose() {
    _fatherController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    _amountController.dispose();
    _durationController.dispose();
    _nameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      TextFormField(
        controller: _nameController,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
          labelText: "Name",
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
        ),
        readOnly: true,
        enabled: false,
      ),
      TextFormField(
        controller: _userIdController,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
          labelText: "User ID",
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
        ),
        readOnly: true,
        enabled: false,
      ),
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
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Application')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: fields.length,
                  itemBuilder: (context, idx) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        fields[idx],
                        if (idx != fields.length - 1) const SizedBox(height: 15),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
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
