import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppCommonExportButton extends StatelessWidget {
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final String dialogTitle;
  final String buttonLabel;
  final Color buttonColor;
  final IconData buttonIcon;
  final double? height;
  final double? width;

  const AppCommonExportButton({
    super.key,
    required this.onExportExcel,
    required this.onExportPdf,
    this.dialogTitle = 'Export Options',
    this.buttonLabel = 'Export',
    this.buttonColor = AppColors.success,
    this.buttonIcon = Icons.file_download_outlined,
    this.height,
    this.width,
  });

  void _showExportDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogTitle,
                style: AppTextStyle.style_16_600(color: AppColors.black),
              ),
              SizedBox(height: 20.h),
              _buildExportOption(
                icon: Icons.table_chart_outlined,
                label: 'Export to Excel',
                color: Colors.green,
                onTap: () {
                  Get.back();
                  onExportExcel();
                },
              ),
              SizedBox(height: 12.h),
              _buildExportOption(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Export to PDF',
                color: Colors.red,
                onTap: () {
                  Get.back();
                  onExportPdf();
                },
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: AppTextStyle.style_14_600(color: AppColors.grey300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTextStyle.style_14_400(color: AppColors.black),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      tileColor: AppColors.grey50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 36.h,
      width: width,
      child: ElevatedButton.icon(
        onPressed: () => _showExportDialog(context),
        icon: Icon(buttonIcon, size: 16.r),
        label: Text(
          buttonLabel,
          style: AppTextStyle.style_12_600(color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
      ),
    );
  }
}
