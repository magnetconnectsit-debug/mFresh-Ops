import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/audit_report_controller.dart';

class AuditReportScreen extends StatefulWidget {
  const AuditReportScreen({super.key});

  @override
  State<AuditReportScreen> createState() => _AuditReportScreenState();
}

class _AuditReportScreenState extends State<AuditReportScreen> {
  late final AuditReportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AuditReportController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Obx(() => controller.isSearching.value
            ? AppCommonSearchBar(
                controller: controller.searchController,
                hintText: 'Search audit no, unit, by...',
                onChanged: (_) => controller.applySearch(),
              )
            : Text(
                'Audit Report',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              )),
        actions: [
          Obx(() => IconButton(
                onPressed: controller.toggleSearch,
                icon: Icon(controller.isSearching.value
                    ? Icons.close
                    : Icons.search),
              )),
        ],
      ),
      drawer: const CommonSidebar(),
      body: AppRefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                _buildTableCard(),
                SizedBox(height: 12.h),
                _buildPagination(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main table card ────────────────────────────────────────────────

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4F7BF7).withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                _headerCell('Sl.No', flex: 1),
                _headerCell('Audit No', flex: 3),
                _headerCell('Unit', flex: 3),
                _headerCell('Date', flex: 3),
                _headerCell('Audited By', flex: 3),
              ],
            ),
          ),
          // Body
          Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 48.h),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (controller.filteredList.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 48.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.fact_check_outlined,
                          size: 40.r, color: Colors.grey.shade300),
                      SizedBox(height: 10.h),
                      Text('No audit records found.',
                          style: AppTextStyle.style_13_400(
                              color: AppColors.grey300)),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredList.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (ctx, index) {
                final entry = controller.filteredList[index];
                final slNo =
                    (controller.currentPage.value - 1) * controller.perPage +
                        index +
                        1;
                return _buildRow(slNo, entry);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyle.style_11_600(color: AppColors.black),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRow(int slNo, AuditReportEntry entry) {
    return InkWell(
      onTap: () => _showDetailSheet(entry),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '$slNo',
                style: AppTextStyle.style_11_400(color: AppColors.grey300),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () => _showDetailSheet(entry),
                child: Text(
                  entry.auditNo,
                  style: AppTextStyle.style_11_600(
                      color: const Color(0xFF4F7BF7)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                entry.unitName,
                style: AppTextStyle.style_11_400(color: AppColors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                _formatDate(entry.auditDate),
                style: AppTextStyle.style_11_400(color: AppColors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                entry.auditBy,
                style: AppTextStyle.style_11_400(color: AppColors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pagination ─────────────────────────────────────────────────────

  Widget _buildPagination() {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? controller.prevPage
                : null,
            icon: const Icon(Icons.chevron_left),
            color: const Color(0xFF4F7BF7),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4F7BF7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Page ${controller.currentPage.value} / ${controller.totalPages.value}',
              style: AppTextStyle.style_12_500(color: const Color(0xFF4F7BF7)),
            ),
          ),
          IconButton(
            onPressed:
                controller.currentPage.value < controller.totalPages.value
                    ? controller.nextPage
                    : null,
            icon: const Icon(Icons.chevron_right),
            color: const Color(0xFF4F7BF7),
          ),
        ],
      );
    });
  }

  // ── Detail bottom sheet ────────────────────────────────────────────

  void _showDetailSheet(AuditReportEntry entry) async {
    await controller.loadAuditDetail(entry);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AuditDetailSheet(controller: controller),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Detail Bottom Sheet ────────────────────────────────────────────

class _AuditDetailSheet extends StatelessWidget {
  final AuditReportController controller;

  const _AuditDetailSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Title row
              Obx(() {
                final audit = controller.selectedAudit.value;
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF4F7BF7).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.fact_check_outlined,
                            color: const Color(0xFF4F7BF7), size: 16.r),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audit?.auditNo ?? '-',
                              style: AppTextStyle.style_15_700(
                                  color: AppColors.black),
                            ),
                            if (audit != null)
                              Text(
                                '${audit.unitName}  •  ${audit.auditBy}  •  ${_fmt(audit.auditDate)}',
                                style: AppTextStyle.style_11_400(
                                    color: AppColors.grey300),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                        color: AppColors.grey300,
                      ),
                    ],
                  ),
                );
              }),
              Divider(height: 1, color: Colors.grey.shade200),
              // Table header
              Container(
                color: const Color(0xFF4F7BF7).withValues(alpha: 0.06),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    _hCell('Item', flex: 5),
                    _hCell('System Qty', flex: 3),
                    _hCell('Audit Qty', flex: 3),
                    _hCell('Variance', flex: 3),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              // Table body
              Expanded(
                child: Obx(() {
                  if (controller.isDetailLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (controller.detailItems.isEmpty) {
                    return Center(
                      child: Text('No items found.',
                          style: AppTextStyle.style_13_400(
                              color: AppColors.grey300)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    itemCount: controller.detailItems.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (ctx, i) {
                      final item = controller.detailItems[i];
                      return _DetailRow(item: item, index: i);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hCell(String text, {int flex = 1}) => Expanded(
        flex: flex,
        child: Text(text,
            style: AppTextStyle.style_11_600(color: AppColors.black),
            overflow: TextOverflow.ellipsis),
      );

  String _fmt(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final AuditDetailItem item;
  final int index;

  const _DetailRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final isNeg = item.variance < 0;
    final isPos = item.variance > 0;

    return Container(
      color: index.isEven ? Colors.transparent : Colors.grey.shade50,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              item.itemName,
              style: AppTextStyle.style_12_500(color: AppColors.black),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _fmt(item.systemQty, item.measurementUnit),
              style: AppTextStyle.style_11_400(color: AppColors.grey300),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _fmt(item.auditQty, item.measurementUnit),
              style: AppTextStyle.style_11_500(color: AppColors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isNeg
                    ? Colors.red.withValues(alpha: 0.1)
                    : isPos
                        ? const Color(0xFF389D6A).withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${isPos ? '+' : ''}${item.variance.toStringAsFixed(1)}',
                style: AppTextStyle.style_11_600(
                    color: isNeg
                        ? Colors.red.shade600
                        : isPos
                            ? const Color(0xFF389D6A)
                            : AppColors.grey300),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double qty, String unit) {
    final display =
        qty == qty.toInt() ? qty.toInt().toString() : qty.toStringAsFixed(2);
    return unit.isNotEmpty ? '$display $unit' : display;
  }
}
