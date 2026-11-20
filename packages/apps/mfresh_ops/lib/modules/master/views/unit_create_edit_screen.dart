// region Imports
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/master/controllers/unit_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
// endregion

// region View
class UnitCreateEditScreen extends StatelessWidget {
  const UnitCreateEditScreen({super.key});

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
                  SizedBox(height: 10.h),
                  _buildStateDistrict(controller),
                  SizedBox(height: 10.h),
                  _buildLocationTiming(context, controller),
                  SizedBox(height: 10.h),
                  _buildFullAddress(controller),
                  SizedBox(height: 10.h),
                  _buildInaugurationDate(context, controller),
                  SizedBox(height: 10.h),
                  _buildImagePickers(context, controller),
                  SizedBox(height: 12.h),
                  _buildAmenitiesSection(controller),
                  SizedBox(height: 14.h),
                  _buildDescriptionSpec(controller),
                  SizedBox(height: 16.h),
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
  // endregion

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
    return Obx(() {
      final options = controller.unitOptions.value;

      // 1. Unit Type (Category)
      final categoryItems = (options?.unitCategories ?? []).map((c) {
        final val = c.unitcategory.trim();
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      if (controller.editCategory.value.isNotEmpty &&
          !categoryItems.any((item) => item.value == controller.editCategory.value)) {
        categoryItems.add(DropdownMenuItem<String>(
          value: controller.editCategory.value,
          child: Text(controller.editCategory.value),
        ));
      }

      final categoryDropdown = AppCommonMultiSelectDropdown<String>(
        label: 'Unit Type',
        hint: 'Select',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: controller.editCategory.value.isNotEmpty
            ? {controller.editCategory.value}
            : <String>{},
        items: categoryItems,
        onChanged: (vals) {
          controller.editCategory.value = vals.isNotEmpty ? vals.first : '';
        },
      );

      // 2. Service Type (Retail / Rental)
      final serviceTypeItems = (options?.serviceTypes ?? []).map((t) {
        return DropdownMenuItem<String>(
          value: t.label,
          child: Text(t.label, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      if (serviceTypeItems.isEmpty) {
        serviceTypeItems.addAll([
          const DropdownMenuItem(value: 'Retail', child: Text('Retail')),
          const DropdownMenuItem(value: 'Rental', child: Text('Rental')),
        ]);
      }

      final serviceTypeDropdown = AppCommonMultiSelectDropdown<String>(
        label: 'Service Type',
        hint: 'Select',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: controller.editServiceType.value.isNotEmpty
            ? {controller.editServiceType.value}
            : <String>{},
        items: serviceTypeItems,
        onChanged: (vals) {
          controller.editServiceType.value = vals.isNotEmpty ? vals.first : '';
        },
      );

      // 3. Service Name (Movable / Fixed from API service_name)
      final serviceNameItems = (options?.serviceNames ?? []).map((n) {
        return DropdownMenuItem<String>(
          value: n.value,
          child: Text(n.label, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      if (serviceNameItems.isEmpty) {
        serviceNameItems.addAll([
          const DropdownMenuItem(value: 'Movable', child: Text('Movable')),
          const DropdownMenuItem(value: 'Fixed', child: Text('Fixed')),
        ]);
      }

      final serviceNameDropdown = AppCommonMultiSelectDropdown<String>(
        label: 'Service Name',
        hint: 'Select',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: controller.editServiceName.value.isNotEmpty
            ? {controller.editServiceName.value}
            : <String>{},
        items: serviceNameItems,
        onChanged: (vals) {
          controller.editServiceName.value = vals.isNotEmpty ? vals.first : '';
        },
      );

      // 4. Year of Delivery (YearPickerField)
      final yearPicker = YearPickerField(
        label: 'Year of Delivery',
        hintText: 'Select',
        showFloatingLabel: true,
        value: controller.editYearOfDelivery.value.isNotEmpty
            ? controller.editYearOfDelivery.value
            : null,
        onChanged: (val) {
          controller.editYearOfDelivery.value = val ?? '';
        },
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
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: serviceNameDropdown),
              SizedBox(width: 10.w),
              Expanded(child: yearPicker),
            ],
          ),
        ],
      );
    });
  }
  // endregion

  // region Section Builders - State & District
  Widget _buildStateDistrict(UnitController controller) {
    return Obx(() {
      final options = controller.unitOptions.value;

      final stateItems = (options?.states ?? []).map((s) {
        return DropdownMenuItem<String>(
          value: s.id.toString(),
          child: Text(s.stateName, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      final currentVal = controller.editStateId.value;
      final validStateVal = currentVal.isNotEmpty &&
              stateItems.any((item) => item.value == currentVal)
          ? currentVal
          : null;

      final stateDropdown = AppCommonMultiSelectDropdown<String>(
        label: 'State',
        hint: 'Select State',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: validStateVal != null ? {validStateVal} : <String>{},
        items: stateItems,
        onChanged: (vals) {
          if (vals.isNotEmpty) {
            controller.editStateId.value = vals.first;
            controller.editDistrictId.value = '';
          } else {
            controller.editStateId.value = '';
            controller.editDistrictId.value = '';
          }
        },
      );

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

      final currentDistVal = controller.editDistrictId.value;
      final validDistVal = currentDistVal.isNotEmpty &&
              districtItems.any((item) => item.value == currentDistVal)
          ? currentDistVal
          : null;

      final districtDropdown = AppCommonMultiSelectDropdown<String>(
        label: 'District',
        hint: 'Select District',
        isSingleSelect: true,
        showSearch: true,
        selectedValues: validDistVal != null ? {validDistVal} : <String>{},
        items: districtItems,
        onChanged: (vals) {
          controller.editDistrictId.value = vals.isNotEmpty ? vals.first : '';
        },
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: stateDropdown),
          SizedBox(width: 10.w),
          Expanded(child: districtDropdown),
        ],
      );
    });
  }
  // endregion

  // region Section Builders - Location & Timing
  Widget _buildLocationTiming(
    BuildContext context,
    UnitController controller,
  ) {
    final locField = AppCommonTextField(
      controller: controller.editLocationCtrl,
      labelText: 'Location',
      hintText: 'Location',
    );
    final timingField = AppCommonTimeField(
      controller: controller.editTimingCtrl,
      labelText: 'Timing',
      hintText: 'Timing',
      alwaysUse24HourFormat: false,
      helpText: 'Select Timing',
      onTimeSelected: (time) {
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
        controller.editTimingCtrl.text = '$hour:$minute $period';
      },
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
  // endregion

  // region Section Builders - Full Address
  Widget _buildFullAddress(UnitController controller) {
    return AppCommonTextField(
      controller: controller.editFullAddrCtrl,
      labelText: 'Full Address',
      hintText: 'Full Address',
      maxLines: 2,
    );
  }
  // endregion

  // region Section Builders - Inauguration Date
  Widget _buildInaugurationDate(
    BuildContext context,
    UnitController controller,
  ) {
    return Obx(
      () => AppCommonDateField(
        labelText: 'Inauguration Date',
        hintText: 'Select date',
        selectedDate: controller.editIngDate.value,
        onDateSelected: (date) {
          controller.editIngDate.value = date;
        },
      ),
    );
  }
  // endregion

  // region Section Builders - Image Pickers
  Widget _buildImagePickers(BuildContext context, UnitController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Unit Image
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showPhotoSourceOptions(
                  context,
                  onCamera: () =>
                      controller.pickSingleImage(source: ImageSource.camera),
                  onGallery: () =>
                      controller.pickSingleImage(source: ImageSource.gallery),
                ),
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  height: 32.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: AppColors.aliceBlue,
                    border: Border.all(color: AppColors.fieldBorderColor),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.grey700,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Unit Image',
                          style: AppTextStyle.style_12_500(
                            color: AppColors.grey700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Obx(() {
                        final hasImg = controller.selectedUnitImg.value !=
                                null ||
                            (controller.existingUnitImgUrl.value != null &&
                                controller.existingUnitImgUrl.value!.isNotEmpty &&
                                !controller.existingUnitImgUrl.value!.endsWith('/NA') &&
                                controller.existingUnitImgUrl.value != 'NA');
                        if (!hasImg) return const SizedBox.shrink();
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '1',
                            style: AppTextStyle.style_10_600(
                              color: AppColors.white,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              _buildUnitImagePreview(context, controller),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        // Right Column: Gallery Images
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showPhotoSourceOptions(
                  context,
                  onCamera: () =>
                      controller.pickMultiImages(source: ImageSource.camera),
                  onGallery: () =>
                      controller.pickMultiImages(source: ImageSource.gallery),
                ),
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  height: 32.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: AppColors.aliceBlue,
                    border: Border.all(color: AppColors.fieldBorderColor),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.grey700,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Gallery Images',
                          style: AppTextStyle.style_12_500(
                            color: AppColors.grey700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Obx(() {
                        final count = controller.selectedMultiImgs.length +
                            controller.existingGalleryUrls.length;
                        if (count == 0) return const SizedBox.shrink();
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$count',
                            style: AppTextStyle.style_10_600(
                              color: AppColors.white,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              _buildGalleryImagesPreview(context, controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitImagePreview(
    BuildContext context,
    UnitController controller,
  ) {
    return Obx(() {
      final file = controller.selectedUnitImg.value;
      final url = controller.existingUnitImgUrl.value;
      final hasUrl = url != null &&
          url.isNotEmpty &&
          !url.endsWith('/NA') &&
          url != 'NA';

      if (file == null && !hasUrl) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                AppImageView.showGalleryViewer(
                  context,
                  images: [
                    AppGalleryImageSource(
                      file: file,
                      url: hasUrl ? url : null,
                      title: 'Unit Image',
                    ),
                  ],
                  initialIndex: 0,
                  title: 'Unit Image',
                );
              },
              child: Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: file != null
                      ? Image.file(file, fit: BoxFit.cover)
                      : AppImageView(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: 50.r,
                          height: 50.r,
                        ),
                ),
              ),
            ),
            Positioned(
              right: -4.w,
              top: -4.h,
              child: InkWell(
                onTap: () {
                  controller.selectedUnitImg.value = null;
                  controller.existingUnitImgUrl.value = null;
                },
                child: CircleAvatar(
                  radius: 8.r,
                  backgroundColor: AppColors.red,
                  child: Icon(
                    Icons.close,
                    size: 9.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGalleryImagesPreview(
    BuildContext context,
    UnitController controller,
  ) {
    return Obx(() {
      final List<_GalleryImageItem> items = [];

      // Newly picked local files
      for (int i = 0; i < controller.selectedMultiImgs.length; i++) {
        final idx = i;
        items.add(
          _GalleryImageItem(
            file: controller.selectedMultiImgs[i],
            onRemove: () => controller.removeSelectedMultiImage(idx),
          ),
        );
      }

      // Existing remote URLs
      for (int i = 0; i < controller.existingGalleryUrls.length; i++) {
        final idx = i;
        final u = controller.existingGalleryUrls[i];
        if (u.isNotEmpty && !u.endsWith('/NA') && u != 'NA') {
          items.add(
            _GalleryImageItem(
              url: u,
              onRemove: () => controller.removeExistingGalleryImage(idx),
            ),
          );
        }
      }

      final total = items.length;
      if (total == 0) return const SizedBox.shrink();

      final allSources = items.map((e) {
        return AppGalleryImageSource(
          file: e.file,
          url: e.url,
          title: 'Gallery Image',
        );
      }).toList();

      Widget buildThumb(int index, {int? overlayCount}) {
        final item = items[index];
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                AppImageView.showGalleryViewer(
                  context,
                  images: allSources,
                  initialIndex: index,
                  title: 'Gallery Image',
                  onDelete: (delIdx) {
                    if (delIdx >= 0 && delIdx < items.length) {
                      items[delIdx].onRemove();
                    }
                  },
                );
              },
              child: Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.file != null)
                        Image.file(item.file!, fit: BoxFit.cover)
                      else
                        AppImageView(
                          imageUrl: item.url,
                          fit: BoxFit.cover,
                          width: 50.r,
                          height: 50.r,
                        ),
                      if (overlayCount != null && overlayCount > 0)
                        Container(
                          color: Colors.black.withValues(alpha: 0.60),
                          alignment: Alignment.center,
                          child: Text(
                            '+$overlayCount',
                            style: AppTextStyle.style_14_700(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -4.w,
              top: -4.h,
              child: InkWell(
                onTap: item.onRemove,
                child: CircleAvatar(
                  radius: 8.r,
                  backgroundColor: AppColors.red,
                  child: Icon(
                    Icons.close,
                    size: 9.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      if (total == 1) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: buildThumb(0),
        );
      } else if (total == 2) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Row(
            children: [
              buildThumb(0),
              SizedBox(width: 8.w),
              buildThumb(1),
            ],
          ),
        );
      } else {
        // total > 2: Show thumb 0, and thumb 1 with "+(total - 2)" overlay (e.g. +4)
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Row(
            children: [
              buildThumb(0),
              SizedBox(width: 8.w),
              buildThumb(1, overlayCount: total - 2),
            ],
          ),
        );
      }
    });
  }
  // endregion

  // region Section Builders - Amenities Section
  Widget _buildAmenitiesSection(UnitController controller) {
    return Obx(() {
      final amenitiesList = controller.unitOptions.value?.amenities ?? [];
      if (amenitiesList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: AppTextStyle.style_16_700(color: AppColors.grey900),
          ),
          SizedBox(height: 6.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: amenitiesList.length,
            separatorBuilder: (context, index) => SizedBox(height: 4.h),
            itemBuilder: (context, index) {
              final item = amenitiesList[index];
              final isSelected =
                  controller.amenitySelections[item.id] ?? false.obs;
              final qtyCtrl = controller.getAmenityQtyController(item.id);

              return Obx(
                () => Row(
                  children: [
                    // Toggle Switch
                    InkWell(
                      onTap: () {
                        final next = !isSelected.value;
                        isSelected.value = next;
                        controller.amenitySelections[item.id] = next.obs;
                        if (!next) {
                          qtyCtrl.text = '0';
                        } else if (qtyCtrl.text.isEmpty) {
                          qtyCtrl.text = '0';
                        }
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
                              ? AppColors.primary
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
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        item.amenityName,
                        style: AppTextStyle.style_12_500(
                          color: isSelected.value
                              ? AppColors.black
                              : AppColors.grey800,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AppCommonTextField(
                      controller: qtyCtrl,
                      width: 52.w,
                      height: 24.h,
                      textAlign: TextAlign.center,
                      hintText: 'Qty',
                      keyboardType: TextInputType.number,
                      enabled: isSelected.value,
                      borderRadius: 4.r,
                      borderColor: isSelected.value
                          ? AppColors.primary
                          : AppColors.fieldBorderColor,
                      borderWidth: isSelected.value ? 1.4 : 1.0,
                      fillColor: isSelected.value
                          ? AppColors.white
                          : AppColors.aliceBlue,
                      style: AppTextStyle.style_11_500(
                        color: AppColors.black,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
          maxLines: 3,
        ),
        SizedBox(height: 10.h),
        AppCommonTextField(
          controller: controller.editSpecCtrl,
          labelText: 'Specification',
          hintText: 'Enter unit specifications',
          maxLines: 3,
        ),
      ],
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  void _showPhotoSourceOptions(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
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
                    onCamera();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.fieldBorderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primary,
                          size: 26.sp,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Camera',
                          style: AppTextStyle.style_12_600(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onGallery();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.fieldBorderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: AppColors.primary,
                          size: 26.sp,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Gallery',
                          style: AppTextStyle.style_12_600(
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
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

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
              buttonColor: AppColors.primary,
              textColor: AppColors.white,
              textSize: 12.sp,
              height: 38.h,
              width: 110.w,
              isLoading: controller.isSubmitting.value,
              onPressed: controller.isSubmitting.value
                  ? null
                  : () async {
                      if (!_hasPermission(AppPermissions.masterPanel)) {
                        AppCommonToastMessage.show(
                          message:
                              'You do not have permission to manage units.',
                          type: ToastType.warning,
                        );
                        return;
                      }
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

// region Gallery Image Helper Item
class _GalleryImageItem {
  final File? file;
  final String? url;
  final VoidCallback onRemove;

  _GalleryImageItem({
    this.file,
    this.url,
    required this.onRemove,
  });
}
// endregion
// endregion
