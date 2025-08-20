// lib/views/admin_home_screen.dart
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.I.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = AuthService.I.currentAdmin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome, ${admin?.name ?? "Admin"}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('Username: ${admin?.name ?? "-"}'),
              const SizedBox(height: 24),
              const Text('This is the Admin dashboard placeholder.'),
            ],
          ),
        ),
      ),
    );
  }
}
