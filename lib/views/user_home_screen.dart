// lib/views/user_home_screen.dart
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'loan_application_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  bool _loading = false;
  DateTime? _lastRefreshed;

  @override
  void initState() {
    super.initState();
    // Optionally refresh once when opening Home
    _refreshBalance(silent: true);
  }

  Future<void> _refreshBalance({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      await AuthService.I.refreshCurrentUser();
      _lastRefreshed = DateTime.now();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh failed: $e')),
        );
      }
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.I.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroLoan App'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/role'); // goes back to role select
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications'); // your notification screen
            },
          ),
          IconButton(
            tooltip: 'Refresh balance',
            icon: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _refreshBalance(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshBalance(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Welcome, ${user?.name ?? "User"}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text('Your Balance:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '${user?.balance ?? 0} BDT',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_fmtDateTime(_lastRefreshed)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 36),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to loan form; when returning, refresh in case a new app was created
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoanApplicationForm()),
                  );
                  if (mounted) _refreshBalance(silent: true);
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
