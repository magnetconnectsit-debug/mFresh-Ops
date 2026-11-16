// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_brands_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_brand_dialog.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region MContactBrandsTable Widget
class MContactBrandsTable extends StatelessWidget {
  // region Properties
  final MContactBrandsController controller;
  // endregion

  // region Constructor
  const MContactBrandsTable({super.key, required this.controller});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value && controller.brands.isEmpty;
      final items = controller.brands.toList();

      final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
      final canManage = userPermissions.contains(AppPermissions.brandDetails);

      final columns = <AppTableColumn<Map<String, dynamic>>>[
        AppTableColumn<Map<String, dynamic>>(
          key: 'id',
          title: '#',
          width: 60.w,
          sortable: false,
          alignment: Alignment.center,
          valueGetter: (b) => b['id']?.toString() ?? '',
          cellBuilder: (context, b, index, isExpanded) => Text(
            '${index + 1}',
            style: AppTextStyle.style_12_500(color: AppColors.black),
          ),
        ),
        AppTableColumn<Map<String, dynamic>>(
          key: 'name',
          title: 'Brand Name',
          width: 300.w,
          sortable: false,
          valueGetter: (b) => b['name']?.toString() ?? '',
          cellBuilder: (context, b, index, isExpanded) => Text(
            b['name']?.toString() ?? '-',
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        if (canManage)
          AppTableColumn<Map<String, dynamic>>(
            key: 'action',
            title: 'Action',
            width: 80.w,
            sortable: false,
            alignment: Alignment.center,
            cellBuilder: (context, brand, index, isExpanded) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.brandDetails)) {
                        AppCommonToastMessage.show(
                          message: 'You do not have permission to perform this action.',
                          type: ToastType.warning,
                        );
                        return;
                      }
                      await showMContactBrandDialog(
                        context,
                        controller,
                        brand: brand,
                      );
                      controller.fetchBrands();
                    },
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.edit_square,
                        size: 16.r,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () => _confirmDelete(context, brand),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        Icons.delete,
                        size: 16.r,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ];

      return AppRefreshIndicator(
        onRefresh: () async => controller.fetchBrands(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppCommonTable<Map<String, dynamic>>(
            items: items,
            columns: columns,
            isLoading: isLoading,
            headingRowColor: AppColors.aliceBlue,
            headingTextStyle: AppTextStyle.style_12_700(color: AppColors.black),
            dataTextStyle: AppTextStyle.style_12_500(color: AppColors.black),
            borderColor: AppColors.borderColor,
            headingRowHeight: 28.h,
            cellVerticalPadding: 6.h,
            cellHorizontalPadding: 8.w,
            enableColumnResizing: false,
            emptyText: 'No brands found.',
          ),
        ),
      );
    });
  }
  // endregion

  // region Actions & Confirmation
  Future<void> _confirmDelete(
    BuildContext context,
    Map<String, dynamic> brand,
  ) async {
    if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.brandDetails)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    final brandId = brand['id'] as int?;
    final brandName = brand['name']?.toString() ?? 'this brand';

    if (brandId == null) return;

    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Delete Brand',
      message: 'Are you sure you want to delete "$brandName"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed) {
      await controller.deleteBrand(brandId);
    }
  }
  // endregion
}
// endregion
