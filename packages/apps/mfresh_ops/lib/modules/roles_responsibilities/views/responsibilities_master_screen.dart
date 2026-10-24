// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/responsibilities_master_controller.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/views/add_responsibility_screen.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/views/widgets/simple_html_renderer.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class ResponsibilitiesMasterScreen extends StatelessWidget {
  const ResponsibilitiesMasterScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ResponsibilitiesMasterController>()
        ? Get.find<ResponsibilitiesMasterController>()
        : Get.put(ResponsibilitiesMasterController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CustomAppLoader());
          }

          return AppRefreshIndicator(
            onRefresh: () => controller.fetchResponsibilities(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionBar(context, controller),
                  SizedBox(height: 10.h),
                  _buildTableSection(context, controller),
                  SizedBox(height: 12.h),
                  _buildPaginationFooter(controller),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ResponsibilitiesMasterController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      showSearchBar: true,
      searchController: controller.searchCtrl,
      onSearchChanged: (v) => controller.searchQuery.value = v,
      toolbarHeight: 45.h,
      title: Text(
        'Responsibility Master',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildActionBar(
    BuildContext context,
    ResponsibilitiesMasterController controller,
  ) {
    final hasAddPerm = _hasPermission(AppPermissions.responsibilitiesMaster);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (hasAddPerm)
          AppCommonButton(
            text: 'Add Responsibility',
            variant: ButtonVariant.primary,
            buttonColor: AppColors.primary,
            height: 24.h,
            textSize: 11.sp,
            isSmall: true,
            borderRadius: 4.r,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            onPressed: () => _navigateToAdd(context),
          )
        else
          const SizedBox.shrink(),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderColor, width: 1.r),
            ),
            child: Text(
              'Total: ${controller.filteredResponsibilities.length}',
              style: AppTextStyle.style_11_600(color: AppColors.grey600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(
    BuildContext context,
    ResponsibilitiesMasterController controller,
  ) {
    return Obx(() {
      final list = controller.paginatedResponsibilities;

      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Center(
            child: Text(
              'No responsibilities found',
              style: AppTextStyle.style_13_500(color: AppColors.grey400),
            ),
          ),
        );
      }

      final columns = <AppTableColumn<ResponsibilityItem>>[
        AppTableColumn<ResponsibilityItem>(
          key: 'sl_no',
          title: 'Sl.No',
          width: 60.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            final originalIdx = controller.responsibilities.indexOf(item);
            final slNo = originalIdx != -1
                ? originalIdx + 1
                : (controller.currentPage.value - 1) * controller.perPage.value +
                    index +
                    1;
            return Text(
              '$slNo',
              style: AppTextStyle.style_11_400(color: AppColors.black87),
              textAlign: TextAlign.center,
            );
          },
        ),
        AppTableColumn<ResponsibilityItem>(
          key: 'role',
          title: 'Role',
          width: 120.w,
          alignment: Alignment.centerLeft,
          sortable: true,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.roleName ?? 'Role #${item.roleId}',
              style: AppTextStyle.style_11_600(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<ResponsibilityItem>(
          key: 'guidelines_en',
          title: 'Guidelines (English)',
          width: 260.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            final text = _stripHtml(item.guidelinesEnglish);
            if (isExpanded && (item.guidelinesEnglish ?? '').contains('<')) {
              return SimpleHtmlRenderer(
                htmlContent: item.guidelinesEnglish ?? '',
                baseStyle: AppTextStyle.style_11_400(color: AppColors.black87),
              );
            }
            return Text(
              text.isNotEmpty ? text : '-',
              style: AppTextStyle.style_11_400(color: AppColors.black87),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<ResponsibilityItem>(
          key: 'guidelines_or',
          title: 'Guidelines (Odia)',
          width: 260.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            final text = _stripHtml(item.guidelinesOdia);
            if (isExpanded && (item.guidelinesOdia ?? '').contains('<')) {
              return SimpleHtmlRenderer(
                htmlContent: item.guidelinesOdia ?? '',
                baseStyle: AppTextStyle.style_11_400(color: AppColors.black87),
              );
            }
            return Text(
              text.isNotEmpty ? text : '-',
              style: AppTextStyle.style_11_400(color: AppColors.black87),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<ResponsibilityItem>(
          key: 'action',
          title: 'Action',
          width: 90.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _handleEdit(context, item),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 13.sp,
                      color: AppColors.grey700,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                InkWell(
                  onTap: () => _handleDelete(context, controller, item),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 13.sp,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ];

      return AppCommonTable<ResponsibilityItem>(
        items: list,
        columns: columns,
        onSort: (key, sortOrder) {
          controller.toggleSort(key == 'role' ? 'roleName' : key);
        },
      );
    });
  }

  Widget _buildPaginationFooter(ResponsibilitiesMasterController controller) {
    return Obx(() {
      final totalItems = controller.filteredResponsibilities.length;
      final startItem = totalItems == 0
          ? 0
          : ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final endItem = (startItem + controller.perPage.value - 1).clamp(
        0,
        totalItems,
      );

      return AppTablePagination(
        startItem: startItem,
        endItem: endItem,
        totalItems: totalItems,
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages,
        onPageChanged: (page) => controller.goToPage(page),
        onPreviousPage: controller.previousPage,
        onNextPage: controller.nextPage,
      );
    });
  }
  // endregion

  // region Dialogs & Action Handlers
  bool _hasPermission(String key) {
    if (!Get.isRegistered<AuthRepository>()) return true;
    final perms = Get.find<AuthRepository>().rxUserPermissions;
    return perms.contains(key);
  }

  void _navigateToAdd(BuildContext context) {
    if (!_hasPermission(AppPermissions.responsibilitiesMaster)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to add responsibilities.',
        type: ToastType.warning,
      );
      return;
    }
    Get.to(() => const AddResponsibilityScreen());
  }

  void _handleEdit(BuildContext context, ResponsibilityItem item) {
    if (!_hasPermission(AppPermissions.responsibilitiesMaster)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to edit responsibilities.',
        type: ToastType.warning,
      );
      return;
    }
    Get.to(() => AddResponsibilityScreen(responsibilityItem: item));
  }

  Future<void> _handleDelete(
    BuildContext context,
    ResponsibilitiesMasterController controller,
    ResponsibilityItem item,
  ) async {
    if (!_hasPermission(AppPermissions.responsibilitiesMaster)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to delete responsibilities.',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Responsibility',
      message:
          'Are you sure you want to delete responsibility for role "${item.roleName ?? item.roleId}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed) {
      await controller.deleteResponsibility(item.id);
    }
  }

  String _stripHtml(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  // endregion
}
// endregion
