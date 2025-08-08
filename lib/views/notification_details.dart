import 'package:flutter/material.dart';

import '../models/app_notification.dart';

class NotificationDetail extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetail({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(notification.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 70),
            const SizedBox(height: 30),
            Text(
              notification.details,
              style: const TextStyle(fontSize: 20, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              "Received: ${notification.timestamp}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
