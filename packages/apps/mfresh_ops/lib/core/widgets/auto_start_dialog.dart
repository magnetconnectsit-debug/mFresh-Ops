import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoStartDialog extends StatelessWidget {
  const AutoStartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings_applications,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Background Tracking',
              style: AppTextStyle.style_18_600(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your phone restricts background apps. To keep location tracking active, please tap "Take me there" and ensure the Auto-Start or Background Execution switch is ON for mFresh Ops.',
              style: AppTextStyle.style_14_400(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Get.back(result: true);
                      try {
                        await getAutoStartPermission();
                      } catch (e) {
                        debugPrint('Failed to open auto-start settings: $e');
                      }
                    },
                    child: Text(
                      'Take me there',
                      style: AppTextStyle.style_14_600(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
