import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppCommonExportButton extends StatelessWidget {
  final VoidCallback onExportExcel;
  final VoidCallback? onExportPdf;
  final String dialogTitle;
  final Color buttonColor;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Widget? iconWidget;
  final bool isLoading;

  const AppCommonExportButton({
    super.key,
    required this.onExportExcel,
    this.onExportPdf,
    this.dialogTitle = 'Export Options',
    this.buttonColor = const Color(0xFF389D6A),
    this.height,
    this.width,
    this.padding,
    this.iconWidget,
    this.isLoading = false,
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
                iconWidget: Image.asset(
                  AppImages.excelIcon,
                  width: 22.r,
                  height: 22.r,
                ),
                label: 'Export to Excel',
                color: Colors.green,
                onTap: () {
                  Get.back();
                  onExportExcel();
                },
              ),
              if (onExportPdf != null) ...[
                SizedBox(height: 12.h),
                _buildExportOption(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Export to PDF',
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    onExportPdf!();
                  },
                ),
              ],
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
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: iconWidget ?? Icon(icon, color: color),
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
    final defaultGradient = const LinearGradient(
      colors: [
        Color(0xFF217346),
        Color(0xFF145A32),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final btnHeight = height ?? 24.h;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                if (onExportPdf != null) {
                  _showExportDialog(context);
                } else {
                  onExportExcel();
                }
              },
        borderRadius: BorderRadius.circular(4.r),
        child: Container(
          height: btnHeight,
          width: width ?? btnHeight,
          padding: padding ?? EdgeInsets.all(3.r),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: defaultGradient,
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: isLoading
              ? SizedBox(
                  width: 12.r,
                  height: 12.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : (iconWidget ??
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: Image.asset(
                      AppImages.excelIcon,
                      width: 18.r,
                      height: 18.r,
                      fit: BoxFit.contain,
                    ),
                  )),
        ),
      ),
    );
  }
}
