import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import 'notification_details.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo notification list
    final List<AppNotification> notifications = [
      AppNotification(
        id: '1',
        title: 'Loan Approved',
        subtitle: 'Your loan has been approved!',
        details: 'Congratulations! Your loan application is granted. You will receive your money shortly.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: '2',
        title: 'Document Verified',
        subtitle: 'Your documents have been verified.',
        details: 'Your NID and address documents were successfully verified by our admin.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: '3',
        title: 'Loan Application Submitted',
        subtitle: 'Your loan application was received.',
        details: 'Thank you for submitting your application. We will review and notify you soon.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: Text(notification.title),
            subtitle: Text(notification.subtitle),
            trailing: Text(
              "${notification.timestamp.hour.toString().padLeft(2, '0')}:${notification.timestamp.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationDetail(notification: notification),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
