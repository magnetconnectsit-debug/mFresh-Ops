import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';

class AppCommonMediaSource {
  static void show({
    required VoidCallback onTakePhoto,
    required VoidCallback onChoosePhoto,
    required VoidCallback onRecordVideo,
    required VoidCallback onChooseVideo,
  }) {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Select Media Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildOption(
              icon: Icons.camera_alt_outlined,
              title: 'Take a Photo',
              onTap: () {
                Get.back();
                onTakePhoto();
              },
            ),
            _buildOption(
              icon: Icons.photo_library_outlined,
              title: 'Choose Photo from Gallery',
              onTap: () {
                Get.back();
                onChoosePhoto();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            ),
            _buildOption(
              icon: Icons.videocam_outlined,
              title: 'Record a Video',
              onTap: () {
                Get.back();
                onRecordVideo();
              },
            ),
            _buildOption(
              icon: Icons.video_library_outlined,
              title: 'Choose Video from Gallery',
              onTap: () {
                Get.back();
                onChooseVideo();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.black87,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onTap: onTap,
    );
  }
}
