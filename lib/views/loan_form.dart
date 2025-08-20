// lib/views/loan_form.dart
import 'package:flutter/material.dart';

import 'loan_application_form.dart';

/// Legacy wrapper so old routes using LoanForm still work.
/// All real logic lives in LoanApplicationForm.
class LoanForm extends StatelessWidget {
  const LoanForm({super.key});

  @override
  Widget build(BuildContext context) {
    return LoanApplicationForm();
  }
}
