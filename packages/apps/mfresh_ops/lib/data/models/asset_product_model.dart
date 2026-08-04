class AssetProductModel {
  final String id;
  final String item;
  final String itemType;
  final String brand;
  final String model;
  final String serialNo;
  final String specification;
  final String qty;
  final String location;
  final String unit;
  final String installedAt;
  final String warrantyExpiry;
  final String warranty;
  final String warrantyStatus;
  final String vendor;
  final List<String> attachments;
  final String project;

  AssetProductModel({
    required this.id,
    required this.item,
    required this.itemType,
    required this.brand,
    required this.model,
    required this.serialNo,
    required this.specification,
    required this.qty,
    required this.location,
    required this.unit,
    required this.installedAt,
    required this.warrantyExpiry,
    required this.warranty,
    required this.warrantyStatus,
    required this.vendor,
    required this.attachments,
    required this.project,
  });

  factory AssetProductModel.dummy(String id) {
    return AssetProductModel(
      id: id,
      item: 'Asset $id',
      itemType: 'Asset',
      brand: 'Brand XYZ',
      model: 'Model $id',
      serialNo: 'SN-00$id',
      specification: 'Spec details for $id',
      qty: '1',
      location: 'Location $id',
      unit: 'Unit $id',
      installedAt: 'Installed Location $id',
      warrantyExpiry: '2026-12-31',
      warranty: '1 Year',
      warrantyStatus: 'Active',
      vendor: 'Vendor ABC',
      attachments: ['pdf', 'image'],
      project: 'mFresh',
    );
  }
}
