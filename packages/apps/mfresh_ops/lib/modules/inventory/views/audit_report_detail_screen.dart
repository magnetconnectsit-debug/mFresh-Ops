import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/audit_report_controller.dart';
import 'widgets/audit_report_detail_table.dart';
import 'widgets/audit_additional_items_table.dart';

class AuditReportDetailScreen extends StatefulWidget {
  final int? auditId;

  const AuditReportDetailScreen({super.key, this.auditId});

  @override
  State<AuditReportDetailScreen> createState() =>
      _AuditReportDetailScreenState();
}

class _AuditReportDetailScreenState extends State<AuditReportDetailScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<AuditReportController>();
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuditReportController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: const CommonSidebar(),
      appBar: const AppCommonAppBar(
        topHeader: CommonShortcutHeader(),
        title: Text('Inventory Audit Details'),
        hasBackButton: true,
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CustomAppLoader());
        }

        final detail = controller.selectedAuditDetail.value;
        final entry = controller.selectedAuditEntry.value;

        if (detail == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  size: 48.r,
                  color: AppColors.grey300,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Failed to load audit detail.',
                  style: AppTextStyle.style_14_500(color: AppColors.grey300),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () {
                    final args = Get.arguments;
                    int? targetId = widget.auditId;
                    if (targetId == null &&
                        args is Map &&
                        args['auditId'] != null) {
                      targetId = args['auditId'] is int
                          ? args['auditId']
                          : int.tryParse(args['auditId'].toString());
                    }
                    if (targetId != null) {
                      controller.loadAuditDetail(targetId);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return _buildDetailBody(context, controller, detail, entry);
      }),
    );
  }

  // ── Main Body ──────────────────────────────────────────────────────────────

  Widget _buildDetailBody(
    BuildContext context,
    AuditReportController controller,
    AuditDetailData detail,
    AuditReportEntry? entry,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryHeader(detail, entry),
        Expanded(
          child: _buildTablesSection(context, controller, detail),
        ),
      ],
    );
  }

  // ── Summary Cards Header ───────────────────────────────────────────────────

  Widget _buildSummaryHeader(
    AuditDetailData detail,
    AuditReportEntry? entry,
  ) {
    final auditNum = detail.auditNumber.isNotEmpty
        ? detail.auditNumber
        : (entry?.auditNumber ?? '-');
    final unitName = detail.unitName.isNotEmpty
        ? detail.unitName
        : (entry?.unitName ?? '-');
    final auditor = detail.auditorName.isNotEmpty
        ? detail.auditorName
        : (entry?.auditorName ?? '-');
    final dateDisp = detail.auditDateDisplay.isNotEmpty
        ? detail.auditDateDisplay
        : (entry?.auditDateDisplay ?? '-');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFloatingLabelCard(
                  label: 'Audit Number',
                  value: auditNum,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildFloatingLabelCard(
                  label: 'Unit',
                  value: unitName,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _buildFloatingLabelCard(
                  label: 'Audit Date',
                  value: dateDisp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildFloatingLabelCard(
                  label: 'Audited By',
                  value: auditor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingLabelCard({
    required String label,
    required String value,
    Color? textColor,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        label: Text(
          label,
          style: AppTextStyle.style_11_400(
            color: AppColors.grey200,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: 3.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: SizedBox(
        height: 16.r,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyle.style_12_400(
              color: textColor ?? AppColors.grey900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // ── Tables Section (Existing + Additional) ──────────────────────────────────

  Widget _buildTablesSection(
    BuildContext context,
    AuditReportController controller,
    AuditDetailData detail,
  ) {
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
            AuditAdditionalItemsTable(detail: detail),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
