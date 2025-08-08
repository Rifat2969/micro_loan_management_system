import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'loan_application_form.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroLoan App'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Profile page or dialog (to be implemented)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user?.name ?? "User"}!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 30),
            const Text('Your Balance:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('0 BDT', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanApplicationForm()));
                },
                child: const Text('Apply for Loan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
