// region Imports
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';

import 'package:core/constants/app_colors.dart';
import 'package:core/routes/app_routes.dart';
import 'package:models/notification/app_notification.dart';
import 'package:mfresh/modules/notification/controllers/notification_controller.dart';
import 'package:mfresh/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:services/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
// endregion

// region Background Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("🔔 Background Notification Data: ${message.data}");

  try {
    if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
    }
    
    await Hive.initFlutter();
    final Box<dynamic> notificationBox = await Hive.openBox<dynamic>(
      'notifications_box',
    );

    if (message.notification != null) {
      final newNotif = AppNotification(
        id:
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification!.title ?? 'New Activity',
        body: message.notification!.body ?? '',
        timestamp: DateTime.now(),
        payload: message.data,
        type: 'info',
        isRead: false,
      );

      await notificationBox.put(newNotif.id, newNotif.toJson());
      debugPrint("✅ Background Notification Saved to Hive: ${newNotif.title}");
    }
    await notificationBox.close();
  } catch (e) {
    debugPrint("❌ Background Save Error: $e");
  }
}
// endregion

// region NotificationService
class NotificationService extends GetxService {
  // region Properties
  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static int? pendingTabIndex;
  static String? pendingDetailRoute;
  static dynamic pendingDetailArguments;
  static bool skipSplashRedirect = false;

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  // endregion

  // region Initialization
  Future<NotificationService> init() async {
    if (Firebase.apps.isEmpty) {
        debugPrint("NotificationService: Firebase not initialized, skipping setup.");
        return this;
    }

    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      await _setupLocalNotifications();
      await _setupFCMListeners();
      await _syncTokenWithServer();
    }

    return this;
  }

  // endregion

  // region Token Sync Logic
  Future<void> _syncTokenWithServer() async {
    if (_messaging == null) return;
    try {
      String? token = await _messaging!.getToken();
      if (token != null) _sendTokenToBackend(token);

      _messaging!.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken);
      });
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }
  }

  void _sendTokenToBackend(String token) {
    debugPrint("FCM Token: $token");
  }

  // endregion

  // region Local Notification Setup
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = json.decode(response.payload!);
            handleNavigationPayload(data);
          } catch (e) {
            debugPrint("Error parsing notification payload: $e");
          }
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  // endregion

  // region Listeners
  Future<void> _setupFCMListeners() async {
    if (_messaging == null) return;
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
        "🔔 Foreground Notification Received. Payload: ${message.data}",
      );
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _addNotificationToController(message);

        if (android != null) {
          String? imageUrl =
              message.data['image'] ?? message.data['big_picture'];

          BigPictureStyleInformation? bigPictureStyleInformation;
          BigTextStyleInformation? bigTextStyleInformation;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            try {
              final String bigPicturePath = await _downloadAndSaveFile(
                imageUrl,
                'bigPicture-${notification.hashCode}',
              );
              bigPictureStyleInformation = BigPictureStyleInformation(
                FilePathAndroidBitmap(bigPicturePath),
                largeIcon: FilePathAndroidBitmap(bigPicturePath),
                contentTitle: notification.title,
                htmlFormatContentTitle: true,
                summaryText: notification.body,
                htmlFormatSummaryText: true,
              );
            } catch (e) {
              debugPrint("❌ Failed to download notification image: $e");
            }
          }

          // Fallback to BigText if no image or download failed
          if (bigPictureStyleInformation == null) {
            bigTextStyleInformation = BigTextStyleInformation(
              notification.body ?? '',
              htmlFormatBigText: true,
              contentTitle: notification.title,
              htmlFormatContentTitle: true,
            );
          }

          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: '@mipmap/ic_launcher',
                color: AppColors.primary,
                styleInformation:
                    bigPictureStyleInformation ?? bigTextStyleInformation,
              ),
            ),
            payload: json.encode(message.data),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked from background!");
      debugPrint(
        "🔔 Notification Clicked (Background). Payload: ${message.data}",
      );
      skipSplashRedirect = true;
      _addNotificationToController(message);
      handleNavigationPayload(message.data);
    });

    final RemoteMessage? initialMessage = await _messaging!.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        "📲 NotificationService: App launched by notification (terminated). Payload: ${initialMessage.data}",
      );

      final String? routeName = _getRouteFromData(initialMessage.data);
      final int targetIndex = calculateTargetIndex(initialMessage.data);

      pendingTabIndex = targetIndex;

      if (_getTabIndexIfPrimary(routeName ?? '') == null && routeName != null) {
        pendingDetailRoute = routeName;
        pendingDetailArguments = initialMessage.data;
        debugPrint("💾 Initializing with Pending Detail Route: $routeName");
      } else {
        debugPrint("💾 Initializing with Tab: $targetIndex");
      }
    } else {
      pendingTabIndex = null;
      pendingDetailRoute = null;
      pendingDetailArguments = null;
    }
  }

  // endregion

  // region Private Helper Methods
  void _addNotificationToController(RemoteMessage message) {
    debugPrint("🔔 NotificationController Add. Payload: ${message.data}");
    final notifController = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    if (message.notification != null) {
      notifController.addNotification(
        message.notification!.title ?? 'New Activity',
        message.notification!.body ?? '',
        data: message.data,
      );
    }
  }

  @visibleForTesting
  int calculateTargetIndex(Map<String, dynamic> data) {
    // Determine route from payload
    String? route = (data['screen'] ?? data['route_name'])?.toString();

    if (route == null || route == "None" || route == "null") {
      debugPrint("⚠️ No valid route found in payload -> Defaulting to Index 0");
      return 0;
    }

    // Normalize route for comparison
    route = route.replaceAll('_', '-');
    if (!route.startsWith('/')) {
      route = '/$route';
    }

    debugPrint("🔍 Calculating Target Index for Route: $route");

    // Flexible matching for Tab Routes
    if (route.startsWith('/profile')) {
      return 3;
    }

    return 0;
  }

  // endregion

  // region File Handler
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/$fileName';
    final dio.Response response = await dio.Dio().get(
      url,
      options: dio.Options(responseType: dio.ResponseType.bytes),
    );
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

  // endregion

  // region Navigation Logic
  Future<void> handleNavigationPayload(
    Map<String, dynamic> data, {
    StorageService? storageService,
  }) async {
    try {
      final storage =
          storageService ??
          (Get.isRegistered<StorageService>()
              ? Get.find<StorageService>()
              : null);

      if (storage == null) {
        debugPrint(
          "⚠️ StorageService not found. Navigation might fail if too early.",
        );
        return;
      }

      // Ensure user is logged in before attempting navigation
      final token = storage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("🚫 User not logged in. Redirecting to login.");
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final String? routeName = _getRouteFromData(data);

      if (routeName != null && routeName.isNotEmpty) {
        debugPrint("🚀 Attempting Route Navigation to: $routeName");

        // Set skip flag so splash doesn't override our navigation
        skipSplashRedirect = true;

        try {
          // Identify Target Tab
          final int targetTabIndex = calculateTargetIndex(data);

          // Decide if we need a full reset or just a push
          final currentRoute = Get.currentRoute;
          debugPrint("📍 Current Route: $currentRoute");

          if (currentRoute == routeName &&
              routeName != AppRoutes.dashboard &&
              routeName != '/') {
            debugPrint("↳ Already on target route. Replacing it to refresh.");
            skipSplashRedirect = false;
            await Get.offNamed(
              routeName,
              arguments: data,
              preventDuplicates: false,
            );
            return;
          }

          if (currentRoute != AppRoutes.dashboard) {
            debugPrint("↳ Resetting stack to Dashboard on tab $targetTabIndex");
            await Get.offAllNamed(
              AppRoutes.dashboard,
              arguments: targetTabIndex,
            );
            // Smaller delay is enough if already transition
            await Future.delayed(const Duration(milliseconds: 300));
          } else {
            // Already on dashboard, just switch tab
            if (Get.isRegistered<DashboardController>()) {
              Get.find<DashboardController>().onTabTapped(targetTabIndex);
            }
          }

          // Handle Detailed navigation if not a primary tab
          final bool isPrimary = _getTabIndexIfPrimary(routeName) != null;
          if (!isPrimary) {
            debugPrint("↳ Pushing Detailed Route: $routeName");
            await Get.toNamed(routeName, arguments: data);
          }
        } catch (e) {
          debugPrint("❌ Navigation payload error: $e");
        }
      } else {
        // No screen info, just go to dashboard on correct tab based on 'type' or logic
        final int targetTabIndex = calculateTargetIndex(data);
        debugPrint(
          "🚀 No Route identified. Defaulting to Dashboard Index: $targetTabIndex",
        );
        Get.offAllNamed(AppRoutes.dashboard, arguments: targetTabIndex);
      }
    } finally {
      // Clear flag after a delay
      Future.delayed(const Duration(seconds: 2), () {
        skipSplashRedirect = false;
        debugPrint("🧹 skipSplashRedirect reset to false");
      });
    }
  }

  String? _getRouteFromData(Map<String, dynamic> data) {
    String? screen = (data['screen'] ?? data['route_name'])?.toString();
    if (screen == null || screen == "None" || screen == "null") return null;

    // Normalize underscores to hyphens
    String normalized = screen.toLowerCase().replaceAll('_', '-');
    if (!normalized.startsWith('/')) normalized = '/$normalized';

    debugPrint("🔍 Mapping screen '$screen' (normalized: '$normalized')");

    return normalized;
  }

  int? _getTabIndexIfPrimary(String routeName) {
    if (routeName == AppRoutes.home || routeName == '/') return 0;
    if (routeName == AppRoutes.profile || routeName == '/profile') return 3;
    return null;
  }

  // endregion
}









