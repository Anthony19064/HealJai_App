import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings);

      // ขอ permission notification
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      print('✅ NotificationService initialized');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      rethrow;
    }
  }

  // ฟังก์ชันตรวจสอบและขอ Exact Alarm Permission
  static Future<bool> checkAndRequestExactAlarmPermission() async {
    final androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      // ตรวจสอบว่ามี permission หรือยัง
      final canScheduleExactAlarms =
          await androidImplementation.canScheduleExactNotifications();

      print('🔍 Can schedule exact alarms: $canScheduleExactAlarms');

      if (canScheduleExactAlarms == false) {
        print('⚠️ Requesting exact alarm permission...');
        // เปิดหน้าตั้งค่าให้ user อนุญาต
        await androidImplementation.requestExactAlarmsPermission();

        // ตรวจสอบอีกครั้งหลังจาก user กลับมา
        final granted =
            await androidImplementation.canScheduleExactNotifications();
        print('✅ Permission granted after request: $granted');
        return granted ?? false;
      }
      return canScheduleExactAlarms ?? false;
    }
    return false;
  }

  // ฟังก์ชันคำนวณเวลา 8:00 น.
  static tz.TZDateTime _nextInstanceOfMorning() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // ฟังก์ชันคำนวณเวลา 12:00 น.
  static tz.TZDateTime _nextInstanceOfNoon() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      12,
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // ฟังก์ชันคำนวณเวลา 18:00 น.
  static tz.TZDateTime _nextInstanceOfEvening() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // ฟังก์ชันแจ้งเตือนเช้า
  static Future<void> scheduleMorningNotification() async {
    try {
      final hasPermission = await checkAndRequestExactAlarmPermission();

      const androidDetails = AndroidNotificationDetails(
        'morning_channel_id',
        'แจ้งเตือนเช้า',
        channelDescription: 'แจ้งเตือนประจำวัน เวลา 8:00 น.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        100, // ID ต่างจาก 100
        'มอนิ่งค้าบบ',
        'ขอให้วันนี้เป็นที่ดีอีกวันนะ :) สู้ๆนะ !!',
        _nextInstanceOfMorning(),
        platformChannelSpecifics,
        androidScheduleMode:
            hasPermission
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Morning notification scheduled at 8:00 AM');
    } catch (e) {
      print('❌ Error scheduling morning notification: $e');
    }
  }

  //ฟังก์ชันแจ้งเเตือนเที่ยง
  static Future<void> scheduleNoonNotification() async {
    try {
      final hasPermission = await checkAndRequestExactAlarmPermission();

      const androidDetails = AndroidNotificationDetails(
        'noon_channel_id',
        'แจ้งเตือนเที่ยง',
        channelDescription: 'แจ้งเตือนประจำวัน เวลา 12:00 น.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        101,
        'เที่ยงแล้ววววว',
        'อย่าลืมพักกินข้าวเติมพลังด้วยน้าา เหลืออีกแค่ครึงวันนะ สู้ๆ ฮึ้บ',
        _nextInstanceOfNoon(),
        platformChannelSpecifics,
        androidScheduleMode:
            hasPermission
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Noon notification scheduled at 8:00 AM');
    } catch (e) {
      print('❌ Error scheduling Noon notification: $e');
    }
  }

  // ฟังก์ชันแจ้งเตือนตอนเย็น
  static Future<void> scheduleEveningNotification() async {
    try {
      final hasPermission = await checkAndRequestExactAlarmPermission();

      const androidDetails = AndroidNotificationDetails(
        'eveing_channel_id',
        'แจ้งเตือนเย็น',
        channelDescription: 'แจ้งเตือนประจำวัน เวลา 18:00 น.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        102,
        'กลับบ้านยังค้าบบ',
        'วันนี้เป็นไงบ้าง เหนื่อยรึป่าว ถ้าเหนื่อยก็อย่าลืมพักผ่อนนะะ :)',
        _nextInstanceOfEvening(),
        platformChannelSpecifics,
        androidScheduleMode:
            hasPermission
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Evening notification scheduled at 18:00 AM');
    } catch (e) {
      print('❌ Error scheduling Evening notification: $e');
    }
  }

  //ฟังก์ชันเรียกแจ้งเตือนทั้งหมด
  static Future<void> scheduleAllDailyNotifications() async {
    await scheduleMorningNotification(); // 8:00 น.
    await scheduleNoonNotification(); // 12:00 น.
    await scheduleEveningNotification(); // 18:00 น.
    print('✅ All daily notifications scheduled!');
  }
}
