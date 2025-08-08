import 'package:flutter/material.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const MicroLoanApp());
}

class MicroLoanApp extends StatelessWidget {
  const MicroLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro Loan Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}