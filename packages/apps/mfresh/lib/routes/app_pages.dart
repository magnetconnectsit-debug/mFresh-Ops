import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/authentication/views/login_screen.dart';
import 'package:mfresh/modules/authentication/views/signup_screen.dart';
import 'package:mfresh/modules/booking/views/booking_confirmed_screen.dart';
import 'package:mfresh/modules/booking/views/booking_history_screen.dart';
import 'package:mfresh/modules/dashboard/views/dashboard_screen.dart';
import 'package:mfresh/modules/service_details/views/service_details_screen.dart';
import 'package:mfresh/modules/qr_scanner/qr_scanner_screen.dart';
import 'package:core/routes/app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const LoginScreen(),
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
      page: () => const Scaffold(body: Center(child: Text('Profile'))),
    ),
    GetPage(
      name: AppRoutes.logViewer,
      page: () => const Scaffold(body: Center(child: Text('Log Viewer'))),
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
  ];
}









