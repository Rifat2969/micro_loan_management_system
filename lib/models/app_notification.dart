class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final String details;
  final DateTime timestamp;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.timestamp,
    this.read = false,
  });
}
