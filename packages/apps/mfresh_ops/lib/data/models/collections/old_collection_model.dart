class OldCollectionModel {
  final int id;
  final String date;
  final String unit;
  final String dailyCash;
  bool isCashCollection;
  bool isCashDeposit;

  OldCollectionModel({
    required this.id,
    required this.date,
    required this.unit,
    required this.dailyCash,
    required this.isCashCollection,
    required this.isCashDeposit,
  });

  factory OldCollectionModel.fromJson(Map<String, dynamic> json) {
    return OldCollectionModel(
      id: json['id'] as int,
      date: json['date'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      dailyCash: json['daily_cash']?.toString() ?? '0',
      isCashCollection: json['is_cash_collection'] == 1 || json['is_cash_collection'] == true,
      isCashDeposit: json['is_cash_deposit'] == 1 || json['is_cash_deposit'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'unit': unit,
      'daily_cash': dailyCash,
      'is_cash_collection': isCashCollection,
      'is_cash_deposit': isCashDeposit,
    };
  }
}
