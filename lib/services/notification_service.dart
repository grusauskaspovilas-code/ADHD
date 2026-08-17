import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();

  //
  // Užduotis, kurią reikia atidaryti
  // paspaudus Guardian pranešimą.
  //
  static String? pendingTaskId;

  //
  // Callback, naudojamas tada, kai
  // programėlė jau veikia.
  //
  static void Function(String taskId)?
      onTaskNotificationTapped;

  static Future<void> scheduleGuardianReminder({
    required int id,
    required String taskId,
    required String taskTitle,
    required DateTime scheduledAt,
  }) async {
    final now = DateTime.now();

    if (!scheduledAt.isAfter(now)) {
      return;
    }

    const androidDetails =
        AndroidNotificationDetails(
      'guardian_required_tasks',
      'Guardian',
      channelDescription:
          'Important task deadline reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    final scheduledTime =
        tz.TZDateTime.from(
      scheduledAt,
      tz.local,
    );

    await _notifications.zonedSchedule(
      id,
      'Guardian',
      'Laikas pradėti: $taskTitle',
      scheduledTime,
      details,
      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
      payload: taskId,
    );
  }

  static Future<void> cancelGuardianReminder({
    required int id,
  }) async {
    await _notifications.cancel(id);
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings =
        InitializationSettings(
      android: androidSettings,
    );

    //
    // Paspaudimas, kai Flutter aplikacija
    // jau paleista / yra fone.
    //
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        final taskId =
            response.payload?.trim();

        if (taskId == null ||
            taskId.isEmpty) {
          return;
        }

        final callback =
            onTaskNotificationTapped;

        if (callback != null) {
          callback(taskId);
        } else {
          //
          // Navigatorius dar neparuoštas.
          //
          pendingTaskId = taskId;
        }
      },
    );

    //
    // Patikriname, ar programėlė buvo
    // paleista būtent paspaudus notification.
    //
    final launchDetails =
        await _notifications
            .getNotificationAppLaunchDetails();

    if (launchDetails
            ?.didNotificationLaunchApp ==
        true) {
      final taskId =
          launchDetails
              ?.notificationResponse
              ?.payload
              ?.trim();

      if (taskId != null &&
          taskId.isNotEmpty) {
        pendingTaskId = taskId;
      }
    }

    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final android =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await android
        ?.requestNotificationsPermission();
  }

  //
  // Momentinis testinis pranešimas.
  //
  static Future<void>
      showTestNotification() async {
    const androidDetails =
        AndroidNotificationDetails(
      'guardian_test',
      'Guardian test',
      channelDescription:
          'Guardian test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1001,
      'Guardian',
      'Bandomasis Guardian pranešimas veikia.',
      details,
    );
  }

  //
  // Testinis pranešimas po 2 minučių.
  //
  static Future<void>
      scheduleTestNotification() async {
    const androidDetails =
        AndroidNotificationDetails(
      'guardian_scheduled',
      'Guardian reminders',
      channelDescription:
          'Important Guardian reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details =
        NotificationDetails(
      android: androidDetails,
    );

    final scheduledTime =
        tz.TZDateTime.now(
      tz.local,
    ).add(
      const Duration(
        minutes: 2,
      ),
    );

    await _notifications.zonedSchedule(
      2001,
      'Guardian',
      'Suplanuotas Guardian pranešimas veikia.',
      scheduledTime,
      details,
      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
    );
  }
}