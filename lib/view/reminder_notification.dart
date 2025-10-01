import 'dart:async';
import 'dart:developer' as lg;
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../../core/db_helper.dart'; // Import DatabaseHelper
import 'package:flutter/material.dart'; // Added for navigation context

// Global navigator key for handling navigation in background/foreground handlers
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Top-level function for background notification handling
@pragma('vm:entry-point')
void backgroundNotificationHandler(NotificationResponse response) async {
  try {
    lg.log(
      'ReminderNotification: Background notification received, payload: ${response.payload}',
      time: DateTime.now(),
    );
    if (response.payload != null &&
        response.payload!.startsWith('lead_reminder_')) {
      final leadId = int.tryParse(response.payload!.split('_').last);
      if (leadId != null) {
        // Store leadId or perform lightweight processing
        // Note: Heavy operations like database initialization should be deferred to app startup
        lg.log(
          'ReminderNotification: Background handler processed leadId: $leadId',
          time: DateTime.now(),
        );
        // Navigation can be handled after app resumes (see main.dart setup)
      }
    }
    lg.log(
      'ReminderNotification: Background handler executed successfully',
      time: DateTime.now(),
    );
  } catch (e, stackTrace) {
    lg.log(
      'ReminderNotification: Error in background notification handler: $e',
      time: DateTime.now(),
    );
    lg.log(
      'ReminderNotification: Stack trace: $stackTrace',
      time: DateTime.now(),
    );
  }
}

class ReminderNotification {
  static final ReminderNotification _instance =
      ReminderNotification._internal();
  factory ReminderNotification() => _instance;
  ReminderNotification._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Store scheduled notifications
  final Map<int, tz.TZDateTime> _scheduledNotifications = {};

  // Callback for remaining time updates
  Function(int id, Duration remainingTime)? onTimerUpdate;

  // Timer for updating remaining time
  Timer? _timer;

  Future<void> init() async {
    lg.log(
      'ReminderNotification: Initializing notifications',
      time: DateTime.now(),
    );
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      lg.log(
        'ReminderNotification: Timezone initialized to Asia/Kolkata',
        time: DateTime.now(),
      );
    } catch (e) {
      lg.log(
        'ReminderNotification: Error initializing timezone: $e',
        time: DateTime.now(),
      );
      tz.setLocalLocation(tz.getLocation('UTC')); // Fallback to UTC
      lg.log(
        'ReminderNotification: Fallback to UTC timezone',
        time: DateTime.now(),
      );
    }

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    // Create Android notification channel without sound
    if (Platform.isAndroid) {
      final androidPlugin =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          'lead_reminder_channel',
          'Lead Reminders',
          description: 'Channel for lead reminder notifications',
          importance: Importance.max,
          playSound: false,
          showBadge: true,
          audioAttributesUsage: AudioAttributesUsage.notificationEvent,
        ),
      );
      lg.log(
        'ReminderNotification: Android notification channel created: lead_reminder_channel, no sound',
        time: DateTime.now(),
      );
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        lg.log(
          'ReminderNotification: Notification tapped in foreground, payload: ${response.payload}, ID: ${response.id}',
          time: DateTime.now(),
        );
        if (response.payload != null &&
            response.payload!.startsWith('lead_reminder_')) {
          final leadId = int.tryParse(response.payload!.split('_').last);
          if (leadId != null) {
            // Navigate to lead details screen
            navigatorKey.currentState?.pushNamed(
              '/lead_details',
              arguments: {'leadId': leadId},
            );
            lg.log(
              'ReminderNotification: Navigating to lead details for leadId: $leadId',
              time: DateTime.now(),
            );
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
    );
    lg.log(
      'ReminderNotification: Notification initialization successful',
      time: DateTime.now(),
    );

    if (Platform.isAndroid) {
      await requestNotificationPermission();
      await requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      await requestIOSNotificationPermission();
    }

    // Clean old/orphaned notifications on init
    await cancelAllNotifications();
    lg.log(
      'ReminderNotification: Cleared old notifications on init',
      time: DateTime.now(),
    );

    // Reschedule all existing reminders on app start
    final prefs = await SharedPreferences.getInstance();
    final String? globalReminderOption = prefs.getString(
      'global_reminder_option',
    );
    await scheduleRemindersForAllBookings(globalReminderOption);
    lg.log(
      'ReminderNotification: Rescheduled all reminders with option: $globalReminderOption on app start',
      time: DateTime.now(),
    );

    // Log initial pending notifications
    final pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    lg.log(
      'ReminderNotification: Initial pending notifications: ${pendingNotifications.map((n) => "ID: ${n.id}, Payload: ${n.payload}").toList()}',
      time: DateTime.now(),
    );

    _startTimer();
    lg.log(
      'ReminderNotification: Initialization completed',
      time: DateTime.now(),
    );
  }

  Future<bool> requestNotificationPermission() async {
    try {
      final androidPlugin =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final granted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
      lg.log(
        'ReminderNotification: Notification permission request result (Android): $granted',
        time: DateTime.now(),
      );
      return granted;
    } catch (e) {
      lg.log(
        'ReminderNotification: Error requesting notification permission (Android): $e',
        time: DateTime.now(),
      );
      return false;
    }
  }

  Future<bool> requestIOSNotificationPermission() async {
    try {
      final iosPlugin =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      final granted =
          await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      lg.log(
        'ReminderNotification: Notification permission request result (iOS): $granted',
        time: DateTime.now(),
      );
      return granted;
    } catch (e) {
      lg.log(
        'ReminderNotification: Error requesting notification permission (iOS): $e',
        time: DateTime.now(),
      );
      return false;
    }
  }

  Future<bool> requestExactAlarmsPermission() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      lg.log(
        'ReminderNotification: Android SDK version: $sdkInt',
        time: DateTime.now(),
      );

      if (sdkInt >= 31) {
        final androidPlugin =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        final canScheduleExact =
            await androidPlugin?.canScheduleExactNotifications() ?? false;
        lg.log(
          'ReminderNotification: Can schedule exact alarms: $canScheduleExact',
          time: DateTime.now(),
        );
        if (!canScheduleExact) {
          await androidPlugin?.requestExactAlarmsPermission();
          final updatedStatus =
              await androidPlugin?.canScheduleExactNotifications() ?? false;
          lg.log(
            'ReminderNotification: Exact alarm permission request result: $updatedStatus',
            time: DateTime.now(),
          );
          return updatedStatus;
        }
        return canScheduleExact;
      }
      return true;
    } catch (e) {
      lg.log(
        'ReminderNotification: Error checking/requesting exact alarm permission: $e',
        time: DateTime.now(),
      );
      return false;
    }
  }

  // Helper method to parse time string (supports both 12-hour and 24-hour formats)
  DateTime _parseTimeString(String timeString, DateTime date) {
    try {
      // Try 24-hour format (HH:mm) first
      try {
        final format = DateFormat('HH:mm');
        final parsedTime = format.parse(timeString);
        return DateTime(
          date.year,
          date.month,
          date.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } catch (_) {
        // Fallback to 12-hour format (h:mm a)
        final format = DateFormat('h:mm a');
        final parsedTime = format.parse(timeString);
        return DateTime(
          date.year,
          date.month,
          date.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      }
    } catch (e) {
      lg.log(
        'ReminderNotification: Error parsing time string "$timeString": $e',
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      lg.log(
        'ReminderNotification: Scheduling notification with ID: $id, Title: $title, Body: $body, ScheduledDate: $scheduledDate',
        time: DateTime.now(),
      );

      final now = DateTime.now();
      if (scheduledDate.isBefore(now.add(const Duration(seconds: 10)))) {
        lg.log(
          'ReminderNotification: Error: Scheduled date ($scheduledDate) is too close to current time ($now) for ID: $id',
          time: DateTime.now(),
        );
        throw Exception(
          'Scheduled date must be at least 10 seconds in the future.',
        );
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      lg.log(
        'ReminderNotification: Converted to TZ Scheduled Date: $tzScheduledDate for ID: $id',
        time: DateTime.now(),
      );

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'lead_reminder_channel',
            'Lead Reminders',
            channelDescription: 'Channel for lead reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            playSound: false,
            audioAttributesUsage: AudioAttributesUsage.notificationEvent,
          );

      final DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      final canScheduleExact = await requestExactAlarmsPermission();
      final androidScheduleMode =
          canScheduleExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexact;
      lg.log(
        'ReminderNotification: Using schedule mode: $androidScheduleMode for ID: $id',
        time: DateTime.now(),
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: 'lead_reminder_$id',
      );

      // Store the scheduled notification
      _scheduledNotifications[id] = tzScheduledDate;
      lg.log(
        'ReminderNotification: Notification scheduled successfully for $tzScheduledDate (ID: $id)',
        time: DateTime.now(),
      );

      // Start or restart the timer after scheduling
      _startTimer();

      // Log pending notifications
      final pendingNotifications =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      if (pendingNotifications.any((notification) => notification.id == id)) {
        lg.log(
          'ReminderNotification: Notification with ID=$id is pending with payload: ${pendingNotifications.firstWhere((n) => n.id == id).payload}',
          time: DateTime.now(),
        );
      } else {
        lg.log(
          'ReminderNotification: No pending notification found with ID=$id. Scheduling may have failed.',
          time: DateTime.now(),
        );
      }
    } catch (e, stackTrace) {
      lg.log(
        'ReminderNotification: ERROR during scheduling for ID: $id: $e',
        time: DateTime.now(),
      );
      lg.log(
        'ReminderNotification: Stack trace: $stackTrace',
        time: DateTime.now(),
      );
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      lg.log(
        'ReminderNotification: Showing immediate notification: ID=$id, Title=$title, Body=$body',
        time: DateTime.now(),
      );

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'lead_reminder_channel',
            'Lead Reminders',
            channelDescription: 'Channel for lead reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            playSound: false,
            audioAttributesUsage: AudioAttributesUsage.notificationEvent,
          );

      final DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: 'lead_reminder_$id',
      );
      lg.log(
        'ReminderNotification: Immediate notification shown: ID=$id',
        time: DateTime.now(),
      );
    } catch (e) {
      lg.log(
        'ReminderNotification: Error showing immediate notification for ID: $id: $e',
        time: DateTime.now(),
      );
    }
  }

  // Start a timer to periodically update remaining time
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
    lg.log(
      'ReminderNotification: Timer started for remaining time updates',
      time: DateTime.now(),
    );
  }

  // Update remaining time for all scheduled notifications
  void _updateRemainingTime() {
    final now = tz.TZDateTime.now(tz.local);
    List<int> toRemove = [];
    _scheduledNotifications.forEach((id, scheduledDate) {
      if (scheduledDate.isAfter(now)) {
        final remainingTime = scheduledDate.difference(now);
        if (onTimerUpdate != null) {
          onTimerUpdate!(id, remainingTime);
        }
        lg.log(
          'ReminderNotification: Notification ID=$id: ${remainingTime.inHours}h ${remainingTime.inMinutes % 60}m ${remainingTime.inSeconds % 60}s remaining',
          time: DateTime.now(),
        );
      } else {
        toRemove.add(id);
      }
    });
    for (var id in toRemove) {
      _scheduledNotifications.remove(id);
      lg.log(
        'ReminderNotification: Notification ID=$id has triggered or passed and is removed from tracking',
        time: DateTime.now(),
      );
    }

    if (_scheduledNotifications.isEmpty) {
      _timer?.cancel();
      lg.log(
        'ReminderNotification: No scheduled notifications left; timer stopped',
        time: DateTime.now(),
      );
    }
  }

  // Get remaining time for a specific notification
  Duration? getRemainingTime(int id) {
    if (_scheduledNotifications.containsKey(id)) {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = _scheduledNotifications[id]!;
      if (scheduledDate.isAfter(now)) {
        return scheduledDate.difference(now);
      } else {
        _scheduledNotifications.remove(id);
        lg.log(
          'ReminderNotification: Notification ID=$id has passed and is removed from tracking',
          time: DateTime.now(),
        );
        return null;
      }
    }
    return null;
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      _scheduledNotifications.remove(id);
      lg.log(
        'ReminderNotification: Notification ID=$id canceled',
        time: DateTime.now(),
      );
    } catch (e) {
      lg.log(
        'ReminderNotification: Error canceling notification for ID: $id: $e',
        time: DateTime.now(),
      );
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      _scheduledNotifications.clear();
      _timer?.cancel();
      lg.log(
        'ReminderNotification: All notifications canceled',
        time: DateTime.now(),
      );
    } catch (e) {
      lg.log(
        'ReminderNotification: Error canceling all notifications: $e',
        time: DateTime.now(),
      );
    }
  }

  // Schedule reminders for all leads with a specific reminder option
  Future<void> scheduleRemindersForAllBookings(String? reminderOption) async {
    try {
      lg.log(
        'ReminderNotification: Scheduling reminders for all bookings with option: $reminderOption',
        time: DateTime.now(),
      );
      final reminders = await DatabaseHelper.instance.getReminders();
      if (reminders.isEmpty) {
        lg.log(
          'ReminderNotification: No reminders found in database',
          time: DateTime.now(),
        );
        return;
      }

      if (reminderOption == "Don't remind") {
        for (var reminder in reminders) {
          final String leadId = reminder['lead_id']?.toString() ?? '';
          if (leadId.isNotEmpty) {
            await cancelNotification(int.parse(leadId));
            lg.log(
              'ReminderNotification: Cancelled notification for lead ID: $leadId due to "Don\'t remind"',
              time: DateTime.now(),
            );
          }
        }
        lg.log(
          'ReminderNotification: All notifications cancelled due to "Don\'t remind"',
          time: DateTime.now(),
        );
        return;
      }

      Duration reminderDuration;
      bool useDefault = reminderOption == null || reminderOption.isEmpty;
      if (useDefault) {
        reminderDuration = const Duration(minutes: 30);
        lg.log(
          'ReminderNotification: Using default reminder duration: 30 minutes',
          time: DateTime.now(),
        );
      } else {
        switch (reminderOption) {
          case '15 mins':
            reminderDuration = const Duration(minutes: 15);
            break;
          case '30 mins':
            reminderDuration = const Duration(minutes: 30);
            break;
          case '45 mins':
            reminderDuration = const Duration(minutes: 45);
            break;
          case '60 mins':
            reminderDuration = const Duration(minutes: 60);
            break;
          case '1 mins':
            reminderDuration = const Duration(minutes: 1);
            break;
          default:
            reminderDuration = const Duration(minutes: 30);
            useDefault = true;
            lg.log(
              'ReminderNotification: Invalid reminder option "$reminderOption", falling back to default 30 minutes',
              time: DateTime.now(),
            );
        }
        lg.log(
          'ReminderNotification: Global reminder option: $reminderOption',
          time: DateTime.now(),
        );
      }

      final DateTime now = DateTime.now();
      final DateFormat dateFormatIndian = DateFormat('dd-MM-yyyy');
      final DateFormat dateFormatISO = DateFormat('yyyy-MM-dd');

      for (var reminder in reminders) {
        try {
          final String leadId = reminder['lead_id']?.toString() ?? '';
          final String leadName = reminder['lead_name']?.toString() ?? 'Lead';
          final String reminderDateString =
              reminder['reminder_date']?.toString() ?? '';
          final String reminderTimeString =
              reminder['reminder_time']?.toString() ?? '';
          lg.log(
            'ReminderNotification: Processing lead ID: $leadId, name: $leadName, date: "$reminderDateString", time: "$reminderTimeString"',
            time: DateTime.now(),
          );

          if (leadId.isEmpty ||
              reminderDateString.isEmpty ||
              reminderTimeString.isEmpty) {
            lg.log(
              'ReminderNotification: Skipping lead with invalid data (ID: $leadId, date: "$reminderDateString", time: "$reminderTimeString")',
              time: DateTime.now(),
            );
            continue;
          }

          // Parse date
          DateTime followUpDate;
          if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(reminderDateString)) {
            followUpDate = dateFormatIndian.parseStrict(reminderDateString);
            lg.log(
              'ReminderNotification: Parsed followUpDate (dd-MM-yyyy): $followUpDate for lead ID: $leadId',
              time: DateTime.now(),
            );
          } else if (RegExp(
            r'^\d{4}-\d{2}-\d{2}$',
          ).hasMatch(reminderDateString)) {
            followUpDate = dateFormatISO.parseStrict(reminderDateString);
            lg.log(
              'ReminderNotification: Parsed followUpDate (yyyy-MM-dd): $followUpDate for lead ID: $leadId',
              time: DateTime.now(),
            );
          } else {
            lg.log(
              'ReminderNotification: Invalid date format "$reminderDateString" for lead ID: $leadId, skipping',
              time: DateTime.now(),
            );
            continue;
          }

          // Validate year
          if (followUpDate.year < 2020) {
            lg.log(
              'ReminderNotification: Parsed year ${followUpDate.year} is too early for lead ID: $leadId, skipping',
              time: DateTime.now(),
            );
            continue;
          }

          // Parse time
          final DateTime followUpTimeParsed = _parseTimeString(
            reminderTimeString,
            followUpDate,
          );
          lg.log(
            'ReminderNotification: Parsed followUpTime: ${followUpTimeParsed.hour}:${followUpTimeParsed.minute.toString().padLeft(2, '0')} for lead ID: $leadId',
            time: DateTime.now(),
          );

          // Combine date and time for follow-up
          final DateTime followUpDateTime = DateTime(
            followUpDate.year,
            followUpDate.month,
            followUpDate.day,
            followUpTimeParsed.hour,
            followUpTimeParsed.minute,
          );
          lg.log(
            'ReminderNotification: Combined followUpDateTime: $followUpDateTime for lead ID: $leadId',
            time: DateTime.now(),
          );

          // Validate if followUpDateTime is in the future
          if (followUpDateTime.isBefore(now)) {
            lg.log(
              'ReminderNotification: Follow-up time $followUpDateTime is in the past for lead ID: $leadId, skipping',
              time: DateTime.now(),
            );
            continue;
          }

          // Calculate reminder time
          final DateTime reminderTime = followUpDateTime.subtract(
            reminderDuration,
          );
          lg.log(
            'ReminderNotification: Calculated reminder time: $reminderTime for lead ID: $leadId',
            time: DateTime.now(),
          );

          // Check if reminder time is in the future
          if (reminderTime.isBefore(now)) {
            lg.log(
              'ReminderNotification: Reminder time $reminderTime is in the past for lead ID: $leadId, skipping notification',
              time: DateTime.now(),
            );
            continue;
          }

          final Duration timeUntilNotification = reminderTime.difference(now);
          lg.log(
            'ReminderNotification: Time remaining to trigger notification: ${timeUntilNotification.inMinutes} minutes (${timeUntilNotification.inSeconds} seconds) for lead ID: $leadId at trigger time: $reminderTime',
            time: DateTime.now(),
          );

          // Cancel existing and schedule new
          await cancelNotification(int.parse(leadId));
          lg.log(
            'ReminderNotification: Cancelled existing notification for lead ID: $leadId',
            time: DateTime.now(),
          );

          final String reminderType = useDefault ? 'default' : 'custom';
          await scheduleNotification(
            id: int.parse(leadId),
            title: 'Reminder: Follow-up with $leadName',
            body:
                'Your follow-up is in ${useDefault ? '30 minutes' : reminderOption} ($reminderType). Scheduled for $reminderDateString at $reminderTimeString.',
            scheduledDate: reminderTime,
          );
          lg.log(
            'ReminderNotification: Successfully scheduled $reminderType notification for lead ID: $leadId at $reminderTime',
            time: DateTime.now(),
          );
        } catch (e, stackTrace) {
          lg.log(
            'ReminderNotification: Error processing lead: $e',
            time: DateTime.now(),
          );
          lg.log(
            'ReminderNotification: Stack trace: $stackTrace',
            time: DateTime.now(),
          );
        }
      }
    } catch (e, stackTrace) {
      lg.log(
        'ReminderNotification: Error in scheduleRemindersForAllBookings: $e',
        time: DateTime.now(),
      );
      lg.log(
        'ReminderNotification: Stack trace: $stackTrace',
        time: DateTime.now(),
      );
    }
  }
}
