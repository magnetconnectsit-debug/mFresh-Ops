// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/master/assign_service_model.dart';
import 'package:mfresh_ops/modules/master/controllers/assign_service_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
// endregion

// region AssignServiceCreateEditScreen
class AssignServiceCreateEditScreen extends StatefulWidget {
  const AssignServiceCreateEditScreen({super.key});

  @override
  State<AssignServiceCreateEditScreen> createState() =>
      _AssignServiceCreateEditScreenState();
}

class _AssignServiceCreateEditScreenState
    extends State<AssignServiceCreateEditScreen> {
  final AssignServiceController controller = Get.find<AssignServiceController>();
  bool _renderAll = false;

  @override
  void initState() {
    super.initState();
    // Fast progressive rendering: allow frame 0 to paint immediately for instant navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _renderAll = true;
        });
      }
    });
  }

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCardContainer(context, controller),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
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
    AssignServiceController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      hasBackButton: true,
      title: Obx(() {
        final isEdit = controller.isEditMode.value;
        final unitQr = controller.selectedUnitQr.value;
        return Text(
          isEdit ? 'Edit Assign Service ($unitQr)' : 'Create Assign Service',
          style: AppTextStyle.style_16_600(color: AppColors.black),
        );
      }),
      topHeader: const CommonShortcutHeader(),
    );
  }
  // endregion

  // region Section Builders - Main Card Container
  Widget _buildCardContainer(
    BuildContext context,
    AssignServiceController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            if (controller.isEditMode.value) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUnitSelectorRow(controller),
                SizedBox(height: 14.h),
              ],
            );
          }),
          _buildMatrixTable(context, controller),
          SizedBox(height: 14.h),
          _buildBottomActionRow(controller),
        ],
      ),
    );
  }

  Widget _buildUnitSelectorRow(AssignServiceController controller) {
    return Obx(() {
      final isEdit = controller.isEditMode.value;

      if (isEdit) {
        return const SizedBox.shrink();
      }

      final unitOptions = controller.units
          .map((u) => DropdownMenuItem<String>(
                value: u.qrcodeId,
                child: Text(
                  '${u.qrcodeId} (${u.unitcategory ?? 'Vehicle'})',
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList();

      final selectedValue = controller.selectedUnitQr.value.isNotEmpty
          ? controller.selectedUnitQr.value
          : null;

      return SizedBox(
        width: 280.w,
        child: AppCommonMultiSelectDropdown<String>(
          isSingleSelect: true,
          label: 'Select Unit *',
          hint: 'Select',
          items: unitOptions,
          selectedValues: selectedValue != null ? {selectedValue} : {},
          onChanged: (selected) {
            if (selected.isNotEmpty) {
              controller.selectedUnitQr.value = selected.first;
            } else {
              controller.selectedUnitQr.value = '';
            }
          },
        ),
      );
    });
  }
  // endregion

  // region Table Section Builders
  Widget _buildMatrixTable(
    BuildContext context,
    AssignServiceController controller,
  ) {
    return Obx(() {
      final isEdit = controller.isEditMode.value;
      final groups = controller.serviceGroups;
      final double tableWidth = isEdit ? 870.w : 775.w;
      final displayCount =
          (_renderAll || groups.length <= 3) ? groups.length : 3;

      // Compute service dropdown options once per table build
      final serviceOptions = controller.services
          .map((s) => DropdownMenuItem<int>(
                value: s.id,
                child: Text(
                  s.servicesName,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeader(isEdit),
              ...List.generate(displayCount, (gIndex) {
                final group = groups[gIndex];
                final isLast = gIndex == displayCount - 1;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceGroupRow(
                      context,
                      controller,
                      gIndex,
                      group,
                      isEdit,
                      groups.length,
                      serviceOptions,
                    ),
                    if (!isLast)
                      Container(
                        width: tableWidth,
                        height: 2.h,
                        color: Colors.black,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTableHeader(bool isEdit) {
    return Container(
      color: const Color(0xFFE4EDF7),
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          _buildHeaderCell('Services', width: 140.w),
          _buildHeaderCell('Service For', width: 100.w),
          _buildHeaderCell('Mode', width: 85.w),
          _buildHeaderCell('Gross Price', width: 85.w),
          _buildHeaderCell('GST', width: 75.w),
          _buildHeaderCell('Net Amt', width: 85.w),
          _buildHeaderCell('Charge Type', width: 85.w),
          _buildHeaderCell('Order', width: 65.w),
          if (isEdit) _buildHeaderCell('Status', width: 95.w),
          _buildHeaderCell('Action', width: 55.w),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          title,
          style: AppTextStyle.style_11_700(color: const Color(0xFF1B2559)),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildServiceGroupRow(
    BuildContext context,
    AssignServiceController controller,
    int groupIndex,
    AssignedServiceGroup group,
    bool isEdit,
    int totalGroups,
    List<DropdownMenuItem<int>> serviceOptions,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Service dropdown + Icon Preview
        Container(
          width: 140.w,
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppCommonMultiSelectDropdown<int>(
                isSingleSelect: true,
                showSearch: true,
                label: 'Service',
                hint: 'Select',
                items: serviceOptions,
                selectedValues: group.serviceId != null && group.serviceId! > 0
                    ? {group.serviceId!}
                    : {},
                onChanged: (selected) {
                  final sId = selected.isNotEmpty ? selected.first : null;
                  controller.onServiceSelected(groupIndex, sId);
                },
              ),
              SizedBox(height: 6.h),
              if (group.iconUrl != null &&
                  group.iconUrl!.isNotEmpty &&
                  !group.iconUrl!.endsWith('/NA') &&
                  group.iconUrl != 'NA')
                AppImageView(
                  imageUrl: group.iconUrl!,
                  width: 44.r,
                  height: 44.r,
                  fit: BoxFit.contain,
                )
              else
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.aliceBlue,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Icon(
                    Icons.miscellaneous_services_outlined,
                    size: 24.sp,
                    color: AppColors.grey400,
                  ),
                ),
            ],
          ),
        ),
        // Middle Matrix Rows (4 sub-rows)
        Column(
          children: List.generate(group.rows.length, (rowIndex) {
            final row = group.rows[rowIndex];
            return _buildMatrixSubRow(
              controller,
              groupIndex,
              rowIndex,
              row,
              isEdit,
            );
          }),
        ),
        // Right Action Column
        Container(
          width: 55.w,
          alignment: Alignment.center,
          child: _buildActionCell(
            context,
            controller,
            groupIndex,
            isEdit,
            totalGroups,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCell(
    BuildContext context,
    AssignServiceController controller,
    int groupIndex,
    bool isEdit,
    int totalGroups,
  ) {
    if (isEdit) {
      return _buildRemoveButton(context, controller, groupIndex);
    }

    // In create mode:
    if (totalGroups == 1) {
      return _buildAddButton(controller);
    }

    // Multiple groups in create mode:
    if (groupIndex == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAddButton(controller),
          SizedBox(height: 6.h),
          _buildRemoveButton(context, controller, groupIndex),
        ],
      );
    } else {
      return _buildRemoveButton(context, controller, groupIndex);
    }
  }

  Widget _buildAddButton(AssignServiceController controller) {
    return InkWell(
      onTap: () => controller.addServiceGroup(),
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: 22.h,
        height: 22.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          Icons.add,
          size: 13.sp,
          color: AppColors.grey700,
        ),
      ),
    );
  }

  Widget _buildRemoveButton(
    BuildContext context,
    AssignServiceController controller,
    int groupIndex,
  ) {
    return InkWell(
      onTap: () => _handleRemoveServiceGroup(context, controller, groupIndex),
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: 22.h,
        height: 22.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          Icons.remove,
          size: 13.sp,
          color: AppColors.grey700,
        ),
      ),
    );
  }

  Widget _buildMatrixSubRow(
    AssignServiceController controller,
    int groupIndex,
    int rowIndex,
    AssignedServiceRow row,
    bool isEdit,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          // Service For
          Container(
            width: 100.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              height: 24.h,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: AppColors.aliceBlue,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.7),
                ),
              ),
              child: Text(
                row.serviceForLabel,
                style: AppTextStyle.style_11_500(color: AppColors.grey800),
              ),
            ),
          ),
          // Mode with compact icon
          Container(
            width: 85.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              height: 24.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppColors.aliceBlue,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.modeLabel,
                    style: AppTextStyle.style_11_500(color: AppColors.grey800),
                  ),
                  Icon(
                    row.payType == 1
                        ? Icons.payments_outlined
                        : Icons.credit_card_outlined,
                    size: 13.sp,
                    color: row.payType == 1
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                  ),
                ],
              ),
            ),
          ),
          // Gross Price
          Container(
            width: 85.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: AppCommonTextField(
              controller: controller.getGrossPriceController(groupIndex, rowIndex),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: '',
              onChanged: (_) =>
                  controller.calculateNetAmount(groupIndex, rowIndex),
            ),
          ),
          // GST
          Container(
            width: 75.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: AppCommonTextField(
              controller: controller.getGstController(groupIndex, rowIndex),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: '',
              onChanged: (_) =>
                  controller.calculateNetAmount(groupIndex, rowIndex),
            ),
          ),
          // Net Amt
          Container(
            width: 85.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: AppCommonTextField(
              controller: controller.getNetAmountController(groupIndex, rowIndex),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: '',
            ),
          ),
          // Charge Type
          Container(
            width: 85.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: AppCommonTextField(
              controller:
                  controller.getChargeTypeController(groupIndex, rowIndex),
              hintText: '',
            ),
          ),
          // Order
          Container(
            width: 65.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: AppCommonTextField(
              controller: controller.getOrderController(groupIndex, rowIndex),
              keyboardType: TextInputType.number,
              hintText: '',
            ),
          ),
          // Status (Edit Mode)
          if (isEdit)
            Container(
              width: 95.w,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SizedBox(
                height: 24.h,
                child: AppCommonMultiSelectDropdown<int>(
                  isSingleSelect: true,
                  hint: 'Active',
                  items: const [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('Active', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text('Inactive', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  selectedValues: {row.status},
                  onChanged: (selected) {
                    if (selected.isNotEmpty) {
                      row.status = selected.first;
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionRow(AssignServiceController controller) {
    return Obx(() {
      final isEdit = controller.isEditMode.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isEdit)
            AppCommonButton(
              text: '+ Add Service',
              onPressed: () => controller.addServiceGroup(),
            )
          else
            const SizedBox.shrink(),
          AppCommonButton(
            text: isEdit ? 'Update' : 'Save',
            buttonColor: AppColors.primary,
            onPressed: () {
              if (isEdit) {
                controller.submitUpdate();
              } else {
                controller.submitCreate();
              }
            },
          ),
        ],
      );
    });
  }
  // endregion

  // region Action Handlers & Dialogs
  Future<void> _handleRemoveServiceGroup(
    BuildContext context,
    AssignServiceController controller,
    int groupIndex,
  ) async {
    final bool confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Remove Service',
      message: 'Are you sure you want to remove this assigned service group?',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      confirmButtonColor: AppColors.error,
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
    );
    if (confirmed) {
      controller.removeServiceGroup(groupIndex);
    }
  }
  // endregion
}
// endregion
