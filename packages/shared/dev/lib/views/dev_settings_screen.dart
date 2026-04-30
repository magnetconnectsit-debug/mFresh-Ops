import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:dev/controllers/dev_settings_controller.dart';

class DevSettingsScreen extends GetView<DevSettingsController> {
  const DevSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppCommonAppBar(title: Text('Developer Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Configuration',
              style: AppTextStyle.style_16_700(color: AppColors.black),
            ),
            SizedBox(height: 16.h),
            AppCommonTextField(
              controller: controller.baseUrlController,
              titleText: 'Base URL',
              hintText: 'https://api.example.com',
            ),
            SizedBox(height: 24.h),
            Text(
              'Debug Tools',
              style: AppTextStyle.style_16_700(color: AppColors.black),
            ),
            SizedBox(height: 8.h),
            _buildToggleTile(
              'Show Floating Logger',
              'Displays a floating button to view logs',
              Icons.bug_report_outlined,
            ),
            SizedBox(height: 16.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.list_alt_rounded, color: Colors.blue),
              ),
              title: Text('View Session Logs', style: AppTextStyle.style_14_600(color: AppColors.black)),
              subtitle: Text('Review network and system logs', style: AppTextStyle.style_12_400(color: AppColors.grey300)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: controller.goToLogViewer,
            ),
            SizedBox(height: 40.h),
            AppCommonButton(
              text: 'Save & Restart App',
              onPressed: controller.saveSettingsAndRestart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(String title, String sub, IconData icon) {
    return Obx(() => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyle.style_14_600(color: AppColors.black)),
      subtitle: Text(sub, style: AppTextStyle.style_12_400(color: AppColors.grey300)),
      value: controller.settingsService.showLogger.value,
      onChanged: controller.toggleLogger,
      activeThumbColor: AppColors.primary,
    ));
  }
}
