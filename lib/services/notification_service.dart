import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../models/note.dart';

// Background notification handler
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle background notification tap
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _initialized = true;
  }

  /// Handle notification tap (when app is open)
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Add navigation to note when notification is tapped
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    // Check notification permission
    if (!await Permission.notification.isGranted) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        return false;
      }
    }

    // Request exact alarm permission for Android 12+
    await Permission.scheduleExactAlarm.request();

    return true;
  }

  /// Schedule a notification for a note
  Future<void> scheduleNoteReminder({
    required Note note,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Request permissions first
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Notification permission denied');
    }

    // Generate unique notification ID from note's creation time
    final int notificationId = note.dateCreated.hashCode;

    // Notification details for Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'note_reminders',
      'Note Reminders',
      channelDescription: 'Notifications for note reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
    );

    // Notification details for iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // Schedule the notification
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      note.title ?? 'Reminder',
      note.content ?? 'You have a note reminder',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: note.dateCreated.toString(),
    );
  }

  /// Cancel a scheduled notification for a note
  Future<void> cancelNoteReminder(Note note) async {
    if (!_initialized) {
      await initialize();
    }

    final int notificationId = note.dateCreated.hashCode;
    await _notificationsPlugin.cancel(notificationId);
  }

  /// Show an immediate notification
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'note_reminders',
      'Note Reminders',
      channelDescription: 'Notifications for note reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}