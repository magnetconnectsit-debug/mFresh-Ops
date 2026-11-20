// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/master/assign_service_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/master/controllers/all_assign_service_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region AllAssignServiceScreen
class AllAssignServiceScreen extends GetView<AllAssignServiceController> {
  const AllAssignServiceScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value &&
                  controller.assignedServices.isEmpty) {
                return const Center(child: CustomAppLoader());
              }

              return AppRefreshIndicator(
                onRefresh: () => controller.fetchAllAssignServices(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActionBar(context, controller),
                      SizedBox(height: 10.h),
                      _buildTableSection(context, controller),
                      SizedBox(height: 12.h),
                      _buildFooterSection(controller),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              );
            }),
            Obx(() {
              if (controller.isToggling.value) {
                return Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: AppColors.black.withValues(alpha: 0.25),
                      child: const Center(child: CustomAppLoader()),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AllAssignServiceController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      title: Text(
        'All Assign Services',
        style: AppTextStyle.style_16_600(color: AppColors.black),
      ),
      showSearchBar: true,
      searchHintText: 'Search services, units, mode...',
      searchController: controller.searchCtrl,
      onSearchChanged: (val) => controller.onSearchChanged(val),
      onSearchClear: () {
        controller.searchCtrl.clear();
        controller.onSearchChanged('');
      },
      topHeader: const CommonShortcutHeader(),
    );
  }
  // endregion

  // region Section Builders - Action Bar
  Widget _buildActionBar(
    BuildContext context,
    AllAssignServiceController controller,
  ) {
    final authRepo = Get.find<AuthRepository>();
    final canManage = authRepo.rxUserPermissions.contains(
      AppPermissions.masterPanel,
    );

    return Row(
      children: [
        if (canManage)
          AppCommonButton(
            text: '+ Create Assign Service',
            onPressed: () => controller.openCreateAssignService(),
          ),
        if (canManage) SizedBox(width: 10.w),
        Obx(
          () => AppCommonExportButton(
            isLoading: controller.isExporting.value,
            onExportExcel: controller.exportToExcel,
          ),
        ),
        const Spacer(),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderColor, width: 1.r),
            ),
            child: Text(
              'Total: ${controller.filteredServices.length}',
              style: AppTextStyle.style_12_500(color: AppColors.grey700),
            ),
          ),
        ),
      ],
    );
  }
  // endregion

  // region Section Builders - Table Section
  Widget _buildTableSection(
    BuildContext context,
    AllAssignServiceController controller,
  ) {
    return Obx(() {
      final items = controller.paginatedServices;

      final columns = <AppTableColumn<AllAssignServiceItem>>[
        AppTableColumn<AllAssignServiceItem>(
          key: 'unit',
          title: 'Unit ID\'s',
          sortable: true,
          width: 75.w,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.assqrcodeId,
              style: AppTextStyle.style_11_500(color: AppColors.grey800),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'service_name',
          title: 'Service name',
          sortable: true,
          width: 115.w,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.servicesName ?? 'NA',
              style: AppTextStyle.style_11_500(color: AppColors.grey800),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'service_for',
          title: 'Service For',
          sortable: true,
          width: 80.w,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.serviceFor ?? 'Customer',
              style: AppTextStyle.style_11_400(color: AppColors.grey700),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'pay_type',
          title: 'Pay Type',
          sortable: true,
          width: 75.w,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.payType ?? 'Offline',
              style: AppTextStyle.style_11_400(color: AppColors.grey700),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'price',
          title: 'Price',
          sortable: true,
          width: 65.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Center(
              child: Text(
                item.price ?? '0',
                style: AppTextStyle.style_11_500(color: AppColors.grey800),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'gst',
          title: 'GST (%)',
          sortable: true,
          width: 65.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Center(
              child: Text(
                '${item.gstpercent ?? 0}',
                style: AppTextStyle.style_11_400(color: AppColors.grey700),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'net_price',
          title: 'Net Price',
          sortable: true,
          width: 70.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Center(
              child: Text(
                item.netPrice ?? '0',
                style: AppTextStyle.style_11_500(color: AppColors.grey800),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'uses',
          title: 'Uses',
          sortable: true,
          width: 65.w,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.uses ?? '',
              style: AppTextStyle.style_11_400(color: AppColors.grey700),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'status',
          title: 'Status',
          sortable: true,
          width: 65.w,
          cellBuilder: (context, item, index, isExpanded) {
            final isActive = item.status == 1;
            return Text(
              isActive ? 'Active' : 'Inactive',
              style: AppTextStyle.style_11_600(
                color: isActive
                    ? const Color(0xFF2E7D32)
                    : AppColors.grey600,
              ),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'toggle',
          title: 'Toggle',
          sortable: false,
          width: 95.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            final isActive = item.status == 1;
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32.w,
                  height: 18.h,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Switch(
                      value: isActive,
                      activeThumbColor: const Color(0xFF1976D2),
                      activeTrackColor: const Color(0xFF90CAF9),
                      inactiveThumbColor: AppColors.grey400,
                      inactiveTrackColor: AppColors.grey200,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) {
                        _handleToggleStatus(context, item, controller);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: AppTextStyle.style_11_400(
                    color: isActive
                        ? const Color(0xFF1976D2)
                        : AppColors.grey600,
                  ),
                ),
              ],
            );
          },
        ),
        AppTableColumn<AllAssignServiceItem>(
          key: 'action',
          title: 'Action',
          sortable: false,
          width: 55.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Center(
              child: InkWell(
                onTap: () => controller.editUnitAssignService(item),
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  width: 22.h,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1.r,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 13.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            );
          },
        ),
      ];

      return AppCommonTable<AllAssignServiceItem>(
        columns: columns,
        items: items,
        isLoading: controller.isLoading.value,
        onSort: (key, order) => controller.sort(key, order),
        currentSortColumn: controller.sortColumn.value,
        currentSortOrder: controller.sortOrder.value,
      );
    });
  }
  // endregion

  // region Section Builders - Footer Section
  Widget _buildFooterSection(AllAssignServiceController controller) {
    return Obx(() {
      final total = controller.filteredServices.length;
      if (total == 0) return const SizedBox.shrink();

      final start =
          ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final end = (start + controller.perPage.value - 1 > total)
          ? total
          : (start + controller.perPage.value - 1);

      return AppTablePagination(
        startItem: start,
        endItem: end,
        totalItems: total,
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages,
        onPageChanged: (page) => controller.changePage(page),
      );
    });
  }
  // endregion

  // region Dialogs & Action Handlers
  Future<void> _handleToggleStatus(
    BuildContext context,
    AllAssignServiceItem item,
    AllAssignServiceController controller,
  ) async {
    final authRepo = Get.find<AuthRepository>();
    if (!authRepo.rxUserPermissions.contains(AppPermissions.masterPanel)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to modify status.',
        type: ToastType.warning,
      );
      return;
    }

    if (item.status == 1) {
      // Deactivation confirmation
      final bool confirmed = await AppCommonDialogBox.showConfirm(
        context,
        title: 'Deactivate Assigned Service',
        message:
            'Are you sure you want to deactivate ${item.servicesName ?? 'this service'} (${item.assqrcodeId})?',
        confirmText: 'Deactivate',
        cancelText: 'Cancel',
        confirmButtonColor: AppColors.error,
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.error,
      );
      if (confirmed) {
        controller.toggleServiceStatus(item);
      }
    } else {
      // Direct activation
      controller.toggleServiceStatus(item);
    }
  }
  // endregion
}
// endregion
