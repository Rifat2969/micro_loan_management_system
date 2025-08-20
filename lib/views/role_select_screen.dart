// lib/views/role_select_screen.dart
import 'package:flutter/material.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 96),
                  const SizedBox(height: 16),
                  Text('Login as', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('User'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/admin_login'),
                    child: const Text('Admin'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
