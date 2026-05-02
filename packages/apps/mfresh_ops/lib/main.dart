import 'package:core/constants/app_colors.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/user.dart';
import 'package:mfresh_ops/core/env/env.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_pages.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/user_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/data/repositories/task_repository.dart';
import 'package:dev/views/widgets/floating_logger_button.dart';

import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await initServices();
  runApp(const OpsApp());
}

Future<void> initServices() async {
  // Initialize LoggerService (No dependencies)
  Get.put(LoggerService());

  // Initialize StorageService (Hive-based)
  final storageService = await Get.putAsync(() => StorageService().init());
  
  final String envName = AppConfig.envName;
  final String activeUrl = AppConfig.baseUrl;
  debugPrint('🚀 [mfresh_ops] Initializing in $envName mode');
  debugPrint('🔗 [mfresh_ops] Active API: $activeUrl');

  if (storageService.getBaseUrl().isEmpty) {
    await storageService.saveBaseUrl(activeUrl);
  }

  // Initialize SettingsService (Depends on StorageService)
  Get.put(SettingsService());

  // Initialize DioClient (Depends on StorageService & LoggerService)
  await Get.putAsync(() => DioClient().init(publicPaths: [AppConstants.login]));

  // Initialize API Service
  Get.put(ApiService());

  // Initialize Repositories
  Get.put(AuthRepository());
  Get.put(UserRepository());
  Get.put(CommonRepository());
  Get.put(SupportRepository());
  Get.put(TaskRepository());
}


class OpsApp extends StatelessWidget {
  const OpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'mFresh Ops',
        theme: ThemeData(
          primaryColor: AppColors.primary,
        ),
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              const FloatingLoggerButton(),
            ],
          );
        },
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}
