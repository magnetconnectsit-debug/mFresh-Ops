import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart';
import 'package:intl/intl.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class DepositsTable extends StatelessWidget {
  const DepositsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositsController>();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          if (controller.isLoading.value) {
            return SizedBox(
              width: 320.w,
              height: 100.h,
              child: const Center(child: CustomAppLoader()),
            );
          }

          if (controller.filteredDeposits.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Text('No deposits found', style: AppTextStyle.style_14_400(color: AppColors.grey500)),
            );
          }

          return Table(
            columnWidths: const {
              0: FixedColumnWidth(50),
              1: FixedColumnWidth(75),
              2: FixedColumnWidth(55),
              3: FixedColumnWidth(55),
              4: FixedColumnWidth(130),
              5: FixedColumnWidth(75),
            },
            border: TableBorder(
              horizontalInside: BorderSide(color: AppColors.borderColor, width: 1.0),
              verticalInside: BorderSide(color: AppColors.borderColor, width: 1.0),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8F9FA)), // Light gray header
                children: [
                  _buildHeaderCell('Date', padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h)),
                  _buildHeaderCell('Deposit'),
                  _buildHeaderCell('Month'),
                  _buildHeaderCell('File', padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h)),
                  _buildHeaderCell('Remark'),
                  _buildHeaderCell('Action'),
                ],
              ),
              ...controller.filteredDeposits.map((item) {
                final isExpanded = controller.expandedRowId.value == item.id;
                return TableRow(
                  children: [
                    _buildRowGestureDetector(item.id, _buildDataCell(item.date, isExpanded, padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h)), controller),
                    _buildRowGestureDetector(item.id, _buildDataCell(currencyFormat.format(item.deposit), isExpanded), controller),
                    _buildRowGestureDetector(item.id, _buildDataCell(_formatMonth(item.month), isExpanded), controller),
                    _buildImageCell(context, item.fileUrl),
                    _buildRowGestureDetector(item.id, _buildDataCell(item.remark, isExpanded), controller),
                    _buildActionCell(context, item, controller),
                  ],
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRowGestureDetector(int id, Widget child, DepositsController controller) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.toggleRowExpansion(id),
      child: child,
    );
  }

  Widget _buildHeaderCell(String text, {EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Text(
        text,
        style: AppTextStyle.style_10_600(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text, bool isExpanded, {EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      child: Text(
        text,
        style: AppTextStyle.style_10_400(color: AppColors.black),
        maxLines: isExpanded ? null : 2,
        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImageCell(BuildContext context, String? fileUrl) {
    bool isValidUrl = false;
    bool isPdf = false;
    if (fileUrl != null && fileUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(fileUrl);
        isValidUrl = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
        isPdf = uri.path.toLowerCase().endsWith('.pdf');
      } catch (_) {}
    }

    final bool hasFile = fileUrl != null && isValidUrl;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
      child: GestureDetector(
        onTap: () async {
          if (hasFile) {
            if (isPdf) {
              try {
                await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
              } catch (e) {
                Get.snackbar('Error', 'Could not open PDF file');
              }
            } else {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: InteractiveViewer(
                    child: AppImageView(
                      imageUrl: fileUrl,
                      errorWidget: Container(
                        padding: EdgeInsets.all(20.r),
                        child: const Center(
                          child: Text('Failed to load image preview'),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        },
        child: !hasFile
            ? Container(
                height: 40.r,
                width: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Icon(Icons.image_not_supported_outlined, size: 20.r, color: AppColors.grey500),
              )
            : isPdf
                ? Container(
                    height: 40.r,
                    width: 40.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEECEB),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: const Color(0xFFFCC5C1)),
                    ),
                    child: Icon(Icons.picture_as_pdf, size: 22.r, color: AppColors.red),
                  )
                : AppImageView(
                    imageUrl: fileUrl,
                    width: 40.r,
                    height: 40.r,
                    borderRadius: 4.r,
                    fit: BoxFit.cover,
                    memCacheWidth: 100,
                    memCacheHeight: 100,
                    errorWidget: Icon(Icons.broken_image, size: 20.r, color: AppColors.grey500),
                  ),
      ),
    );
  }

  Widget _buildActionCell(BuildContext context, DepositItem item, DepositsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.createDeposit, arguments: item);
            },
            child: Icon(Icons.edit_outlined, size: 20.r, color: AppColors.grey500),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Deposit'),
                  content: const Text('Are you sure you want to delete this cash deposit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.deleteDepositItem(item.id);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: Icon(Icons.delete_outline, size: 20.r, color: Colors.red.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  String _formatMonth(String monthStr) {
    try {
      final parsed = DateFormat('yyyy-MM').parse(monthStr);
      return DateFormat('MMM yyyy').format(parsed);
    } catch (_) {
      return monthStr;
    }
  }
}
