import 'package:mfresh/core/constants/app_constants.dart';

class ServiceModel {
  final int id;
  final String assignServiceId;
  final String serviceName;
  final double price;
  final String usageDuration;
  final String imagePath;

  ServiceModel({
    required this.id,
    required this.assignServiceId,
    required this.serviceName,
    required this.price,
    required this.usageDuration,
    required this.imagePath,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String img = (json['Image'] ?? json['service_image'] ?? '').toString();
    if (img.isNotEmpty && !img.startsWith('http')) {
      img = '${AppConstants.serviceImageBaseUrl}$img';
    }

    return ServiceModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse((json['Service_ID'] ?? json['id'] ?? '0').toString()) ?? 0,
      assignServiceId: (json['Assign_Service_Id'] ?? json['assign_service_id'] ?? '').toString(),
      serviceName: (json['Service_Name'] ?? json['services_name'] ?? '').toString(),
      price: double.tryParse((json['Price'] ?? json['price'] ?? '0').toString()) ?? 0.0,
      usageDuration: (json['Usage_Duration'] ?? json['usage_duration'] ?? '').toString(),
      imagePath: img.isEmpty ? 'assets/images/urinal_female.png' : img,
    );
  }
}
