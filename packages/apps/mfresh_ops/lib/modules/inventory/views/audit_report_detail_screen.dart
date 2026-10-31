// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/inventory/audit_report_model.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import '../controllers/audit_report_controller.dart';
import 'widgets/audit_additional_items_table.dart';
import 'widgets/audit_report_detail_table.dart';
import 'widgets/audit_summary_table.dart';
// endregion

// region View
class AuditReportDetailScreen extends StatefulWidget {
  final int? auditId;

  const AuditReportDetailScreen({super.key, this.auditId});

  @override
  State<AuditReportDetailScreen> createState() =>
      _AuditReportDetailScreenState();
}
// endregion

// region State
class _AuditReportDetailScreenState extends State<AuditReportDetailScreen> {
  // region Dependencies & Controllers
  late final AuditReportController controller;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    controller = Get.find<AuditReportController>();
    final args = Get.arguments;

    int? targetId = widget.auditId;
    if (targetId == null && args is Map && args['auditId'] != null) {
      targetId = args['auditId'] is int
          ? args['auditId']
          : int.tryParse(args['auditId'].toString());
    }

    if (targetId != null) {
      controller.loadAuditDetail(targetId);
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CustomAppLoader());
        }

        final detail = controller.selectedAuditDetail.value;

        if (detail == null) {
          return _buildErrorState(context);
        }

        return _buildDetailContent(context, detail);
      }),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppCommonAppBar(
      topHeader: const CommonShortcutHeader(),
      hasBackButton: true,
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Audit Report',
              style: AppTextStyle.style_16_700(color: AppColors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(() {
            final isExporting = controller.isExporting.value;
            final hasDetail = controller.selectedAuditDetail.value != null;
            if (!hasDetail) return const SizedBox.shrink();

            return Container(
              margin: EdgeInsets.only(right: 8.w),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isExporting ? null : () => controller.exportDetailToExcel(),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF107C41), // Excel green
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isExporting
                            ? SizedBox(
                                width: 12.r,
                                height: 12.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Icon(
                                Icons.file_download_outlined,
                                size: 14.r,
                                color: AppColors.white,
                              ),
                        SizedBox(width: 4.w),
                        Text(
                          'Excel',
                          style: AppTextStyle.style_11_600(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildDetailContent(BuildContext context, AuditDetailData detail) {
    return AppRefreshIndicator(
      onRefresh: () async {
        await controller.loadAuditDetail(detail.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Audit Summary Table
            AuditSummaryTable(unitList: detail.unitList),
            SizedBox(height: 16.h),

            // 2. Existing Inventory Items — Unit-wise Comparison Table
            AuditReportDetailTable(detail: detail),
            SizedBox(height: 16.h),

            // 3. Additional / Unlisted Items Table
            AuditAdditionalItemsTable(detail: detail),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_problem_outlined,
            size: 48.r,
            color: AppColors.grey400,
          ),
          SizedBox(height: 12.h),
          Text(
            'Failed to load audit detail.',
            style: AppTextStyle.style_14_500(color: AppColors.grey500),
          ),
          SizedBox(height: 12.h),
          AppCommonButton(
            text: 'Retry',
            onPressed: () {
              final args = Get.arguments;
              int? targetId = widget.auditId;
              if (targetId == null && args is Map && args['auditId'] != null) {
                targetId = args['auditId'] is int
                    ? args['auditId']
                    : int.tryParse(args['auditId'].toString());
              }
              if (targetId != null) {
                controller.loadAuditDetail(targetId);
              }
            },
          ),
        ],
      ),
    );
  }
  // endregion
}
// endregion
