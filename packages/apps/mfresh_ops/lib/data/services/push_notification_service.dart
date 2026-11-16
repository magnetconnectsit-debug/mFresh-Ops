import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class PushNotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription = 'This channel is used for important notifications.';

  static const String dutyChannelId = 'duty_status_channel';
  static const String dutyChannelName = 'Duty Status Alerts';
  static const String dutyChannelDescription = 'Shows popup notifications when starting or stopping duty.';

  @override
  void onInit() {
    super.onInit();
    _initLocalNotifications();
    _setupForegroundMessageListener();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For iOS foreground notifications
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('PushNotificationService: Notification clicked with payload: ${response.payload}');
      },
    );

    // Create the channel for Android
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    // Create the duty status channel with max importance for heads-up popup
    final AndroidNotificationChannel dutyChannel = AndroidNotificationChannel(
      dutyChannelId,
      dutyChannelName,
      description: dutyChannelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await androidPlugin?.createNotificationChannel(dutyChannel);
    
    // Request Android 13+ Notification Permission
    try {
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {}
        
    // Required to show heads up notifications in foreground for iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('PushNotificationService: Got a foreground message! ${message.messageId}');
      
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDescription,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('PushNotificationService: App opened from notification: ${message.messageId}');
    });
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotificationsPlugin.show(
      id: title.hashCode ^ body.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          dutyChannelId,
          dutyChannelName,
          channelDescription: dutyChannelDescription,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
