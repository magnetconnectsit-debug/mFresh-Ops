import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:dev/views/widgets/floating_logger_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mfresh/core/config/app_config.dart';
import 'package:mfresh/core/constants/app_constants.dart';
import 'package:mfresh/data/models/user.dart';
import 'package:mfresh/data/repositories/auth_repository.dart';
import 'package:mfresh/data/repositories/common_repository.dart';
import 'package:mfresh/data/repositories/user_repository.dart';
import 'package:mfresh/routes/app_pages.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:mfresh/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:services/api_services.dart';
import 'package:services/app_update_service.dart';
import 'package:services/connectivity_service.dart';
import 'package:services/dio_client.dart';
import 'package:services/error_handler.dart';
import 'package:services/log_service.dart';
import 'package:services/phonepe_service.dart';
import 'package:services/plutus_service.dart';
import 'package:services/remote_config_service.dart';
import 'package:services/settings_service.dart';
import 'package:services/storage_service.dart';
// endregion

// region Background Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Background Init Error: $e");
  }
  debugPrint("Handling a background message: ${message.messageId}");
}
// endregion

// region Service Initialization
Future<void> initServices() async {
  debugPrint('Initializing services...');

  try {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM TOKEN: $token");
    } catch (e) {
      debugPrint("Firebase/Messaging not available: $e");
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint(
      "Ensure google-services.json is present in android/app/ and plugins are configured.",
    );
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Get.putAsync(() => StorageService().init());
  Get.put(SettingsService());
  final StorageService storageService = Get.find<StorageService>();

  final String envName = AppConfig.envName;
  final String activeUrl = AppConfig.baseUrl;
  debugPrint('🚀 [mfresh] Initializing in $envName mode');
  debugPrint('🔗 [mfresh] Active API: $activeUrl');

  final RemoteConfigService remoteConfigService = await Get.putAsync(
        () => RemoteConfigService().init(defaultBaseUrl: activeUrl),
  );

  final String fetchedBaseUrl = AppConfig.isDev
      ? AppConfig.baseUrl
      : remoteConfigService.getBaseUrl();

  await storageService.saveBaseUrl(fetchedBaseUrl);

  Get.put(LoggerService());
  Get.put(ErrorHandler());
  Get.put(ConnectivityService());

  await Get.putAsync(
        () =>
        DioClient().init(
          publicPaths: [
            AppConstants.login,
            AppConstants.sendOtp,
            AppConstants.verifyOtp,
          ],
        ),
  );

  Get.put(ApiService());
  Get.put(AuthRepository());
  Get.put(UserRepository());
  Get.put(CommonRepository());
  Get.put(PlutusService());
  PhonePeService.init(isProduction: AppConfig.isPhonePeProduction);
  Get.put(PhonePeService());
  await Get.putAsync(() => NotificationService().init());
  Get.put(AppUpdateService());

  try {
    Pdfrx.getCacheDirectory = () async {
      final dir = await getTemporaryDirectory();
      return '${dir.path}/pdfrx_cache';
    };
  } catch (e) {
    debugPrint("Error initializing Pdfrx: $e");
  }

  debugPrint('All services initialized.');
}
// endregion

// region Main Entry
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await initServices();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return AppCommonErrorWidget(details: details);
  };

  runApp(const MyApp());
}
// endregion

// region MyApp Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Set design size based on screen width
        // For large POS/Desktop screens (width > 600), use a tablet-optimized design size
        final Size designSize = constraints.maxWidth > 600
            ? const Size(1024, 768)
            : const Size(360, 690);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            final SettingsService settings = Get.find<SettingsService>();

            return Directionality(
              textDirection: TextDirection.ltr,
              child: Obx(
                    () =>
                    Stack(
                      children: [
                        GetMaterialApp(
                          title: 'mFresh',
                          debugShowCheckedModeBanner: false,
                          theme: ThemeData(
                            primaryColor: AppColors.primary,
                            scaffoldBackgroundColor: AppColors.white,
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: AppColors.primary,
                              brightness: Brightness.light,
                            ),
                            appBarTheme: AppBarTheme(
                              elevation: 0,
                              backgroundColor: AppColors.white,
                              surfaceTintColor: AppColors.transparent,
                              iconTheme: const IconThemeData(
                                color: AppColors.black1,
                              ),
                              titleTextStyle: AppTextStyle.style_18_600(
                                color: AppColors.black1,
                              ),
                            ),
                          ),
                          initialRoute: AppRoutes.initial,
                          getPages: AppPages.routes,
                          defaultTransition: Transition.cupertino,
                        ),
                        if (settings.showLogger.value ||
                            settings.isDevMode.value ||
                            kDebugMode)
                          const FloatingLoggerButton(),
                      ],
                    ),
              ),
            );
          },
        );
      },
    );
  }
}
// endregion

// region Stubs for missing classes
class AppCommonErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const AppCommonErrorWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Error: ${details.exception}')));
  }
}

// endregion
