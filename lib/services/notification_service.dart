import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../models/note.dart';

// Background notification handler - يشتغل حتى لو التطبيق مقفول
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('🔔 Background notification tapped: ${notificationResponse.id}');
  // يمكن نضيف navigation للملاحظة هنا لما التطبيق يفتح
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
    if (_initialized) {
      print('🔔 NotificationService already initialized');
      return;
    }

    print('🔔 Initializing NotificationService...');

    // Initialize timezone database
    tz.initializeTimeZones();
    print('🔔 Timezone initialized');

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

    // Initialize the plugin with background handler
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    print('🔔 Plugin initialized');

    _initialized = true;
    print('🔔 ✅ NotificationService initialized successfully');
  }

  /// Handle notification tap (when app is open)
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Foreground notification tapped: ${response.id}');
    // يمكن نضيف هنا navigation للملاحظة لما المستخدم يضغط على الـ notification
    // TODO: Add navigation to note when notification is tapped
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    print('🔔 Checking notification permissions...');

    // Check notification permission
    if (!await Permission.notification.isGranted) {
      print('🔔 Requesting notification permission...');
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        print('🔔 ❌ Notification permission denied');
        return false;
      }
      print('🔔 ✅ Notification permission granted');
    } else {
      print('🔔 ✅ Notification permission already granted');
    }

    // Request exact alarm permission for Android 12+ (CRITICAL for Xiaomi/MIUI)
    print('🔔 Requesting exact alarm permission...');
    final alarmStatus = await Permission.scheduleExactAlarm.request();
    print('🔔 Exact alarm permission status: ${alarmStatus}');

    return true;
  }

  /// Schedule a notification for a note
  Future<void> scheduleNoteReminder({
    required Note note,
    required DateTime scheduledTime,
  }) async {
    print('🔔 NotificationService.scheduleNoteReminder called');
    print('🔔 Note title: ${note.title}');
    print('🔔 Scheduled time: $scheduledTime');

    if (!_initialized) {
      print('🔔 Not initialized, calling initialize()...');
      await initialize();
      print('🔔 Initialize completed');
    }

    // Request permissions first
    print('🔔 Requesting notification permissions...');
    final hasPermission = await requestPermissions();
    print('🔔 Permission granted: $hasPermission');

    if (!hasPermission) {
      print('🔔 ❌ Permission denied, throwing exception');
      throw Exception('Notification permission denied');
    }

    // Generate unique notification ID from note's creation time
    final int notificationId = note.dateCreated.hashCode;
    print('🔔 Notification ID: $notificationId');

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
      // Full-screen intent for Android (يظهر على كامل الشاشة)
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
    print('🔔 TZDateTime scheduled: $scheduledDate');
    print('🔔 Current TZDateTime: ${tz.TZDateTime.now(tz.local)}');

    // Schedule the notification
    print('🔔 Calling zonedSchedule...');
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
    print('🔔 ✅ zonedSchedule completed successfully');

    // Verify it was scheduled
    final pending = await getPendingNotifications();
    print('🔔 Total pending notifications: ${pending.length}');
    for (final p in pending) {
      print('🔔   - ID: ${p.id}, Title: ${p.title}, Body: ${p.body}');
    }
  }

  /// Cancel a scheduled notification for a note
  Future<void> cancelNoteReminder(Note note) async {
    if (!_initialized) {
      await initialize();
    }

    final int notificationId = note.dateCreated.hashCode;
    await _notificationsPlugin.cancel(notificationId);
  }

  /// Show an immediate notification (for testing)
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
