class NotificationService {
  // In production: Firebase Cloud Messaging
  final List<Map<String, dynamic>> _sentNotifications = [];

  List<Map<String, dynamic>> get sentNotifications => List.unmodifiable(_sentNotifications);

  /// Sends a "¡Llegó Lana!" push notification when a Bre-B transfer completes.
  Future<void> sendBrebCompletionNotification({
    required String recipientPhone,
    required String senderName,
    required double amountCop,
    required String brebRef,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final notification = {
      'to': recipientPhone,
      'title': '💰 ¡Llegó Lana!',
      'body': '$senderName te envió \$${amountCop.toStringAsFixed(0)} COP.',
      'data': {
        'type': 'BREB_RECEIVED',
        'brebRef': brebRef,
        'amount': amountCop,
      },
      'sentAt': DateTime.now().toIso8601String(),
    };

    _sentNotifications.add(notification);
    // In production: FirebaseMessaging.instance.sendMessage(...)
  }

  /// Sends a generic notification.
  Future<void> sendNotification({
    required String to,
    required String title,
    required String body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sentNotifications.add({
      'to': to, 'title': title, 'body': body,
      'sentAt': DateTime.now().toIso8601String(),
    });
  }
}
