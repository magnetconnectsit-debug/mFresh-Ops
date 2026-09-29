import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import '../controllers/audit_item_rank_controller.dart';
import 'package:mfresh_ops/data/models/inventory/audit_item_rank_model.dart';
import '../../../widgets/common_sidebar.dart';
import '../../../widgets/common_shortcut_header.dart';

class AuditItemRankScreen extends StatelessWidget {
  const AuditItemRankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuditItemRankController());

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canViewPage = userPermissions.contains('audit_item_rank') ||
          userPermissions.contains('audit_item_ranks');
      final canCreateRank = userPermissions.contains('create_audit_item_rank');
      final canEditRank = userPermissions.contains('edit_audit_item_rank');

      if (!canViewPage) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppCommonAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            hasBackButton: false,
            showAppDrawer: true,
            topHeader: const CommonShortcutHeader(),
            title: Text(
              'Audit Item Rank',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
          ),
          drawer: const CommonSidebar(),
          body: Center(
            child: Text(
              'You do not have permission to view this page.',
              style: AppTextStyle.style_14_600(color: AppColors.grey400),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppCommonAppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          hasBackButton: false,
          showAppDrawer: true,
          topHeader: const CommonShortcutHeader(),
          title: Obx(
            () => controller.isSearching.value
                ? AppCommonSearchBar(
                    controller: controller.searchController,
                    onChanged: (v) => controller.applyFilters(),
                    hintText: 'Search Audit Item Rank...',
                  )
                : Text(
                    'Audit Item Rank',
                    style: AppTextStyle.style_18_700(color: AppColors.black),
                  ),
          ),
          actions: [
            Obx(
              () => IconButton(
                onPressed: () => controller.toggleSearch(),
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                ),
              ),
            ),
          ],
        ),
        drawer: const CommonSidebar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canCreateRank)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      height: 28.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showAddDialog(context, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                        ),
                        child: Text(
                          'Add Rank',
                          style: AppTextStyle.style_12_600(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: AppRefreshIndicator(
                onRefresh: () => controller.onRefresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(() {
                    final isTableLoading = controller.isLoading.value;
                    final items = isTableLoading
                        ? List.generate(
                            4,
                            (index) => AuditItemRankModel(
                              id: index + 1,
                              rankName: 'Loading Audit Rank ${index + 1}',
                            ),
                          )
                        : controller.auditItemRanks;

                    if (!isTableLoading && items.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Center(
                          child: Text(
                            'No audit item ranks found',
                            style: AppTextStyle.style_14_400(color: AppColors.grey300),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Skeletonizer(
                          enabled: isTableLoading,
                          child: Table(
                            columnWidths: canEditRank
                                ? const {
                                    0: IntrinsicColumnWidth(), // Sl No
                                    1: FlexColumnWidth(1),     // Name
                                    2: IntrinsicColumnWidth(), // Action
                                  }
                                : const {
                                    0: IntrinsicColumnWidth(), // Sl No
                                    1: FlexColumnWidth(1),     // Name
                                  },
                            border: TableBorder.all(color: AppColors.grey50, width: 1),
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(color: AppColors.white),
                                children: [
                                  _buildHeaderCell('Sl No'),
                                  _buildHeaderCell(
                                    'Name',
                                    sortable: true,
                                    columnIndex: 1,
                                    controller: controller,
                                  ),
                                  if (canEditRank) _buildHeaderCell('Action'),
                                ],
                              ),
                              ...items.asMap().entries.map((entry) {
                                final index = entry.key;
                                final model = entry.value;
                                return TableRow(
                                  decoration: const BoxDecoration(color: AppColors.white),
                                  children: [
                                    _buildDataCell('${index + 1}'),
                                    _buildDataCell(model.rankName),
                                    if (canEditRank)
                                      _buildActionCell(context, controller, model),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Showing 1 to ${controller.auditItemRanks.length} of ${controller.allAuditItemRanks.length} entries',
                          style: AppTextStyle.style_14_400(color: AppColors.black),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderCell(
    String text, {
    bool sortable = false,
    int columnIndex = 0,
    AuditItemRankController? controller,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: sortable && controller != null
          ? InkWell(
              onTap: () => controller.sortTable(columnIndex),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: AppTextStyle.style_12_700(color: AppColors.black),
                  ),
                  SizedBox(width: 4.w),
                  Obx(() {
                    final state = controller.sortState.value;
                    IconData icon;
                    Color iconColor;
                    if (state == 1) {
                      icon = Icons.arrow_upward;
                      iconColor = AppColors.primary;
                    } else if (state == 2) {
                      icon = Icons.arrow_downward;
                      iconColor = AppColors.primary;
                    } else {
                      icon = Icons.unfold_more;
                      iconColor = AppColors.grey300;
                    }
                    return Icon(
                      icon,
                      size: 13.sp,
                      color: iconColor,
                    );
                  }),
                ],
              ),
            )
          : Text(
              text,
              style: AppTextStyle.style_12_700(color: AppColors.black),
            ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.black),
      ),
    );
  }

  Widget _buildActionCell(
    BuildContext context,
    AuditItemRankController controller,
    AuditItemRankModel model,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _showEditDialog(context, controller, model),
            child: Icon(
              Icons.edit_square,
              color: AppColors.primary,
              size: 16.r,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, AuditItemRankController controller) {
    controller.rankNameController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Audit Item Rank',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
              SizedBox(height: 20.h),
              AppCommonTextField(
                controller: controller.rankNameController,
                titleText: 'Rank Name',
                hintText: 'e.g. Audit Daily',
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey300,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(
                    () => AppCommonButton(
                      text: 'Submit',
                      width: 100.w,
                      height: 36.h,
                      isLoading: controller.isSubmitting.value,
                      onPressed: () async {
                        final success = await controller.addAuditItemRank();
                        if (success && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    AuditItemRankController controller,
    AuditItemRankModel model,
  ) {
    final nameController = TextEditingController(text: model.rankName);
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Audit Item Rank',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
              SizedBox(height: 20.h),
              AppCommonTextField(
                controller: nameController,
                titleText: 'Rank Name',
                hintText: 'e.g. Audit Daily',
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey300,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(
                    () => AppCommonButton(
                      text: 'Update',
                      width: 100.w,
                      height: 36.h,
                      isLoading: controller.isSubmitting.value,
                      onPressed: () async {
                        final success =
                            await controller.editAuditItemRank(model, nameController.text);
                        if (success && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
