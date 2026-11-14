// region Imports
import 'dart:io';
import 'dart:math';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/master/amenity_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/master/controllers/amenity_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region AmenityScreen
class AmenityScreen extends StatelessWidget {
  const AmenityScreen({super.key});

  // region RBAC Permissions Helper
  bool _hasPermission(String key) {
    if (!Get.isRegistered<AuthRepository>()) return false;
    final permissions = Get.find<AuthRepository>().rxUserPermissions;
    return AppPermissions.has(permissions, key);
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AmenityController>()
        ? Get.find<AmenityController>()
        : Get.put(AmenityController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value && controller.amenities.isEmpty) {
                return const Center(child: CustomAppLoader());
              }

              return AppRefreshIndicator(
                onRefresh: () => controller.fetchAmenities(),
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
              if (controller.isSubmitting.value) {
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
    AmenityController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      showSearchBar: true,
      searchController: controller.searchCtrl,
      searchHintText: 'Search Amenity...',
      searchBarWidth: 150.w,
      onSearchChanged: (v) {
        controller.searchQuery.value = v;
        controller.currentPage.value = 1;
      },
      onSearchClear: () {
        controller.resetSearch();
      },
      title: Text(
        'All Amenities',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildActionBar(BuildContext context, AmenityController controller) {
    final canManage = _hasPermission(AppPermissions.masterPanel);

    return Row(
      children: [
        if (canManage)
          AppCommonButton(
            text: '+ Amenity',
            onPressed: () => _showAddEditAmenityDialog(context, controller),
          ),
        if (canManage) SizedBox(width: 10.w),
        Obx(
          () => AppCommonExportButton(
            onExportExcel: () => controller.exportToExcel(),
            isLoading: controller.isExporting.value,
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
              'Total: ${controller.filteredAmenities.length}',
              style: AppTextStyle.style_11_600(color: AppColors.grey600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(BuildContext context, AmenityController controller) {
    final canManage = _hasPermission(AppPermissions.masterPanel);

    return Obx(() {
      final items = controller.paginatedAmenities;

      if (items.isEmpty && !controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Center(
            child: Text(
              'No amenities found',
              style: AppTextStyle.style_13_500(color: AppColors.grey400),
            ),
          ),
        );
      }

      final columns = [
        AppTableColumn<AmenityItem>(
          key: 'si_no',
          title: 'SI No.',
          sortable: true,
          width: 50.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            final overallIndex =
                (controller.currentPage.value - 1) * controller.perPage.value +
                    index +
                    1;
            return Text(
              overallIndex.toString(),
              style: AppTextStyle.style_11_500(color: AppColors.black),
            );
          },
        ),
        AppTableColumn<AmenityItem>(
          key: 'icon',
          title: 'Icon',
          sortable: false,
          width: 60.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            if (item.hasValidIcon) {
              return SizedBox(
                width: 20.r,
                height: 20.r,
                child: AppImageView(
                  imageUrl: item.iconUrl,
                  width: 20.r,
                  height: 20.r,
                  fit: BoxFit.contain,
                  errorWidget: Icon(
                    Icons.category_outlined,
                    size: 16.sp,
                    color: AppColors.grey400,
                  ),
                ),
              );
            }
            return Icon(
              Icons.category_outlined,
              size: 16.sp,
              color: AppColors.grey400,
            );
          },
        ),
        AppTableColumn<AmenityItem>(
          key: 'amenity',
          title: 'Amenity Name',
          sortable: true,
          width: 180.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, item, index, isExpanded) {
            return Text(
              item.amenityName,
              style: AppTextStyle.style_11_500(color: AppColors.black),
              maxLines: isExpanded ? null : 1,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            );
          },
        ),
        if (canManage)
          AppTableColumn<AmenityItem>(
            key: 'action',
            title: 'Action',
            sortable: false,
            width: 75.w,
            alignment: Alignment.centerLeft,
            cellBuilder: (context, item, index, isExpanded) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showAddEditAmenityDialog(
                      context,
                      controller,
                      amenityItem: item,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14.sp,
                        color: AppColors.blue500,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () => _handleDeleteAmenity(context, controller, item),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.delete_outline,
                        size: 14.sp,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ];

      return AppCommonTable<AmenityItem>(
        columns: columns,
        items: items,
        isLoading: controller.isLoading.value,
        onSort: (colKey, order) => controller.onSort(colKey, order),
        currentSortColumn: controller.sortColumn.value,
        currentSortOrder: controller.sortOrder.value,
      );
    });
  }

  Widget _buildFooterSection(AmenityController controller) {
    return Obx(() {
      final total = controller.filteredAmenities.length;
      final start = total == 0
          ? 0
          : ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final end = min(
        controller.currentPage.value * controller.perPage.value,
        total,
      );

      return AppTablePagination(
        startItem: start,
        endItem: end,
        totalItems: total,
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages,
        onPageChanged: (page) => controller.setPage(page),
      );
    });
  }
  // endregion

  // region Dialogs & Action Handlers
  void _showAddEditAmenityDialog(
    BuildContext context,
    AmenityController controller, {
    AmenityItem? amenityItem,
  }) {
    final isEdit = amenityItem != null;
    controller.amenityNameCtrl.text = amenityItem?.amenityName ?? '';
    controller.selectedIconFile.value = null;
    controller.currentIconUrl.value = amenityItem?.iconUrl;

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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.r),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? 'Edit Amenity' : 'Add Amenity',
                            style: AppTextStyle.style_16_700(
                              color: AppColors.black,
                            ),
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
                      // Amenity Name Field
                      AppCommonTextField(
                        controller: controller.amenityNameCtrl,
                        labelText: 'Amenity Name',
                        isRequired: true,
                        hintText: 'Enter amenity name',
                      ),
                      SizedBox(height: 14.h),
                      // Amenity Icon Picker Section
                      Text(
                        'Amenity Icon (Optional)',
                        style: AppTextStyle.style_12_500(
                          color: AppColors.black300,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Obx(() {
                        final file = controller.selectedIconFile.value;
                        final url = controller.currentIconUrl.value;
                        final hasImage =
                            file != null ||
                            (url != null &&
                                url.isNotEmpty &&
                                !url.endsWith('/NA'));

                        if (!hasImage) {
                          return InkWell(
                            onTap: () => _showIconSourcePicker(ctx, controller),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              width: 60.r,
                              height: 60.r,
                              decoration: BoxDecoration(
                                color: AppColors.aliceBlue,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.fieldBorderColor,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 24.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Add',
                                    style: AppTextStyle.style_10_500(
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InkWell(
                              onTap: () => _showIconSourcePicker(ctx, controller),
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                width: 60.r,
                                height: 60.r,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: AppColors.fieldBorderColor,
                                    width: 1.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7.r),
                                  child: file != null
                                      ? Image.file(file, fit: BoxFit.contain)
                                      : AppImageView(
                                          imageUrl: url,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -6.r,
                              right: -6.r,
                              child: InkWell(
                                onTap: () => controller.clearIcon(),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.all(2.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 3.r,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.cancel,
                                    size: 16.sp,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 18.h),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppCommonButton(
                            text: 'Cancel',
                            variant: ButtonVariant.outline,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          SizedBox(width: 8.w),
                          Obx(
                            () => AppCommonButton(
                              text: isEdit ? 'Update' : 'Save',
                              isLoading: controller.isSubmitting.value,
                              onPressed: () async {
                                final amenityName =
                                    controller.amenityNameCtrl.text.trim();
                                if (amenityName.isEmpty) {
                                  AppCommonToastMessage.show(
                                    message: 'Amenity name is required',
                                    type: ToastType.error,
                                  );
                                  return;
                                }

                                final bool success = isEdit
                                    ? await controller.updateAmenity(
                                        id: amenityItem.id,
                                        amenityName: amenityName,
                                        iconFile: controller.selectedIconFile.value,
                                      )
                                    : await controller.createAmenity(
                                        amenityName: amenityName,
                                        iconFile: controller.selectedIconFile.value,
                                      );

                                if (success && ctx.mounted) {
                                  Navigator.pop(ctx);
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
            ],
          ),
        ),
      ),
    );
  }

  void _showIconSourcePicker(
    BuildContext context,
    AmenityController controller,
  ) {
    AppCommonBottomSheet.showModal(
      context,
      title: 'Select Photo Source',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickIcon(ImageSource.camera);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    decoration: BoxDecoration(
                      color: AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.fieldBorderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Camera',
                          style: AppTextStyle.style_13_600(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickIcon(ImageSource.gallery);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    decoration: BoxDecoration(
                      color: AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.fieldBorderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'File / Gallery',
                          style: AppTextStyle.style_13_600(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAmenity(
    BuildContext context,
    AmenityController controller,
    AmenityItem item,
  ) async {
    if (!_hasPermission(AppPermissions.masterPanel)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to delete amenities.',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Amenity',
      message: 'Are you sure you want to delete "${item.amenityName}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDanger: true,
    );

    if (confirmed) {
      await controller.deleteAmenity(item.id);
    }
  }
  // endregion
}
// endregion

