import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_pages.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';
import 'package:services/repositories/support_repository.dart';
import 'package:dev/views/widgets/floating_logger_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const OpsApp());
}

Future<void> initServices() async {
  // 1. Initialize LoggerService (No dependencies)
  Get.put(LoggerService());

  // 2. Initialize StorageService (Hive-based)
  await Get.putAsync(() => StorageService().init());

  // 3. Initialize SettingsService (Depends on StorageService)
  Get.put(SettingsService());

  // 4. Initialize DioClient (Depends on StorageService & LoggerService)
  await Get.putAsync(() => DioClient().init());

  // 5. Initialize API Service
  Get.put(ApiService());

  // 6. Initialize Repositories
  Get.put(AuthRepository());
  Get.put(UserRepository());
  Get.put(CommonRepository());
  Get.put(SupportRepository());
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
          primaryColor: Colors.orange,
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
