import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
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
  static void Function(String taskId)? onTaskNotificationTapped;

  static Future<void> scheduleGuardianReminder({
    required int id,
    required String taskId,
    required String message,
    required DateTime scheduledAt,
  }) async {
    final now = DateTime.now();

    if (!scheduledAt.isAfter(now)) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'guardian_required_tasks',
      'Guardian',
      channelDescription: 'Important task deadline reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledTime = tz.TZDateTime.from(scheduledAt, tz.local);

    await _notifications.zonedSchedule(
      id,
      'Guardian',
      message,
      scheduledTime,
      details,
      androidScheduleMode: await _androidScheduleMode(),
      payload: taskId,
    );
  }

  static Future<void> cancelGuardianReminder({required int id}) async {
    await _notifications.cancel(id);
  }

  static Future<void> showGuardianWarning({
    required int id,
    required String taskId,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'guardian_risk_warnings',
      'Guardian warnings',
      channelDescription:
          'Warnings about important tasks at risk of missing their deadline',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      id,
      'Guardian',
      message,
      details,
      payload: taskId,
    );
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    //
    // Paspaudimas, kai Flutter aplikacija
    // jau paleista / yra fone.
    //
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final taskId = response.payload?.trim();

        if (taskId == null || taskId.isEmpty) {
          return;
        }

        final callback = onTaskNotificationTapped;

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
    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      final taskId = launchDetails?.notificationResponse?.payload?.trim();

      if (taskId != null && taskId.isNotEmpty) {
        pendingTaskId = taskId;
      }
    }

    await _requestNotificationPermissions();
  }

  static Future<void> _configureLocalTimezone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      // Jei įrenginio laiko juostos nustatyti
      // nepavyksta, timezone paketo UTC
      // numatytoji reikšmė lieka saugi atsarga.
    }
  }

  static Future<void> _requestNotificationPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.requestNotificationsPermission();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> requestGuardianPermissions() async {
    try {
      await _requestNotificationPermissions();

      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (await android?.canScheduleExactNotifications() == false) {
        await android?.requestExactAlarmsPermission();
      }
    } catch (_) {
      // Leidimo klaida neturi sutrukdyti išsaugoti užduoties. Tokiu atveju
      // priminimas bus suplanuotas apytiksliu Android režimu.
    }
  }

  static Future<AndroidScheduleMode> _androidScheduleMode() async {
    try {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (await android?.canScheduleExactNotifications() == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    } catch (_) {
      // Ne Android platformoje arba nepavykus patikrinti naudojame atsargą.
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  //
  // Momentinis testinis pranešimas.
  //
  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'guardian_test',
      'Guardian test',
      channelDescription: 'Guardian test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
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
  static Future<void> scheduleTestNotification() async {
    await requestGuardianPermissions();

    const androidDetails = AndroidNotificationDetails(
      'guardian_scheduled',
      'Guardian reminders',
      channelDescription: 'Important Guardian reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(minutes: 2));

    await _notifications.zonedSchedule(
      2001,
      'Guardian',
      'Suplanuotas Guardian pranešimas veikia.',
      scheduledTime,
      details,
      androidScheduleMode: await _androidScheduleMode(),
    );
  }
}
