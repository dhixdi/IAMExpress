import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';

class NotificationService {
  static Future<void> showStatusUpdate({
    required String resi,
    required String newStatus,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'status_channel',
      'Status Paket',
      channelDescription: 'Notifikasi perubahan status paket',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      resi.hashCode,
      'Status Paket Diperbarui',
      'Paket $resi → $newStatus',
      details,
    );
  }
}
