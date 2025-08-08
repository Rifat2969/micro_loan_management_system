import 'package:flutter/material.dart';

class ApplicationSubmittedPage extends StatelessWidget {
  const ApplicationSubmittedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_rounded, size: 90, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                "Application Submitted!",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Thank you for applying for a loan.\nWait for the bank’s response.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Go to Home"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
