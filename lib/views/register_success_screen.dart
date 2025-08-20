import 'package:flutter/material.dart';

class RegisterSuccessScreen extends StatelessWidget {
  final String name;
  final String phone;
  const RegisterSuccessScreen({super.key, required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, color: Colors.green, size: 96),
                const SizedBox(height: 24),
                Text('Congratulations, $name! 🎉',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text('Your account has been successfully created.', textAlign: TextAlign.center),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login', arguments: {'phone': phone}),
                  child: const Text('Continue to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
