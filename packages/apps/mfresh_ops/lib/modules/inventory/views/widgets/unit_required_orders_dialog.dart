import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_orders_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/data/models/inventory/inventory_order_model.dart';

class UnitRequiredOrdersDialog extends StatefulWidget {
  final BulkPreviewSection? bulkPreviewSection;
  const UnitRequiredOrdersDialog({super.key, this.bulkPreviewSection});

  static Future<void> show({
    required BuildContext context,
    BulkPreviewSection? bulkPreviewSection,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            child: UnitRequiredOrdersDialog(bulkPreviewSection: bulkPreviewSection),
          ),
        );
      },
    );
  }

  @override
  State<UnitRequiredOrdersDialog> createState() =>
      _UnitRequiredOrdersDialogState();
}

class _UnitRequestOrderItemData {
  final String itemName;
  final String displayUnit;
  final Map<String, num> unitQtyMap;

  _UnitRequestOrderItemData({
    required this.itemName,
    required this.displayUnit,
    required this.unitQtyMap,
  });

  num get totalQty {
    return unitQtyMap.values.fold(0, (sum, q) => sum + q);
  }
}

class _UnitRequiredOrdersDialogState
    extends State<UnitRequiredOrdersDialog> {
  final GlobalKey _tableRepaintKey = GlobalKey();
  bool _isSubmitting = false;
  bool _isLoadingPreview = false;
  BulkPreviewSection? _fetchedPreviewSection;

  @override
  void initState() {
    super.initState();
    if (widget.bulkPreviewSection == null) {
      _fetchBulkPreview();
    }
  }

  Future<void> _fetchBulkPreview() async {
    setState(() {
      _isLoadingPreview = true;
    });
    try {
      final repository = Get.find<InventoryRepository>();
      final response = await repository.getInventoryOrders();
      if (response != null && response['status'] == true && response['data'] != null) {
        final bulkData = response['data']['bulk_preview'];
        if (bulkData != null && bulkData['unit_orders'] != null) {
          _fetchedPreviewSection = BulkPreviewSection.fromJson(bulkData['unit_orders']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching bulk preview for unit orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPreview = false;
        });
      }
    }
  }

  String _formatQty(num qty) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(qty);
  }

  Future<void> _shareTableImage(BuildContext btnContext) async {
    try {
      final boundary = _tableRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        AppCommonToastMessage.show(
          message: 'Unable to capture table image.',
          type: ToastType.error,
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/unit_required_orders_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      if (!btnContext.mounted) return;

      final box = btnContext.findRenderObject() as RenderBox?;
      final rect = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.fromLTWH(0, 0, MediaQuery.of(btnContext).size.width,
              MediaQuery.of(btnContext).size.height / 2);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Unit Required Orders',
        sharePositionOrigin: rect,
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to share image: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> _submitBulkOrder() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = Get.find<InventoryRepository>();
      final response = await repository.createBulkUnitOrder();

      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        final message =
            response['message']?.toString() ?? 'Unit order(s) created successfully.';

        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        AppCommonToastMessage.show(
          message: message,
          type: ToastType.success,
        );

        if (Get.isRegistered<UnitInventoryController>()) {
          Get.find<UnitInventoryController>().fetchUnitInventory();
        }
        if (Get.isRegistered<InventoryController>()) {
          Get.find<InventoryController>().fetchInventoryStock();
        }
        if (Get.isRegistered<InventoryOrdersController>()) {
          Get.find<InventoryOrdersController>().fetchOrders();
        }
      } else {
        final errorMessage =
            response?['message']?.toString() ?? 'Failed to create unit orders.';
        AppCommonToastMessage.show(
          message: errorMessage,
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to create unit orders: $e',
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
    final bulkSection = widget.bulkPreviewSection ?? _fetchedPreviewSection;
    final List<String> units;
    final List<_UnitRequestOrderItemData> itemsData;
    final String dialogTitle;

    if (_isLoadingPreview) {
      dialogTitle = 'Unit Required Orders';
      units = ['Unit 1', 'Unit 2'];
      itemsData = List.generate(
        6,
        (index) => _UnitRequestOrderItemData(
          itemName: 'Loading Item Name ${index + 1}',
          displayUnit: 'pcs',
          unitQtyMap: {'Unit 1': 100, 'Unit 2': 200},
        ),
      );
    } else if (bulkSection != null) {
      dialogTitle = bulkSection.title.isNotEmpty
          ? bulkSection.title
          : 'Unit Required Orders';
      units = bulkSection.columns.map((c) => c.name).toList();

      final Map<String, _UnitRequestOrderItemData> itemMap = {};
      for (var row in bulkSection.rows) {
        final itemName = row.itemName;
        final unitDisplay = row.measurementUnit;
        if (!itemMap.containsKey(itemName)) {
          itemMap[itemName] = _UnitRequestOrderItemData(
            itemName: itemName,
            displayUnit: unitDisplay,
            unitQtyMap: {},
          );
        }
        for (var q in row.quantities) {
          itemMap[itemName]!.unitQtyMap[q.locationName] = q.orderQty;
        }
      }
      itemsData = itemMap.values.toList()
        ..sort((a, b) => a.itemName.compareTo(b.itemName));
    } else {
      final unitController = Get.isRegistered<UnitInventoryController>()
          ? Get.find<UnitInventoryController>()
          : null;
      final days = unitController?.consumptionDays.value.isNotEmpty == true
          ? unitController!.consumptionDays.value
          : '8';
      final rawDate = unitController?.consumptionToDate.value ?? '';
      String dateStr;
      if (rawDate.isNotEmpty) {
        try {
          dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.parse(rawDate));
        } catch (_) {
          dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.now());
        }
      } else {
        dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.now());
      }
      dialogTitle = 'Unit Required Orders (for next $days days from $dateStr)';

      final filteredItems = (unitController?.unitInventoryItems ?? [])
          .where((i) => i.canRequestOrder && !i.canReceiveOrder)
          .toList();

      final Set<String> unitSet = {};
      for (var i in filteredItems) {
        if (i.unitName.isNotEmpty) unitSet.add(i.unitName);
      }
      units = unitSet.toList()..sort();

      final Map<String, _UnitRequestOrderItemData> itemMap = {};
      for (var i in filteredItems) {
        final itemName = i.itemName;
        final unitDisplay = i.displayUnit.isNotEmpty ? i.displayUnit : i.mUnit;
        if (!itemMap.containsKey(itemName)) {
          itemMap[itemName] = _UnitRequestOrderItemData(
            itemName: itemName,
            displayUnit: unitDisplay,
            unitQtyMap: {},
          );
        }
        itemMap[itemName]!.unitQtyMap[i.unitName] = i.orderQty;
      }

      itemsData = itemMap.values.toList()
        ..sort((a, b) => a.itemName.compareTo(b.itemName));
    }

    return Stack(
      children: [
        // Offscreen unclipped full table container specifically for full image capture
        Positioned(
          left: -9999,
          top: -9999,
          child: RepaintBoundary(
            key: _tableRepaintKey,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dialogTitle,
                    style: AppTextStyle.style_14_700(color: const Color(0xFF1E3A5F)),
                  ),
                  SizedBox(height: 12.h),
                  Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    border: TableBorder.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    children: [
                      // Table Header Row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0288D1),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            child: Text(
                              'Item',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.style_11_700(
                                  color: Colors.white),
                            ),
                          ),
                          ...units.map(
                            (uName) => Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              child: Text(
                                uName,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.style_11_700(
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            child: Text(
                              'Total',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.style_11_700(
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      // Table Data Rows
                      ...itemsData.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final itemData = entry.value;
                        final rowBgColor = idx % 2 == 0
                            ? Colors.white
                            : const Color(0xFFFAFAFA);

                        return TableRow(
                          decoration: BoxDecoration(color: rowBgColor),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h),
                              child: Text(
                                itemData.itemName,
                                style: AppTextStyle.style_11_600(
                                    color: const Color(0xFF2C3E50)),
                              ),
                            ),
                            ...units.map((uName) {
                              final qty = itemData.unitQtyMap[uName] ?? 0;
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 6.h),
                                child: Text(
                                  '${_formatQty(qty)} ${itemData.displayUnit}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.style_11_400(
                                      color: const Color(0xFF2C3E50)),
                                ),
                              );
                            }),
                            Container(
                              color: const Color(0xFFF7F2E9),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h),
                              child: Text(
                                '${_formatQty(itemData.totalQty)} ${itemData.displayUnit}',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.style_11_600(
                                    color: const Color(0xFF2C3E50)),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Visible Dialog Body
        Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Container(
                color: const Color(0xFFEBF3FA),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dialogTitle,
                        style: AppTextStyle.style_14_700(color: const Color(0xFF1E3A5F)),
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Notice Banner
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        border: Border.all(color: const Color(0xFFB2EBF2)),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Required quantities for all Units. Zero-quantity items are not included.',
                        style: AppTextStyle.style_11_500(color: const Color(0xFF006064)),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Data Table Section
                    if (!_isLoadingPreview && itemsData.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: Text(
                            'No required unit orders found.',
                            style: AppTextStyle.style_12_400(color: AppColors.grey500),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: Skeletonizer(
                          enabled: _isLoadingPreview,
                          child: Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Table(
                                  defaultColumnWidth: const IntrinsicColumnWidth(),
                                  border: TableBorder.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                  children: [
                                    // Table Header Row
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0288D1),
                                      ),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 8.h),
                                          child: Text(
                                            'Item',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyle.style_11_700(
                                                color: Colors.white),
                                          ),
                                        ),
                                        ...units.map(
                                          (uName) => Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w, vertical: 8.h),
                                            child: Text(
                                              uName,
                                              textAlign: TextAlign.center,
                                              style: AppTextStyle.style_11_700(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 8.h),
                                          child: Text(
                                            'Total',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyle.style_11_700(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Table Data Rows
                                    ...itemsData.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      final itemData = entry.value;
                                      final rowBgColor = idx % 2 == 0
                                          ? Colors.white
                                          : const Color(0xFFFAFAFA);

                                      return TableRow(
                                        decoration: BoxDecoration(color: rowBgColor),
                                        children: [
                                          // Item Name Column
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w, vertical: 6.h),
                                            child: Text(
                                              itemData.itemName,
                                              style: AppTextStyle.style_11_600(
                                                  color: const Color(0xFF2C3E50)),
                                            ),
                                          ),

                                          // Unit Qty Columns
                                          ...units.map((uName) {
                                            final qty = itemData.unitQtyMap[uName] ?? 0;
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w, vertical: 6.h),
                                              child: Text(
                                                '${_formatQty(qty)} ${itemData.displayUnit}',
                                                textAlign: TextAlign.center,
                                                style: AppTextStyle.style_11_400(
                                                    color: const Color(0xFF2C3E50)),
                                              ),
                                            );
                                          }),

                                          // Total Column
                                          Container(
                                            color: const Color(0xFFF7F2E9),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w, vertical: 6.h),
                                            child: Text(
                                              '${_formatQty(itemData.totalQty)} ${itemData.displayUnit}',
                                              textAlign: TextAlign.center,
                                              style: AppTextStyle.style_11_600(
                                                  color: const Color(0xFF2C3E50)),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 16.h),

                    // Action Buttons Row
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        // Share Button
                        Builder(
                          builder: (btnContext) => SizedBox(
                            height: 30.h,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _shareTableImage(btnContext),
                              icon: Icon(Icons.share,
                                  size: 14.r, color: Colors.white),
                              label: Text(
                                'Share',
                                style: AppTextStyle.style_11_600(
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF198754),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                elevation: 0,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ),

                        // Order Button
                        SizedBox(
                          height: 30.h,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitBulkOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D6EFD),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.r),
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
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check,
                                          size: 14.r, color: Colors.white),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Order',
                                        style: AppTextStyle.style_11_600(
                                            color: Colors.white),
                                      ),
                                    ],
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
        ),
        ],
      );
    }
}
