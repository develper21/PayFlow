import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:payflow/shared/models/boleto_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
    log('NotificationService initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermission() async {
    final androidPermission = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosPermission = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return androidPermission ?? iosPermission ?? false;
  }

  Future<void> scheduleBillReminder(BoletoModel boleto) async {
    if (!_isInitialized) await init();

    try {
      final dueDate = _parseDate(boleto.dueDate);
      if (dueDate == null) {
        log('Invalid due date for bill: ${boleto.name}');
        return;
      }

      // Schedule reminder for 1 day before due date at 9 AM
      final reminderTime = dueDate.subtract(const Duration(days: 1));
      final scheduledDate = DateTime(
        reminderTime.year,
        reminderTime.month,
        reminderTime.day,
        9, // 9 AM
        0,
      );

      // Don't schedule if reminder time has already passed
      if (scheduledDate.isBefore(DateTime.now())) {
        log('Reminder time already passed for: ${boleto.name}');
        return;
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        boleto.hashCode, // Use bill hash as notification ID
        'Bill Due Tomorrow!',
        '${boleto.name} - \$${_formatValue(boleto.value)}',
        tzScheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'bill_reminders',
            'Bill Reminders',
            channelDescription: 'Notifications for upcoming bill due dates',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              'Your bill "${boleto.name}" for \$${_formatValue(boleto.value)} is due tomorrow (${boleto.dueDate}). Don\'t forget to pay!',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: boleto.barcode,
      );

      log('Scheduled reminder for ${boleto.name} at $scheduledDate');
    } catch (e, stackTrace) {
      log('Error scheduling notification: $e');
      log('Stack trace: $stackTrace');
    }
  }

  Future<void> cancelBillReminder(BoletoModel boleto) async {
    await _notifications.cancel(boleto.hashCode);
    log('Cancelled reminder for ${boleto.name}');
  }

  Future<void> scheduleAllReminders(List<BoletoModel> boletos) async {
    for (final boleto in boletos) {
      await scheduleBillReminder(boleto);
    }
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    log('Cancelled all reminders');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Expected format: DD/MM/YYYY
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      log('Error parsing date: $dateStr - $e');
      return null;
    }
  }

  String _formatValue(double value) {
    return value.toStringAsFixed(2);
  }
}
