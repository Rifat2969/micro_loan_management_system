import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'loan_application_form.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.I.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.I.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroLoan App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') _logout(context);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ListView(
          children: [
            Text(
              'Welcome, ${user?.name ?? "User"}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if ((user?.phone ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Phone: ${user!.phone}', style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 30),
            const Text('Your Balance:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('0 BDT', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoanApplicationForm()),
                  );
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
