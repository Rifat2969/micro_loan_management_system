import 'dart:io';

import 'package:flutter/material.dart';

import 'application_submitted_page.dart';

class LoanApplicationOverviewPage extends StatelessWidget {
  final String name;
  final String fatherName;
  final String address;
  final String reason;
  final String amount;
  final String duration;
  final File? nidImage;

  const LoanApplicationOverviewPage({
    super.key,
    required this.name,
    required this.fatherName,
    required this.address,
    required this.reason,
    required this.amount,
    required this.duration,
    required this.nidImage,
  });

  @override
  Widget build(BuildContext context) {
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

I am $name, son/daughter of $fatherName, residing at $address.
I am writing to apply for a loan of BDT $amount for a duration of $duration month(s).
The reason for seeking this loan is as follows:
$reason

I have attached my NID card along with this application for your kind consideration.

I sincerely hope that you will look into my request and grant me the required loan. If you need any further information, please let me know.

Thank you for your time and consideration.

Yours faithfully,

$name
''',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("NID Card Attachment:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            nidImage != null
                ? Center(child: Image.file(nidImage!, height: 100))
                : const Text("No NID image attached.", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Edit"),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirm Submission"),
                        content: const Text("Are you sure you want to submit this application?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), // Closes the dialog
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Closes the dialog

                              // Replace the current overview page with the success page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ApplicationSubmittedPage(),
                                ),
                              );
                            },
                            child: const Text("Submit"),
                          ),
                        ],
                      ),
                    );
                  },
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
