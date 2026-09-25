import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';

class RequestStoreOrderDialog extends StatefulWidget {
  final int storeId;
  final int itemId;
  final String storeName;
  final String itemName;
  final num orderQty;
  final String displayUnit;

  const RequestStoreOrderDialog({
    super.key,
    required this.storeId,
    required this.itemId,
    required this.storeName,
    required this.itemName,
    required this.orderQty,
    required this.displayUnit,
  });

  static Future<void> show({
    required BuildContext context,
    required int storeId,
    required int itemId,
    required String storeName,
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
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 380.w,
            child: RequestStoreOrderDialog(
              storeId: storeId,
              itemId: itemId,
              storeName: storeName,
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
  State<RequestStoreOrderDialog> createState() =>
      _RequestStoreOrderDialogState();
}

class _RequestStoreOrderDialogState extends State<RequestStoreOrderDialog> {
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = Get.find<InventoryRepository>();
      final response = await repository.requestStoreOrder(
        storeId: widget.storeId,
        itemId: widget.itemId,
        qty: widget.orderQty,
      );

      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        final message =
            response['message']?.toString() ?? 'Store order request submitted successfully.';

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
      } else {
        final errorMessage =
            response?['message']?.toString() ?? 'Failed to submit store order request.';
        AppCommonToastMessage.show(
          message: errorMessage,
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to submit request: $e',
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
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(14.w),
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
                  'Request Store Inventory Order',
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

          // Store Field (Read Only)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Store ',
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
          TextFormField(
            initialValue: widget.storeName,
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

          // Item Field (Read Only)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Item ',
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

          // Order Quantity Field (Read Only with Unit)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Order Quantity ',
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
              initialValue: widget.orderQty.toString(),
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
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
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
                          'Submit Request',
                          style: AppTextStyle.style_11_600(
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
