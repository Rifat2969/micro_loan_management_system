import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'application_overview_page.dart';

class LoanApplicationForm extends StatefulWidget {
  const LoanApplicationForm({super.key});

  @override
  State<LoanApplicationForm> createState() => _LoanApplicationFormState();
}

class _LoanApplicationFormState extends State<LoanApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  final _amountController = TextEditingController();
  final _durationController = TextEditingController();

  File? _nidImage;

  Future<void> _pickNidImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _nidImage = File(picked.path);
      });
    }
  }

  void _showOverviewDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Application Overview'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Name: ${_nameController.text}'),
              Text('Father\'s Name: ${_fatherController.text}'),
              Text('Address: ${_addressController.text}'),
              Text('Reason: ${_reasonController.text}'),
              Text('Amount: ${_amountController.text}'),
              Text('Duration: ${_durationController.text}'),
              Text('NID Photo: ${_nidImage != null ? "Attached" : "Not attached"}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit this application?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Yes, Submit'),
            onPressed: () {
              Navigator.pop(context);
              _submitForm();
            },
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _nidImage != null) {
      // TODO: Save application data to backend or state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted!')),
      );
      Navigator.pop(context); // Return to Home after submission
    } else if (_nidImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach NID card photo!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Application')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _fatherController,
                decoration: const InputDecoration(labelText: "Father's Name"),
                validator: (v) => v!.isEmpty ? "Enter father's name" : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Reason for the loan'),
                validator: (v) => v!.isEmpty ? 'Enter reason' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount of loan'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter amount' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (months)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter duration' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickNidImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload NID Photo'),
                  ),
                  const SizedBox(width: 12),
                  _nidImage != null
                      ? const Text('NID Selected', style: TextStyle(color: Colors.green))
                      : const Text('No NID selected', style: TextStyle(color: Colors.red)),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _showOverviewPage,
                  child: const Text('Overview Application Form'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOverviewPage() {
    if (_formKey.currentState!.validate() && _nidImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoanApplicationOverviewPage(
            name: _nameController.text,
            fatherName: _fatherController.text,
            address: _addressController.text,
            reason: _reasonController.text,
            amount: _amountController.text,
            duration: _durationController.text,
            nidImage: _nidImage,
          ),
        ),
      );
    } else if (_nidImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please attach NID card photo!')));
    }
  }
}
