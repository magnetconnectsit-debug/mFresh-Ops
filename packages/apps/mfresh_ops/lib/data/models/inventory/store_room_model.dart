class StoreRoomModel {
  final int id;
  final String storeName;

  StoreRoomModel({
    required this.id,
    required this.storeName,
  });

  factory StoreRoomModel.fromJson(Map<String, dynamic> json) {
    return StoreRoomModel(
      id: json['storeid'] is int
          ? json['storeid']
          : int.tryParse(json['storeid']?.toString() ?? '0') ?? 0,
      storeName: json['storeroom_name']?.toString() ?? '',
    );
  }
}
