// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/master/controllers/unit_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
// endregion

// region View
class UnitEditScreen extends StatelessWidget {
  const UnitEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<UnitController>()
        ? Get.find<UnitController>()
        : Get.put(UnitController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBasicDropdowns(controller),
                  SizedBox(height: 12.h),
                  _buildImagePickers(context, controller),
                  SizedBox(height: 12.h),
                  _buildStateDistrict(controller),
                  SizedBox(height: 12.h),
                  _buildLocationTiming(controller),
                  SizedBox(height: 12.h),
                  _buildFullAddress(controller),
                  SizedBox(height: 12.h),
                  _buildInaugurationDate(context, controller),
                  SizedBox(height: 14.h),
                  _buildAmenitiesSection(controller),
                  SizedBox(height: 14.h),
                  _buildDescriptionSpec(controller),
                  SizedBox(height: 20.h),
                  _buildActionButtons(context, controller),
                  SizedBox(height: 16.h),
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

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final controller = Get.isRegistered<UnitController>()
        ? Get.find<UnitController>()
        : Get.put(UnitController());
    return AppCommonAppBar(
      title: Obx(() {
        final isEdit = controller.selectedUnitForEdit.value != null;
        return Text(
          isEdit ? 'Edit Unit' : 'Create Unit',
          style: AppTextStyle.style_16_700(color: AppColors.black),
        );
      }),
      backgroundColor: AppColors.white,
      hasBackButton: true,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      onBackButtonPressed: () => Navigator.of(context).pop(),
    );
  }
  // endregion

  // region Section Builders - Dropdowns
  Widget _buildBasicDropdowns(UnitController controller) {
    final options = controller.unitOptions.value;

    final categoryItems = (options?.unitCategories ?? []).map((c) {
      return DropdownMenuItem<String>(
        value: c.unitcategory,
        child: Text(c.unitcategory, overflow: TextOverflow.ellipsis),
      );
    }).toList();

    // Fallback default category if not in options
    if (categoryItems.isEmpty && controller.editCategory.value.isNotEmpty) {
      categoryItems.add(DropdownMenuItem<String>(
        value: controller.editCategory.value,
        child: Text(controller.editCategory.value),
      ));
    }

    final categoryDropdown = Obx(
      () => AppCommonMultiSelectDropdown<String>(
        label: 'Unit Type (Category)',
        hint: 'Select Category',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: controller.editCategory.value.isNotEmpty
            ? {controller.editCategory.value}
            : (categoryItems.isNotEmpty
                ? {categoryItems.first.value!}
                : <String>{}),
        items: categoryItems,
        onChanged: (vals) {
          if (vals.isNotEmpty) controller.editCategory.value = vals.first;
        },
      ),
    );

    final serviceTypeDropdown = Obx(
      () => AppCommonMultiSelectDropdown<String>(
        label: 'Service Type',
        hint: 'Select Service Type',
        isSingleSelect: true,
        showSearch: false,
        selectedValues: {controller.editServiceType.value},
        items: const [
          DropdownMenuItem(value: 'Movable', child: Text('Movable')),
          DropdownMenuItem(value: 'Fixed', child: Text('Fixed')),
        ],
        onChanged: (vals) {
          if (vals.isNotEmpty) controller.editServiceType.value = vals.first;
        },
      ),
    );

    final unitTypeDropdown = Obx(
      () => AppCommonMultiSelectDropdown<String>(
        label: 'Service Name',
        hint: 'Select Service Name',
        isSingleSelect: true,
        showSearch: false,
        selectedValues: {controller.editUnitType.value},
        items: const [
          DropdownMenuItem(value: '1', child: Text('Retail (1)')),
          DropdownMenuItem(value: '0', child: Text('Rental (0)')),
          DropdownMenuItem(value: '2', child: Text('Other (2)')),
        ],
        onChanged: (vals) {
          if (vals.isNotEmpty) controller.editUnitType.value = vals.first;
        },
      ),
    );

    final yearDropdown = Obx(
      () => AppCommonMultiSelectDropdown<String>(
        label: 'Year of Delivery',
        hint: 'Select Year',
        isSingleSelect: true,
        showSearch: false,
        selectedValues: {controller.editYearOfDelivery.value},
        items: const [
          DropdownMenuItem(value: '25', child: Text('2025 (25)')),
          DropdownMenuItem(value: '26', child: Text('2026 (26)')),
          DropdownMenuItem(value: '27', child: Text('2027 (27)')),
          DropdownMenuItem(value: '24', child: Text('2024 (24)')),
        ],
        onChanged: (vals) {
          if (vals.isNotEmpty) controller.editYearOfDelivery.value = vals.first;
        },
      ),
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: categoryDropdown),
            SizedBox(width: 10.w),
            Expanded(child: serviceTypeDropdown),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: unitTypeDropdown),
            SizedBox(width: 10.w),
            Expanded(child: yearDropdown),
          ],
        ),
      ],
    );
  }
  // endregion

  // region Section Builders - Images
  Widget _buildImagePickers(BuildContext context, UnitController controller) {
    final singleImgCard = Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.aliceBlue,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.grey100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unit Image',
                style: AppTextStyle.style_12_600(color: AppColors.grey400),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  AppCommonButton(
                    text: 'Choose file',
                    variant: ButtonVariant.outline,
                    borderColor: AppColors.grey200,
                    textColor: AppColors.black,
                    textSize: 10.sp,
                    height: 28.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    onPressed: () => controller.pickSingleImage(),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() {
                      if (controller.selectedUnitImg.value != null) {
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: Image.file(
                                controller.selectedUnitImg.value!,
                                width: 32.r,
                                height: 32.r,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                controller.selectedUnitImg.value!.path
                                    .split(RegExp(r'[\\/]'))
                                    .last,
                                style: AppTextStyle.style_10_500(
                                    color: AppColors.grey400),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }
                      if (controller.existingUnitImgUrl.value != null &&
                          controller.existingUnitImgUrl.value!.isNotEmpty) {
                        return Row(
                          children: [
                            AppImageView(
                              imageUrl: controller.existingUnitImgUrl.value,
                              width: 32.r,
                              height: 32.r,
                              borderRadius: 6.r,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Current Image',
                                style: AppTextStyle.style_10_500(
                                    color: AppColors.grey300),
                              ),
                            ),
                          ],
                        );
                      }
                      return Text(
                        'No file chosen',
                        style: AppTextStyle.style_10_400(
                            color: AppColors.grey300),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        );

        final multiImgCard = Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.aliceBlue,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.grey100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gallery Images (Multi)',
                style: AppTextStyle.style_12_600(color: AppColors.grey400),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  AppCommonButton(
                    text: 'Choose files',
                    variant: ButtonVariant.outline,
                    borderColor: AppColors.grey200,
                    textColor: AppColors.black,
                    textSize: 10.sp,
                    height: 28.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    onPressed: () => controller.pickMultiImages(),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => Text(
                        '${controller.selectedMultiImgs.length} new, ${controller.existingGalleryUrls.length} existing',
                        style: AppTextStyle.style_10_500(color: AppColors.grey400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Previews Row
              Obx(() {
                if (controller.selectedMultiImgs.isEmpty &&
                    controller.existingGalleryUrls.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 40.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...controller.selectedMultiImgs.asMap().entries.map(
                        (entry) {
                          return Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Image.file(
                                    entry.value,
                                    width: 36.r,
                                    height: 36.r,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () => controller
                                        .removeSelectedMultiImage(entry.key),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(2.w),
                                      child: Icon(Icons.close,
                                          size: 10.sp, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      ...controller.existingGalleryUrls.asMap().entries.map(
                        (entry) {
                          return Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: Stack(
                              children: [
                                AppImageView(
                                  imageUrl: entry.value,
                                  width: 36.r,
                                  height: 36.r,
                                  borderRadius: 6.r,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () => controller
                                        .removeExistingGalleryImage(entry.key),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(2.w),
                                      child: Icon(Icons.close,
                                          size: 10.sp, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: singleImgCard),
            SizedBox(width: 10.w),
            Expanded(child: multiImgCard),
          ],
        );
  }
  // endregion

  // region Section Builders - State & District
  Widget _buildStateDistrict(UnitController controller) {
    final options = controller.unitOptions.value;

    final stateItems = (options?.states ?? []).map((s) {
      return DropdownMenuItem<String>(
        value: s.id.toString(),
        child: Text(s.stateName, overflow: TextOverflow.ellipsis),
      );
    }).toList();

    final stateDropdown = Obx(() {
      final currentVal = controller.editStateId.value;
      final validVal = stateItems.any((item) => item.value == currentVal)
          ? currentVal
          : (stateItems.isNotEmpty ? stateItems.first.value : null);

      return AppCommonMultiSelectDropdown<String>(
        label: 'State',
        hint: 'Select State',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: validVal != null ? {validVal} : <String>{},
        items: stateItems,
        onChanged: (vals) {
          if (vals.isNotEmpty) {
            controller.editStateId.value = vals.first;
          }
        },
      );
    });

    final districtDropdown = Obx(() {
      final selectedStateId =
          int.tryParse(controller.editStateId.value) ?? 0;
      final filteredDistricts = (options?.districts ?? [])
          .where((d) =>
              selectedStateId == 0 || d.stateId == selectedStateId)
          .toList();

      final districtItems = filteredDistricts.map((d) {
        return DropdownMenuItem<String>(
          value: d.id.toString(),
          child: Text(d.districtName, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      final currentVal = controller.editDistrictId.value;
      final validVal = districtItems.any((item) => item.value == currentVal)
          ? currentVal
          : (districtItems.isNotEmpty ? districtItems.first.value : null);

      return AppCommonMultiSelectDropdown<String>(
        label: 'District',
        hint: 'Select District',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: validVal != null ? {validVal} : <String>{},
        items: districtItems,
        onChanged: (vals) {
          if (vals.isNotEmpty) {
            controller.editDistrictId.value = vals.first;
          }
        },
      );
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: stateDropdown),
        SizedBox(width: 10.w),
        Expanded(child: districtDropdown),
      ],
    );
  }
  // endregion

  // region Section Builders - Location & Timing
  Widget _buildLocationTiming(UnitController controller) {
    final locField = AppCommonTextField(
      controller: controller.editLocationCtrl,
      labelText: 'Location',
      hintText: 'e.g. Puri',
    );
    final timingField = AppCommonTextField(
      controller: controller.editTimingCtrl,
      labelText: 'Timing',
      hintText: 'e.g. 9 A.M. to 9 P.M.',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: locField),
        SizedBox(width: 10.w),
        Expanded(child: timingField),
      ],
    );
  }

  Widget _buildFullAddress(UnitController controller) {
    return AppCommonTextField(
      controller: controller.editFullAddrCtrl,
      labelText: 'Full Address',
      hintText: 'Near Swargadwar, Puri',
      maxLines: 2,
    );
  }

  Widget _buildInaugurationDate(
    BuildContext context,
    UnitController controller,
  ) {
    return Obx(
      () => AppCommonDateField(
        labelText: 'Inauguration Date',
        selectedDate: controller.editIngDate.value,
        onDateSelected: (date) {
          controller.editIngDate.value = date;
        },
      ),
    );
  }
  // endregion

  // region Section Builders - Amenities Section
  Widget _buildAmenitiesSection(UnitController controller) {
    return Obx(() {
      final amenitiesList = controller.unitOptions.value?.amenities ?? [];
      if (amenitiesList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenities',
              style: AppTextStyle.style_14_700(color: AppColors.grey500),
            ),
            SizedBox(height: 8.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 32.h,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 6.h,
              ),
              itemCount: amenitiesList.length,
              itemBuilder: (context, index) {
                final item = amenitiesList[index];
                final isSelected =
                    controller.amenitySelections[item.id] ?? false.obs;
                final qtyCtrl = controller.amenityQuantities[item.id] ??
                    TextEditingController(text: '1');

                return Obx(
                  () => Row(
                    children: [
                      // Compact Mini Toggle Switch
                      InkWell(
                        onTap: () {
                          final next = !isSelected.value;
                          isSelected.value = next;
                          controller.amenitySelections[item.id] = next.obs;
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 26.w,
                          height: 15.h,
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: isSelected.value
                                ? const Color(0xFFF15A24)
                                : AppColors.grey200,
                          ),
                          alignment: isSelected.value
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 11.r,
                            height: 11.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          item.amenityName,
                          style: AppTextStyle.style_11_500(
                            color: isSelected.value
                                ? AppColors.black
                                : AppColors.grey400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      AppCommonTextField(
                        controller: qtyCtrl,
                        width: 36.w,
                        height: 24.h,
                        textAlign: TextAlign.center,
                        hintText: 'Qty',
                        keyboardType: TextInputType.number,
                        enabled: isSelected.value,
                        borderRadius: 4.r,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 2.h,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
  // endregion

  // region Section Builders - Description & Specification
  Widget _buildDescriptionSpec(UnitController controller) {
    return Column(
      children: [
        AppCommonTextField(
          controller: controller.editDescCtrl,
          labelText: 'Description',
          hintText: 'Enter unit description',
          maxLines: 4,
        ),
        SizedBox(height: 14.h),
        AppCommonTextField(
          controller: controller.editSpecCtrl,
          labelText: 'Specification',
          hintText: 'Enter unit specifications',
          maxLines: 4,
        ),
      ],
    );
  }
  // endregion

  // region Section Builders - Actions
  Widget _buildActionButtons(
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
          height: 38.h,
          width: 100.w,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SizedBox(width: 12.w),
        Obx(
          () {
            final isEdit = controller.selectedUnitForEdit.value != null;
            return AppCommonButton(
              text: isEdit ? 'Update' : 'Submit',
              buttonColor: const Color(0xFFF15A24),
              textColor: AppColors.white,
              textSize: 12.sp,
              height: 38.h,
              width: 110.w,
              isLoading: controller.isSubmitting.value,
              onPressed: controller.isSubmitting.value
                  ? null
                  : () async {
                      final success = await controller.submitUnit();
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
            );
          },
        ),
      ],
    );
  }
  // endregion
}
// endregion
