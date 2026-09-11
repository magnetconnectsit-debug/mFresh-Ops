import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';

class RequestUnitOrderDialog extends StatefulWidget {
  final int? initialUnitId;
  final int itemId;
  final String? initialUnitName;
  final String itemName;
  final num orderQty;
  final String displayUnit;

  const RequestUnitOrderDialog({
    super.key,
    this.initialUnitId,
    required this.itemId,
    this.initialUnitName,
    required this.itemName,
    required this.orderQty,
    required this.displayUnit,
  });

  static Future<void> show({
    required BuildContext context,
    int? unitId,
    required int itemId,
    String? unitName,
    required String itemName,
    required num orderQty,
    required String displayUnit,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          clipBehavior: Clip.antiAlias,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: SizedBox(
            width: 420.w,
            child: RequestUnitOrderDialog(
              initialUnitId: unitId,
              itemId: itemId,
              initialUnitName: unitName,
              itemName: itemName,
              orderQty: orderQty,
              displayUnit: displayUnit,
            ),
          ),
        );
      },
    );
  }

  @override
  State<RequestUnitOrderDialog> createState() =>
      _RequestUnitOrderDialogState();
}

class _RequestUnitOrderDialogState extends State<RequestUnitOrderDialog> {
  bool _isSubmitting = false;
  final Set<int> _selectedUnitIds = {};

  @override
  void initState() {
    super.initState();
    // By default, no unit is selected until chosen by user.
  }

  Future<void> _submitRequest() async {
    if (_selectedUnitIds.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please select a unit.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = Get.find<InventoryRepository>();
      int successCount = 0;
      String lastMessage = '';

      for (final unitId in _selectedUnitIds) {
        final response = await repository.requestUnitOrder(
          unitId: unitId,
          itemId: widget.itemId,
          qty: widget.orderQty,
        );

        if (response != null &&
            (response['status'] == true || response['status'] == 'success')) {
          successCount++;
          lastMessage = response['message']?.toString() ?? 'Unit order request submitted successfully.';
        }
      }

      if (successCount > 0) {
        if (mounted) {
          Navigator.of(context).pop();
        }

        AppCommonToastMessage.show(
          message: successCount == 1
              ? lastMessage
              : '$successCount Unit order request(s) submitted successfully.',
          type: ToastType.success,
        );

        if (Get.isRegistered<UnitInventoryController>()) {
          Get.find<UnitInventoryController>().fetchUnitInventory();
        }
        if (Get.isRegistered<InventoryController>()) {
          Get.find<InventoryController>().fetchInventoryStock();
        }
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to submit unit order request.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error submitting unit order request: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitController = Get.isRegistered<UnitInventoryController>()
        ? Get.find<UnitInventoryController>()
        : Get.put(UnitInventoryController());

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            color: const Color(0xFF0F9D58),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Inventory Order',
                  style: AppTextStyle.style_15_700(color: Colors.white),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.all(2.r),
                    child: Icon(
                      Icons.close,
                      size: 18.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form Body
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Unit Selection Field (Multi-Select Dropdown with isSingleSelect: false)
                _buildFieldLabel('Unit'),
                SizedBox(height: 6.h),
                Obx(() {
                  final selectedSet = _selectedUnitIds.map((e) => e.toString()).toSet();
                  String displayText = 'Select Unit';
                  if (selectedSet.isNotEmpty) {
                    final match = unitController.unitOptions
                        .where((e) => e.value.toString() == selectedSet.first)
                        .firstOrNull;
                    displayText = match?.label ?? widget.initialUnitName ?? 'Select Unit';
                  }

                  return MultiSelectDropdownWidget<String>(
                    label: 'Select Unit',
                    isSingleSelect: true,
                    selectedValues: selectedSet,
                    items: unitController.unitOptions
                        .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                              value: e.value.toString(),
                              child: Text(e.label,
                                  style: AppTextStyle.style_12_400(color: const Color(0xFF2C3E50))),
                            ))
                        .toList(),
                    onChanged: (values) {
                      setState(() {
                        _selectedUnitIds.clear();
                        if (values.isNotEmpty) {
                          final parsed = int.tryParse(values.first);
                          if (parsed != null) {
                            _selectedUnitIds.add(parsed);
                          }
                        }
                      });
                    },
                    customChild: Container(
                      height: 38.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayText,
                              style: selectedSet.isEmpty
                                  ? AppTextStyle.style_12_400(color: const Color(0xFFADB5BD))
                                  : AppTextStyle.style_12_400(color: const Color(0xFF2C3E50)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF6C757D),
                            size: 18.r,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 14.h),

                // Item Field (Read Only)
                _buildFieldLabel('Item'),
                SizedBox(height: 6.h),
                Container(
                  height: 38.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    initialValue: widget.itemName,
                    readOnly: true,
                    style: AppTextStyle.style_12_400(color: const Color(0xFF2C3E50)),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Select Item',
                      hintStyle: AppTextStyle.style_12_400(color: const Color(0xFFADB5BD)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Order Quantity Field with Suffix Unit Badge
                _buildFieldLabel('Order Quantity'),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          initialValue: widget.orderQty.toString(),
                          readOnly: true,
                          style: AppTextStyle.style_12_400(color: const Color(0xFF2C3E50)),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    if (widget.displayUnit.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Container(
                        height: 38.h,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F9D58),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.displayUnit,
                          style: AppTextStyle.style_12_600(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 24.h),

                // Footer Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    SizedBox(
                      height: 34.h,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C757D),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyle.style_12_600(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // Submit Request Button
                    SizedBox(
                      height: 34.h,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48C78E),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 14.r,
                                height: 14.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Submit Request',
                                style: AppTextStyle.style_12_600(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: AppTextStyle.style_12_600(color: const Color(0xFF2C3E50)),
          ),
          TextSpan(
            text: '*',
            style: AppTextStyle.style_12_600(color: const Color(0xFFDC3545)),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hintText}) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      hintStyle: AppTextStyle.style_12_400(color: const Color(0xFFADB5BD)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
    );
  }
}
