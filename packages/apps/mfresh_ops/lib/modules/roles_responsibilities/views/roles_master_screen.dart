// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/roles_responsibilities/controllers/roles_master_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class RolesMasterScreen extends StatelessWidget {
  const RolesMasterScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<RolesMasterController>()
        ? Get.find<RolesMasterController>()
        : Get.put(RolesMasterController());

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
            onRefresh: () => controller.fetchRoles(),
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
    RolesMasterController controller,
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
        'Roles Master',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildActionBar(
    BuildContext context,
    RolesMasterController controller,
  ) {
    final hasAddPerm = _hasPermission(AppPermissions.rolesMaster);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (hasAddPerm)
          AppCommonButton(
            text: 'Add Role',
            variant: ButtonVariant.primary,
            buttonColor: AppColors.primary,
            height: 24.h,
            textSize: 11.sp,
            isSmall: true,
            borderRadius: 4.r,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            onPressed: () => _showAddEditRoleDialog(context, controller),
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
              'Total: ${controller.filteredRoles.length}',
              style: AppTextStyle.style_11_600(color: AppColors.grey600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(
    BuildContext context,
    RolesMasterController controller,
  ) {
    return Obx(() {
      final rolesList = controller.paginatedRoles;

      if (rolesList.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Center(
            child: Text(
              'No roles found',
              style: AppTextStyle.style_13_500(color: AppColors.grey400),
            ),
          ),
        );
      }

      final columns = <AppTableColumn<RoleItem>>[
        AppTableColumn<RoleItem>(
          key: 'sl_no',
          title: 'Sl.No',
          width: 70.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            final originalIdx = controller.roles.indexOf(item);
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
        AppTableColumn<RoleItem>(
          key: 'role_name',
          title: 'Role Name',
          width: 250.w,
          alignment: Alignment.centerLeft,
          sortable: true,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.roleName,
              style: AppTextStyle.style_11_600(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<RoleItem>(
          key: 'action',
          title: 'Action',
          width: 90.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _handleEditRole(context, controller, item),
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
                  onTap: () => _handleDeleteRole(context, controller, item),
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

      return AppCommonTable<RoleItem>(
        items: rolesList,
        columns: columns,
        onSort: (key, sortOrder) {
          controller.toggleSort(key == 'role_name' ? 'roleName' : key);
        },
      );
    });
  }

  Widget _buildPaginationFooter(RolesMasterController controller) {
    return Obx(() {
      final totalItems = controller.filteredRoles.length;
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

  void _handleEditRole(
    BuildContext context,
    RolesMasterController controller,
    RoleItem role,
  ) {
    if (!_hasPermission(AppPermissions.rolesMaster)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to edit roles.',
        type: ToastType.warning,
      );
      return;
    }
    _showAddEditRoleDialog(context, controller, roleItem: role);
  }

  Future<void> _handleDeleteRole(
    BuildContext context,
    RolesMasterController controller,
    RoleItem role,
  ) async {
    if (!_hasPermission(AppPermissions.rolesMaster)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to delete roles.',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Role',
      message: 'Are you sure you want to delete role "${role.roleName}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed) {
      await controller.deleteRole(role.id);
    }
  }

  void _showAddEditRoleDialog(
    BuildContext context,
    RolesMasterController controller, {
    RoleItem? roleItem,
  }) {
    controller.roleNameCtrl.text = roleItem?.roleName ?? '';
    final isEdit = roleItem != null;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 440.w),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Role' : 'Add Role',
                      style: AppTextStyle.style_16_700(color: AppColors.black),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                AppCommonTextField(
                  controller: controller.roleNameCtrl,
                  titleText: 'Role Name *',
                  hintText: 'Enter role name',
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppCommonButton(
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                      height: 32.h,
                      width: 80.w,
                      borderRadius: 4.r,
                      textSize: 12.sp,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    SizedBox(width: 8.w),
                    AppCommonButton(
                      text: isEdit ? 'Update' : 'Save',
                      variant: ButtonVariant.primary,
                      buttonColor: AppColors.primary,
                      height: 32.h,
                      width: 85.w,
                      borderRadius: 4.r,
                      textSize: 12.sp,
                      onPressed: () async {
                        final name = controller.roleNameCtrl.text.trim();
                        if (name.isEmpty) {
                          AppCommonToastMessage.show(
                            message: 'Role Name is required',
                            type: ToastType.error,
                          );
                          return;
                        }
                        final bool success = isEdit
                            ? await controller.updateRole(roleItem.id, name)
                            : await controller.addRole(name);
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // endregion
}
// endregion
