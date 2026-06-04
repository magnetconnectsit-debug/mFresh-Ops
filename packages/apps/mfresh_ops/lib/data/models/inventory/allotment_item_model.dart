import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class AllotmentItemModel {
  final int allotmentId;
  final String dateOfAllotment;
  final String itemName;
  final String source;
  final String destination;
  final String quantity;
  final String unit;
  final String allotmentBy;
  final int isReversed;
  final String reverseStatus;

  AllotmentItemModel({
    required this.allotmentId,
    required this.dateOfAllotment,
    required this.itemName,
    required this.source,
    required this.destination,
    required this.quantity,
    required this.unit,
    required this.allotmentBy,
    required this.isReversed,
    required this.reverseStatus,
  });

  factory AllotmentItemModel.fromJson(Map<String, dynamic> json) {
    return AllotmentItemModel(
      allotmentId: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      dateOfAllotment: AppDateUtils.formatToOrdinalDate(json['date_of_allotment']?.toString()),
      itemName: json['item_name']?.toString() ?? '',
      source: json['source_name']?.toString() ?? '',
      destination: json['destination_name']?.toString() ?? '',
      quantity: (json['final_qty'] ?? json['quantity'])?.toString() ?? '',
      unit: json['measurement_name']?.toString() ?? '',
      allotmentBy: json['created_by']?.toString() ?? '',
      isReversed: (json['is_reversed'] == 1 ||
              json['is_reversed'] == true ||
              json['is_reversed']?.toString() == '1')
          ? 1
          : 0,
      reverseStatus: json['reverse_status']?.toString() ?? '',
    );
  }
}
