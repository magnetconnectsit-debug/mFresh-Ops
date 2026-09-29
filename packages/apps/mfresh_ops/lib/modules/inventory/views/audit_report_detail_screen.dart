import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/audit_report_controller.dart';

import 'widgets/audit_report_detail_table.dart';
import 'widgets/audit_table_widget.dart' show openFullScreenImageViewer;

class AuditReportDetailScreen extends StatefulWidget {
  final int? auditId;

  const AuditReportDetailScreen({super.key, this.auditId});

  @override
  State<AuditReportDetailScreen> createState() =>
      _AuditReportDetailScreenState();
}

class _AuditReportDetailScreenState extends State<AuditReportDetailScreen> {
  late final AuditReportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AuditReportController());

    final int targetAuditId =
        widget.auditId ??
        Get.arguments?['auditId'] ??
        (Get.arguments is int ? Get.arguments : 0);

    if (targetAuditId > 0) {
      controller.loadAuditDetail(targetAuditId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: true,
        toolbarHeight: 40.h,
        topHeader: const CommonShortcutHeader(),
        titleSpacing: 0,
        title: Obx(() {
          final detail = controller.selectedAuditDetail.value;

          // ── Compact Excel button ────────────────────────────────────────
          final excelBtn = Obx(() => InkWell(
                onTap: controller.isExporting.value
                    ? null
                    : controller.exportDetailToExcel,
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF389D6A),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: controller.isExporting.value
                      ? SizedBox(
                          width: 10.r,
                          height: 10.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.file_download_outlined,
                              color: Colors.white,
                              size: 11.r,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Excel',
                              style: AppTextStyle.style_10_600(
                                  color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ));

          if (detail == null) {
            return Row(
              children: [
                Text(
                  'Inv Audit Details',
                  style: AppTextStyle.style_13_600(color: AppColors.black),
                ),
                const Spacer(),
                excelBtn,
              ],
            );
          }

          final auditNo = detail.auditNumber;
          final rawDate = detail.auditDateDisplay;
          final formattedDate = AppDateUtils.formatToShortOrdinalDate(rawDate);
          final auditDate = formattedDate.isNotEmpty ? formattedDate : rawDate;
          final unitDisplay = detail.unitName;
          final auditorName = detail.auditorName;

          final subtitleParts = <String>[];
          if (auditDate.isNotEmpty) subtitleParts.add(auditDate);
          if (unitDisplay.isNotEmpty) subtitleParts.add(unitDisplay);
          if (auditorName.isNotEmpty && auditorName != '-') {
            subtitleParts.add(auditorName);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Title | Audit No | Spacer | Excel btn ─────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Inv Audit Details',
                    style: AppTextStyle.style_13_600(color: AppColors.black),
                  ),
                  if (auditNo.isNotEmpty && auditNo != '-') ...[
                    SizedBox(width: 5.w),
                    Text(
                      '#$auditNo',
                      style: AppTextStyle.style_10_600(color: AppColors.grey300),
                    ),
                  ],
                  const Spacer(),
                  excelBtn,
                ],
              ),
              // ── Row 2: Subtitle ──────────────────────────────────────────
              if (subtitleParts.isNotEmpty) ...[
                Text(
                  subtitleParts.join("  •  "),
                  style: AppTextStyle.style_10_500(color: AppColors.grey300),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          );
        }),
      ),

      drawer: const CommonSidebar(),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return CustomAppLoader();
        }

        final detail = controller.selectedAuditDetail.value;
        if (detail == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48.r,
                  color: Colors.amber.shade700,
                ),
                SizedBox(height: 12.h),
                Text(
                  'No audit details available.',
                  style: AppTextStyle.style_14_400(color: AppColors.grey300),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return AppRefreshIndicator(
          onRefresh: () async {
            await controller.loadAuditDetail(detail.id);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuditReportDetailTable(detail: detail),
                SizedBox(height: 12.h),
                _buildAdditionalItemsTable(detail),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );

      }),
    );
  }

  // ── Additional / Unlisted Items Table ──────────────────────────────────────

  Widget _buildAdditionalItemsTable(AuditDetailData detail) {
    final items = detail.additionalItems;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: const BoxDecoration(color: Color(0xFF009BD9)),
              child: Row(
                children: [
                  Icon(Icons.add_box_outlined, color: Colors.white, size: 16.r),
                  SizedBox(width: 6.w),
                  Text(
                    'Additional / Unlisted Items',
                    style: AppTextStyle.style_12_500(color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${items.length} items',
                      style: AppTextStyle.style_11_600(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'No additional audit items found.',
                    style: AppTextStyle.style_12_400(color: AppColors.grey600),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Builder(
                  builder: (context) {
                    final columnWidths = {
                      0: FixedColumnWidth(120.w),
                      1: FixedColumnWidth(65.w),
                      2: FixedColumnWidth(85.w),
                      3: FixedColumnWidth(110.w),
                      4: FixedColumnWidth(100.w),
                    };

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade300),
                          ),
                          columnWidths: columnWidths,
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F1F8),
                              ),
                              children: [
                                _buildSimpleHeaderCell('Item'),
                                _buildSimpleHeaderCell('Image'),
                                _buildSimpleHeaderCell('Actual Qty'),
                                _buildSimpleHeaderCell('Measurement Unit'),
                                _buildSimpleHeaderCell('Type'),
                              ],
                            ),
                          ],
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),
                        Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade300),
                          ),
                          columnWidths: columnWidths,
                          children: List.generate(items.length, (index) {
                            final item = items[index];
                            return TableRow(
                              children: [
                                _buildSimpleDataCell(
                                  item.itemName,
                                  textStyle: AppTextStyle.style_11_600(
                                    color: AppColors.black,
                                  ),
                                ),
                                _buildImageCell(context, item.imageUrls),
                                _buildSimpleDataCell('${item.actualQty}'),
                                _buildSimpleDataCell(item.measurementUnit),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 6.h,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        item.type,
                                        style: AppTextStyle.style_10_500(
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCell(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
        child: Center(
          child: Text(
            'No Image',
            style: AppTextStyle.style_10_400(color: AppColors.grey300),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final firstUrl = imageUrls.first;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Center(
        child: GestureDetector(
          onTap: () => openFullScreenImageViewer(context, imageUrls, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: AppImageView(
                  imageUrl: firstUrl,
                  width: 26.r,
                  height: 26.r,
                  fit: BoxFit.cover,
                ),
              ),
              if (imageUrls.length > 1)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      '+${imageUrls.length - 1}',
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      child: Text(
        text,
        style: AppTextStyle.style_11_700(color: AppColors.black),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSimpleDataCell(
    String text, {
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      child: Text(
        text,
        style:
            textStyle ??
            AppTextStyle.style_11_500(color: textColor ?? AppColors.black),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
