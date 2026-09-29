import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
                child: _AddAdditionalItemBody(
                  controller: controller,
                  itemNameCtrl: itemNameCtrl,
                  actualQtyCtrl: actualQtyCtrl,
                  selectedMeasurementId: selectedMeasurementId,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AddAdditionalItemBody extends StatefulWidget {
  final InventoryAuditController controller;
  final TextEditingController itemNameCtrl;
  final TextEditingController actualQtyCtrl;
  final RxString selectedMeasurementId;

  const _AddAdditionalItemBody({
    required this.controller,
    required this.itemNameCtrl,
    required this.actualQtyCtrl,
    required this.selectedMeasurementId,
  });

  @override
  State<_AddAdditionalItemBody> createState() => _AddAdditionalItemBodyState();
}

class _AddAdditionalItemBodyState extends State<_AddAdditionalItemBody> {
  final List<File> _pickedImages = [];

  Future<void> _pickImages(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final List<XFile> files = await picker.pickMultiImage(imageQuality: 80);
        if (files.isNotEmpty) {
          setState(() {
            for (final f in files) {
              _pickedImages.add(File(f.path));
            }
          });
        }
      } else {
        final XFile? image =
            await picker.pickImage(source: source, imageQuality: 80);
        if (image != null) {
          setState(() => _pickedImages.add(File(image.path)));
        }
      }
    } catch (_) {
      AppCommonToastMessage.show(
          message: 'Failed to pick image.', type: ToastType.error);
    }
  }

  void _removeImageAt(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item Name *',
            style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 4.h),
        _textField(widget.itemNameCtrl, 'e.g. Floor Cleaning Brush'),
        SizedBox(height: 12.h),

        Text('Measurement Unit *',
            style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 4.h),
        Obx(() => MultiSelectDropdownWidget<String>(
              isSingleSelect: true,
              selectedValues: widget.selectedMeasurementId.value.isNotEmpty
                  ? {widget.selectedMeasurementId.value}
                  : {},
              items: widget.controller.measurementOptions
                  .map<DropdownMenuItem<String>>(
                    (e) => DropdownMenuItem<String>(
                      value: e.value,
                      child: Text(e.label,
                          style: AppTextStyle.style_12_400(
                              color: AppColors.black)),
                    ),
                  )
                  .toList(),
              onChanged: (set) {
                widget.selectedMeasurementId.value =
                    set.isNotEmpty ? set.first : '';
              },
              hint: 'Select measurement unit',
            )),
        SizedBox(height: 12.h),

        Text('Actual Quantity *',
            style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 4.h),
        _textField(widget.actualQtyCtrl, 'e.g. 4',
            keyboard: const TextInputType.numberWithOptions(decimal: true)),
        SizedBox(height: 14.h),

        // ── Photos ────────────────────────────────────────────────────────
        Row(children: [
          Text('Photos',
              style: AppTextStyle.style_12_500(color: AppColors.black300)),
          if (_pickedImages.isNotEmpty) ...[
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: const Color(0xFF009BD9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text('${_pickedImages.length}',
                  style: AppTextStyle.style_10_600(
                      color: const Color(0xFF009BD9))),
            ),
          ],
        ]),
        SizedBox(height: 6.h),
        Row(children: [
          _pickBtn(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              color: const Color(0xFF009BD9),
              onTap: () => _pickImages(ImageSource.camera)),
          SizedBox(width: 8.w),
          _pickBtn(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              color: const Color(0xFF10B981),
              onTap: () => _pickImages(ImageSource.gallery)),
        ]),
        if (_pickedImages.isNotEmpty) ...[
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _pickedImages.asMap().entries.map((entry) {
                final idx = entry.key;
                final img = entry.value;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Stack(clipBehavior: Clip.none, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.file(img,
                          width: 50.r, height: 50.r, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: GestureDetector(
                        onTap: () => _removeImageAt(idx),
                        child: Container(
                          padding: EdgeInsets.all(1.r),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.cancel,
                              size: 16.r, color: Colors.red.shade500),
                        ),
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
        SizedBox(height: 20.h),

        // ── Actions ───────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r)),
              ),
              child: Text('Cancel',
                  style: AppTextStyle.style_12_500(color: AppColors.black)),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009BD9),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r)),
              ),
              child: Text('Add Item',
                  style: AppTextStyle.style_12_600(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    final name = widget.itemNameCtrl.text.trim();
    if (name.isEmpty) {
      AppCommonToastMessage.show(
          message: 'Please enter item name.', type: ToastType.error);
      return;
    }
    if (widget.selectedMeasurementId.value.isEmpty) {
      AppCommonToastMessage.show(
          message: 'Please select a measurement unit.',
          type: ToastType.error);
      return;
    }
    final qtyStr = widget.actualQtyCtrl.text.trim();
    final qty = double.tryParse(qtyStr);
    if (qtyStr.isEmpty || qty == null) {
      AppCommonToastMessage.show(
          message: 'Please enter a valid actual quantity.',
          type: ToastType.error);
      return;
    }
    final unitIdInt =
        int.tryParse(widget.selectedMeasurementId.value) ?? 0;
    final unitOpt = widget.controller.measurementOptions.firstWhereOrNull(
        (o) => o.value == widget.selectedMeasurementId.value);
    widget.controller.addAdditionalItem(AdditionalAuditItem(
      itemName: name,
      measurementUnitId: unitIdInt,
      measurementUnitName: unitOpt?.label ?? '',
      actualQty: qty,
      images: List.from(_pickedImages),
    ));
    Get.back();
  }

  Widget _textField(TextEditingController ctrl, String hint,
      {TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: AppTextStyle.style_12_400(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.style_12_400(color: Colors.grey.shade400),
        isDense: true,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xFF009BD9)),
        ),
      ),
    );
  }

  Widget _pickBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16.r),
              SizedBox(width: 5.w),
              Text(label,
                  style: AppTextStyle.style_11_600(color: AppColors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

