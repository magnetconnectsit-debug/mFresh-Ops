import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class ConsumptionItemModel {
  final int id;
  final String consumedOn;
  final String state;
  final String district;
  final String sourceType;
  final String source;
  final String category;
  final String item;
  final String consumedQty;
  final String mUnit;
  final String createdBy;
  final int isReversed;

  ConsumptionItemModel({
    required this.id,
    required this.consumedOn,
    required this.state,
    required this.district,
    required this.sourceType,
    required this.source,
    required this.category,
    required this.item,
    required this.consumedQty,
    required this.mUnit,
    required this.createdBy,
    required this.isReversed,
  });

  factory ConsumptionItemModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date_of_consumption']?.toString() ?? '';
    final formattedDate = AppDateUtils.formatToOrdinalDate(rawDate);

    return ConsumptionItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      consumedOn: formattedDate,
      state: json['state_name']?.toString() ?? '',
      district: json['district_name']?.toString() ?? '',
      sourceType: json['source_type']?.toString() ?? '',
      source: json['sourcename']?.toString() ?? '',
      category: json['category_name']?.toString() ?? '',
      item: json['item_name']?.toString() ?? '',
      consumedQty: json['consumed_qty']?.toString() ?? '',
      mUnit: json['measurement_name']?.toString() ?? '',
      createdBy: json['created_by_name']?.toString() ?? '',
      isReversed: (json['is_reversed'] == 1 ||
              json['is_reversed'] == true ||
              json['is_reversed']?.toString() == '1')
          ? 1
          : 0,
    );
  }
}
