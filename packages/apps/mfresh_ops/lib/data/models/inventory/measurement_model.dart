class MeasurementModel {
  final int id;
  final String measurementUnit;

  MeasurementModel({
    required this.id,
    required this.measurementUnit,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    return MeasurementModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      measurementUnit: json['measurement_unit']?.toString() ?? '',
    );
  }
}
