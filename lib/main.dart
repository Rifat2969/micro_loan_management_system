// lib/main.dart
import 'package:flutter/material.dart';

import 'services/api_client.dart';
import 'views/RegisterScreen.dart';
import 'views/admin_home_screen.dart';
import 'views/admin_login_screen.dart';
import 'views/login_screen.dart';
import 'views/register_success_screen.dart';
import 'views/role_select_screen.dart';
import 'views/user_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.I.init();
  runApp(const MicroLoanApp());
}

class MicroLoanApp extends StatelessWidget {
  const MicroLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro Loan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),

      // 👉 Start at the role selection screen
      initialRoute: '/role',

      routes: {
        '/role': (_) => const RoleSelectScreen(),
        '/login': (_) => const LoginScreen(), // user login
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(), // user home
        '/admin_login': (_) => const AdminLoginScreen(), // admin login
        '/admin_home': (_) => const AdminHomeScreen(), // admin home (if you want a named route)
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/register_success') {
          final args = (settings.arguments as Map?) ?? const {};
          final name = (args['name'] as String?) ?? '';
          final phone = (args['phone'] as String?) ?? '';
          return MaterialPageRoute(
            builder: (_) => RegisterSuccessScreen(name: name, phone: phone),
          );
        }
        return null;
      },
    );
  }
}
