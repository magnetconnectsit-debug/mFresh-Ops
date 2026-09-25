import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_audit_controller.dart';

void showAddAdditionalItemDialog(
    BuildContext context, InventoryAuditController controller) {
  final itemNameCtrl = TextEditingController();
  final actualQtyCtrl = TextEditingController();
  final selectedMeasurementId = ''.obs;

  Get.dialog(
    Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
        side: const BorderSide(color: AppColors.grey50, width: 1),
      ),
      insetPadding: EdgeInsets.all(20.r),
      child: SizedBox(
        width: 380.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF009BD9),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(3.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Additional Audit Item',
                      style: AppTextStyle.style_14_600(color: Colors.white),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      child: Icon(Icons.close, color: Colors.white, size: 18.r),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    Text(
                      'Item Name *',
                      style:
                          AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: itemNameCtrl,
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: 'e.g. Floor Cleaning Brush',
                        hintStyle: AppTextStyle.style_12_400(
                            color: Colors.grey.shade400),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide:
                              const BorderSide(color: Color(0xFF009BD9)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Measurement Unit Dropdown
                    Text(
                      'Measurement Unit *',
                      style:
                          AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                    SizedBox(height: 4.h),
                    Obx(() {
                      return MultiSelectDropdownWidget<String>(
                        isSingleSelect: true,
                        selectedValues: selectedMeasurementId.value.isNotEmpty
                            ? {selectedMeasurementId.value}
                            : {},
                        items: controller.measurementOptions
                            .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(
                                  e.label,
                                  style: AppTextStyle.style_12_400(
                                      color: AppColors.black),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (set) {
                          if (set.isNotEmpty) {
                            selectedMeasurementId.value = set.first;
                          } else {
                            selectedMeasurementId.value = '';
                          }
                        },
                        hint: 'Select measurement unit',
                      );
                    }),
                    SizedBox(height: 12.h),

                    // Actual Quantity
                    Text(
                      'Actual Quantity *',
                      style:
                          AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: actualQtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: 'e.g. 4',
                        hintStyle: AppTextStyle.style_12_400(
                            color: Colors.grey.shade400),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide:
                              const BorderSide(color: Color(0xFF009BD9)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.style_12_500(
                                color: AppColors.black),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: () {
                            final name = itemNameCtrl.text.trim();
                            if (name.isEmpty) {
                              AppCommonToastMessage.show(
                                  message: 'Please enter item name.',
                                  type: ToastType.error);
                              return;
                            }
                            if (selectedMeasurementId.value.isEmpty) {
                              AppCommonToastMessage.show(
                                  message: 'Please select a measurement unit.',
                                  type: ToastType.error);
                              return;
                            }
                            final qtyStr = actualQtyCtrl.text.trim();
                            final qty = double.tryParse(qtyStr);
                            if (qtyStr.isEmpty || qty == null) {
                              AppCommonToastMessage.show(
                                  message:
                                      'Please enter a valid actual quantity.',
                                  type: ToastType.error);
                              return;
                            }

                            final unitIdInt =
                                int.tryParse(selectedMeasurementId.value) ?? 0;
                            final unitOpt =
                                controller.measurementOptions.firstWhereOrNull(
                              (opt) => opt.value == selectedMeasurementId.value,
                            );
                            final unitName = unitOpt?.label ?? '';

                            controller.addAdditionalItem(
                              AdditionalAuditItem(
                                itemName: name,
                                measurementUnitId: unitIdInt,
                                measurementUnitName: unitName,
                                actualQty: qty,
                              ),
                            );

                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009BD9),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          child: Text(
                            'Add Item',
                            style:
                                AppTextStyle.style_12_600(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
