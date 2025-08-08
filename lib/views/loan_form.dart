import 'package:flutter/material.dart';
import '../models/loan_model.dart';

class LoanForm extends StatefulWidget {
  const LoanForm({super.key});

  @override
  State<LoanForm> createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  double amount = 0;
  int term = 0;
  String documents = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loan Application")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (val) => name = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Term (months)"),
                keyboardType: TextInputType.number,
                onChanged: (val) => term = int.tryParse(val) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Documents Info"),
                onChanged: (val) => documents = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final app = LoanApplication(
                    name: name,
                    amount: amount,
                    term: term,
                    documents: documents,
                  );
                  print("Loan submitted: \${app.name} - \${app.amount} Tk");
                  Navigator.pop(context);
                },
                child: const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}