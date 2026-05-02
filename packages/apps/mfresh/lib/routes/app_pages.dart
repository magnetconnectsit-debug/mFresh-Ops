import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/authentication/views/login_screen.dart';
import 'package:mfresh/modules/authentication/views/signup_screen.dart';
import 'package:mfresh/modules/booking/views/booking_confirmed_screen.dart';
import 'package:mfresh/modules/booking/views/booking_history_screen.dart';
import 'package:mfresh/modules/dashboard/views/dashboard_screen.dart';
import 'package:mfresh/modules/service_details/views/service_details_screen.dart';
import 'package:mfresh/modules/qr_scanner/qr_scanner_screen.dart';
import 'package:mfresh/modules/splash/views/splash_screen.dart';
import 'package:mfresh/modules/profile/views/profile_screen.dart';
import 'package:mfresh/views/web_view_page.dart';
import 'package:mfresh/routes/app_routes.dart';

import 'package:dev/routes/dev_pages.dart';

class AppPages {
  static final routes = [
    ...DevPages.routes,
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const Scaffold(body: Center(child: Text('Home'))),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingHistory,
      page: () => const BookingHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingConfirmed,
      page: () => const BookingConfirmedScreen(),
    ),
    GetPage(
      name: AppRoutes.serviceDetails,
      page: () => const ServiceDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.qrScanner,
      page: () => const QRScannerScreen(),
    ),
    GetPage(
      name: AppRoutes.webView,
      page: () => WebViewPage(),
    ),
  ];
}









