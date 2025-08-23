// lib/views/admin_home_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart'; // use the casing that exists in your project
import '../services/api_client.dart';
import 'admin_user_loans_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<UserModel> _users = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.I.dio.get(
        '/users/users/all/',
        options: Options(validateStatus: (s) => s != null && s >= 200 && s < 600),
      );
      if (res.statusCode == 200 && res.data is List) {
        final list = (res.data as List).cast<Map>().cast<Map<String, dynamic>>();
        final users = list.map((j) => UserModel.fromJson(j)).toList();
        users.sort((a, b) => a.name.compareTo(b.name));
        setState(() => _users = users);
      } else {
        setState(() => _error = 'Failed to load users (HTTP ${res.statusCode})');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _fetchUsers,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/admin_login'); // logout to admin login
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _users.length,
                  itemBuilder: (_, i) {
                    final u = _users[i];
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminUserLoansScreen(
                            userId: u.userId,
                            userName: u.name,
                          ),
                        ),
                      ),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                u.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Phone: ${u.phone}'),
                              const SizedBox(height: 6),
                              Text('Balance: ${u.balance} BDT'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
