import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_audit_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class AddItemDialog extends StatefulWidget {
  final InventoryAuditController controller;

  const AddItemDialog({super.key, required this.controller});

  static Future<void> show(
    BuildContext context,
    InventoryAuditController controller,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddItemDialog(controller: controller),
    );
  }

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  String? _selectedUnitId;
  String? _selectedUnitName;
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.controller.measurementOptions.isEmpty) {
      widget.controller.fetchMeasurements();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final pickedList = await picker.pickMultiImage(imageQuality: 80);
        if (pickedList.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(pickedList.map((x) => File(x.path)));
          });
        }
      } else {
        final picked = await picker.pickImage(source: source, imageQuality: 80);
        if (picked != null) {
          setState(() {
            _selectedImages.add(File(picked.path));
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image in dialog: $e');
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Image Source',
              style: AppTextStyle.style_15_700(color: AppColors.black),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009BD9).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFF009BD9).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: const Color(0xFF009BD9),
                            size: 28.r,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Camera',
                            style: AppTextStyle.style_13_600(color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: const Color(0xFF10B981),
                            size: 28.r,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Gallery',
                            style: AppTextStyle.style_13_600(color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter item name.',
        type: ToastType.error,
      );
      return;
    }
    if (_selectedUnitId == null || _selectedUnitId!.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please select a measurement unit.',
        type: ToastType.error,
      );
      return;
    }
    final qtyStr = _qtyController.text.trim();
    final qty = double.tryParse(qtyStr);
    if (qtyStr.isEmpty || qty == null || qty <= 0) {
      AppCommonToastMessage.show(
        message: 'Please enter a valid actual quantity.',
        type: ToastType.error,
      );
      return;
    }
    if (qty > 0 && _selectedImages.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please add at least one photo since quantity is greater than 0.',
        type: ToastType.error,
      );
      return;
    }

    final unitIdInt = int.tryParse(_selectedUnitId!) ?? 0;

    widget.controller.addAdditionalItem(
      AdditionalAuditItem(
        itemName: name,
        measurementUnitId: unitIdInt,
        measurementUnitName: _selectedUnitName ?? '',
        actualQty: qty,
        images: _selectedImages,
      ),
    );

    AppCommonToastMessage.show(
      message: 'Additional item added successfully.',
      type: ToastType.success,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        width: 380.w,
        padding: EdgeInsets.all(16.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.post_add_rounded,
                          color: const Color(0xFF009BD9),
                          size: 18.r,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Additional Item',
                        style: AppTextStyle.style_15_700(color: AppColors.black),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.close,
                        size: 18.r,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(height: 1, color: Colors.grey.shade200),
              SizedBox(height: 12.h),

              // Item Name Field
              Text(
                'Item Name *',
                style: AppTextStyle.style_12_500(color: AppColors.black300),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                height: 28.h,
                child: TextField(
                  controller: _nameController,
                  style: AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter item name',
                    hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: const BorderSide(color: Color(0xFF009BD9), width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Measurement Unit Dropdown (MultiSelectDropdownWidget - Filter Style)
              Obx(() {
                final options = widget.controller.measurementOptions;
                return MultiSelectDropdownWidget<String>(
                  title: 'Measurement Unit *',
                  hint: 'Select measurement unit',
                  isSingleSelect: true,
                  showSearch: true,
                  height: 28.h,
                  selectedValues: _selectedUnitId != null ? {_selectedUnitId!} : {},
                  items: options
                      .map(
                        (opt) => DropdownMenuItem<String>(
                          value: opt.value,
                          child: Text(
                            opt.label,
                            style: AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      _selectedUnitId = values.isNotEmpty ? values.first : null;
                      final opt = options.firstWhereOrNull((o) => o.value == _selectedUnitId);
                      _selectedUnitName = opt?.label;
                    });
                  },
                );
              }),
              SizedBox(height: 10.h),

              // Actual Quantity Field
              Text(
                'Actual Quantity *',
                style: AppTextStyle.style_12_500(color: AppColors.black300),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                height: 28.h,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',
                    hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: const BorderSide(color: Color(0xFF009BD9), width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Item Image Picker (Optional)
              Text(
                'Item Images (Optional)',
                style: AppTextStyle.style_12_500(color: AppColors.black300),
              ),
              SizedBox(height: 4.h),
              if (_selectedImages.isEmpty)
                InkWell(
                  onTap: _showImagePickerModal,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    height: 28.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 16.r, color: const Color(0xFF009BD9)),
                        SizedBox(width: 6.w),
                        Text(
                          'Tap to select Camera or Gallery',
                          style: AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._selectedImages.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final img = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: Image.file(
                                    img,
                                    width: 32.r,
                                    height: 32.r,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.removeAt(idx);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(1.r),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.cancel,
                                        size: 14.r,
                                        color: Colors.red.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        InkWell(
                          onTap: _showImagePickerModal,
                          borderRadius: BorderRadius.circular(4.r),
                          child: Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              size: 14.r,
                              color: const Color(0xFF009BD9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16.h),

              // Action Buttons (Matching Filter Button Sizes)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 28.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.style_11_600(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 28.h,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009BD9),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Add Item',
                        style: AppTextStyle.style_11_600(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
