import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_orders_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_order_logs_controller.dart';

class ReceiveStoreOrderDialog extends StatefulWidget {
  final int orderId;
  final String storeOrUnitName;
  final String itemName;
  final String requestedQty;
  final String displayUnit;
  final bool isStoreOrder;

  const ReceiveStoreOrderDialog({
    super.key,
    required this.orderId,
    required this.storeOrUnitName,
    required this.itemName,
    required this.requestedQty,
    required this.displayUnit,
    this.isStoreOrder = true,
  });

  static Future<void> show({
    required BuildContext context,
    required int orderId,
    required String storeOrUnitName,
    required String itemName,
    required String requestedQty,
    required String displayUnit,
    bool isStoreOrder = true,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 380.w,
            child: ReceiveStoreOrderDialog(
              orderId: orderId,
              storeOrUnitName: storeOrUnitName,
              itemName: itemName,
              requestedQty: requestedQty,
              displayUnit: displayUnit,
              isStoreOrder: isStoreOrder,
            ),
          ),
        );
      },
    );
  }

  @override
  State<ReceiveStoreOrderDialog> createState() =>
      _ReceiveStoreOrderDialogState();
}

class _ReceiveStoreOrderDialogState extends State<ReceiveStoreOrderDialog> {
  final TextEditingController _receivedQtyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _receivedQtyController.dispose();
    super.dispose();
  }

  Future<void> _submitReceiveOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final receivedQty = int.tryParse(_receivedQtyController.text.trim());
    if (receivedQty == null || receivedQty < 0) {
      AppCommonToastMessage.show(
        message: 'Please enter a valid received quantity.',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = Get.find<InventoryRepository>();
      final response = await repository.receiveStoreOrder(
        widget.orderId,
        receivedQty,
      );

      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        final message =
            response['message']?.toString() ?? 'Order received successfully.';
        if (mounted) {
          Navigator.of(context).pop();
        }

        AppCommonToastMessage.show(
          message: message,
          type: ToastType.success,
        );

        if (Get.isRegistered<InventoryController>()) {
          Get.find<InventoryController>().fetchInventoryStock();
        }
        if (Get.isRegistered<UnitInventoryController>()) {
          Get.find<UnitInventoryController>().fetchUnitInventory();
        }
        if (Get.isRegistered<InventoryOrdersController>()) {
          Get.find<InventoryOrdersController>().fetchOrders();
        }
        if (Get.isRegistered<InventoryOrderLogsController>()) {
          Get.find<InventoryOrderLogsController>().fetchOrderLogs();
        }
      } else {
        final errorMessage =
            response?['message']?.toString() ?? 'Failed to receive order.';
        AppCommonToastMessage.show(
          message: errorMessage,
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to submit receive order: $e',
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
    final titleText =
        widget.isStoreOrder ? 'Receive Store Order' : 'Receive Order';
    final locationLabel = widget.isStoreOrder ? 'Store' : 'Unit';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(14.w),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    titleText,
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14.r,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 1, color: Color(0xFFE5E7EB)),

            // Store / Unit Name Field (Read Only)
            Text(
              locationLabel,
              style: AppTextStyle.style_11_600(color: AppColors.black),
            ),
            SizedBox(height: 3.h),
            TextFormField(
              initialValue: widget.storeOrUnitName,
              readOnly: true,
              style: AppTextStyle.style_11_400(color: const Color(0xFF495057)),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Item Name Field (Read Only)
            Text(
              'Item',
              style: AppTextStyle.style_11_600(color: AppColors.black),
            ),
            SizedBox(height: 3.h),
            TextFormField(
              initialValue: widget.itemName,
              readOnly: true,
              style: AppTextStyle.style_11_400(color: const Color(0xFF495057)),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Requested Quantity Field (Read Only)
            Text(
              'Requested Quantity',
              style: AppTextStyle.style_11_600(color: AppColors.black),
            ),
            SizedBox(height: 3.h),
            TextFormField(
              initialValue: widget.displayUnit.isNotEmpty
                  ? '${widget.requestedQty} ${widget.displayUnit}'
                  : widget.requestedQty,
              readOnly: true,
              style: AppTextStyle.style_11_400(color: const Color(0xFF495057)),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Received Quantity Field (Editable)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Received Quantity ',
                    style: AppTextStyle.style_11_600(color: AppColors.black),
                  ),
                  TextSpan(
                    text: '*',
                    style: AppTextStyle.style_11_600(color: Colors.red),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              height: 30.h,
              child: TextFormField(
                controller: _receivedQtyController,
                keyboardType: TextInputType.number,
                style: AppTextStyle.style_12_500(color: AppColors.black),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Required';
                  }
                  final numVal = int.tryParse(val.trim());
                  if (numVal == null || numVal < 0) {
                    return 'Invalid';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 6.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: const BorderSide(color: Color(0xFF00875A)),
                  ),
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 0,
                    minHeight: 30.h,
                    maxHeight: 30.h,
                  ),
                  suffixIcon: widget.displayUnit.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                border: Border(
                                  left: BorderSide(color: Colors.grey.shade300),
                                ),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5.r),
                                  bottomRight: Radius.circular(5.r),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.displayUnit,
                                style: AppTextStyle.style_11_500(
                                    color: const Color(0xFF495057)),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Enter the quantity actually received.',
              style: AppTextStyle.style_10_400(color: AppColors.grey500),
            ),
            SizedBox(height: 12.h),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            SizedBox(height: 10.h),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 28.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C757D),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_11_600(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  height: 28.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReceiveOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00875A),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 12.r,
                            height: 12.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Receive Order',
                            style: AppTextStyle.style_11_600(
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
