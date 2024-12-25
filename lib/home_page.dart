import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> checkAndRequestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      const channel = MethodChannel('flutter_local_notifications_plugin');
      try {
        final isPermissionNeeded = await channel.invokeMethod<bool>('isExactAlarmPermissionNeeded') ?? false;

        if (isPermissionNeeded) {
          // Request permission for exact alarms
          await channel.invokeMethod('requestExactAlarmPermission');
        }
      } catch (e) {
        print('Error while checking or requesting exact alarm permission: $e');
      }
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid && (await isExactAlarmPermissionNeeded())) {
      try {
        const channel = MethodChannel('flutter_local_notifications_plugin');
        await channel.invokeMethod('requestExactAlarmPermission');
      } catch (e) {
        print('Error requesting exact alarm permission: $e');
      }
    }
  }

  Future<bool> isExactAlarmPermissionNeeded() async {
    const channel = MethodChannel('flutter_local_notifications_plugin');
    try {
      final result = await channel.invokeMethod<bool>('isExactAlarmPermissionNeeded');
      return result ?? false;
    } catch (e) {
      print('Error checking exact alarm permission: $e');
      return false;
    }
  }
  Future<void> scheduleNotification() async {

    await checkAndRequestExactAlarmPermission();


    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel', // Channel ID
      'Scheduled Notifications', // Channel name
      channelDescription: 'This channel is for scheduled notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Scheduled Notification', // Title
      'This is a test notification!', // Body
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)), // Schedule time
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Notifications'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            scheduleNotification();
          },
          child: Text('Schedule Notification'),
        ),
      ),
    );
  }
}