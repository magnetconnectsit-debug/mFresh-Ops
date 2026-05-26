import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';

import 'widgets/home_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          AppCommonToastMessage.show(
            message: "Please press back again to close",
            type: ToastType.info,
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppCommonAppBar(
          title: Text(
            'mFresh Ops',
            style: AppTextStyle.style_14_700(color: AppColors.black),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              icon: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 22.r,
              ),
            ),
          ],
          showAppDrawer: true,
          hasBackButton: false,
          elevation: 0,
        ),
        drawer: const CommonSidebar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Management Hub',
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    SizedBox(height: 12.h),
                    const HomeGrid(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
