// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/master/controllers/unit_controller.dart';
// endregion

// region Dialog
class EditUnitManagerDialog extends StatelessWidget {
  const EditUnitManagerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UnitController>();

    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 620.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: 16.h),
                _buildFormFields(controller),
                SizedBox(height: 12.h),
                _buildLocationAction(controller),
                SizedBox(height: 16.h),
                _buildBottomButtons(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // region Header
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Edit Unit Manager Details',
          style: AppTextStyle.style_16_700(color: AppColors.grey500),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Icon(
              Icons.close,
              size: 20.sp,
              color: AppColors.grey300,
            ),
          ),
        ),
      ],
    );
  }
  // endregion

  // region Form Fields
  Widget _buildFormFields(UnitController controller) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPreferredDropdown(controller)),
            SizedBox(width: 10.w),
            Expanded(child: _buildTimingField(controller)),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildUnitAddressField(controller)),
            SizedBox(width: 10.w),
            Expanded(child: _buildFullAddressField(controller)),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLatitudeField(controller)),
            SizedBox(width: 10.w),
            Expanded(child: _buildLongitudeField(controller)),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferredDropdown(UnitController controller) {
    return Obx(
      () => AppCommonMultiSelectDropdown<String>(
        label: 'Highly Preferred',
        hint: 'Select',
        isSingleSelect: true,
        showSearch: false,
        selectedValues: {controller.preferredCtrl.value},
        items: const [
          DropdownMenuItem(value: '1', child: Text('Yes')),
          DropdownMenuItem(value: '0', child: Text('No')),
        ],
        onChanged: (values) {
          if (values.isNotEmpty) {
            controller.preferredCtrl.value = values.first;
          }
        },
      ),
    );
  }

  Widget _buildTimingField(UnitController controller) {
    return AppCommonTextField(
      controller: controller.timingCtrl,
      labelText: 'Timing',
      hintText: 'e.g. 8 A.M. to 8 P.M.',
    );
  }

  Widget _buildUnitAddressField(UnitController controller) {
    return AppCommonTextField(
      controller: controller.unitAddrCtrl,
      labelText: 'Unit Address',
      hintText: 'e.g. Puri',
    );
  }

  Widget _buildFullAddressField(UnitController controller) {
    return AppCommonTextField(
      controller: controller.fullAddrCtrl,
      labelText: 'Full Address',
      hintText: 'e.g. Near Swargadwar, Puri',
    );
  }

  Widget _buildLatitudeField(UnitController controller) {
    return AppCommonTextField(
      controller: controller.latCtrl,
      labelText: 'Latitude',
      hintText: '19.7983',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildLongitudeField(UnitController controller) {
    return AppCommonTextField(
      controller: controller.lngCtrl,
      labelText: 'Longitude',
      hintText: '85.8249',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
  // endregion

  // region Location Action
  Widget _buildLocationAction(UnitController controller) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(
        () => AppCommonButton(
          text: controller.isLocating.value
              ? 'Locating...'
              : 'Get Current Location',
          icon: controller.isLocating.value ? null : Icons.my_location,
          variant: ButtonVariant.outline,
          borderColor: AppColors.grey200,
          textColor: AppColors.black,
          textSize: 12.sp,
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          isLoading: controller.isLocating.value,
          onPressed: controller.isLocating.value
              ? null
              : () => controller.getCurrentLocation(),
        ),
      ),
    );
  }
  // endregion

  // region Bottom Buttons
  Widget _buildBottomButtons(
    BuildContext context,
    UnitController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppCommonButton(
          text: 'Cancel',
          variant: ButtonVariant.outline,
          borderColor: AppColors.grey200,
          textColor: AppColors.black,
          textSize: 12.sp,
          height: 36.h,
          width: 90.w,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SizedBox(width: 10.w),
        Obx(
          () => AppCommonButton(
            text: 'Update',
            buttonColor: const Color(0xFFF15A24),
            textColor: AppColors.white,
            textSize: 12.sp,
            height: 36.h,
            width: 100.w,
            isLoading: controller.isSubmitting.value,
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    final success =
                        await controller.updateUnitDetailsSubmit();
                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
          ),
        ),
      ],
    );
  }
  // endregion
}
// endregion

