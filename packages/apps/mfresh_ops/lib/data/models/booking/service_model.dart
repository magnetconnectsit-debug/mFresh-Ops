// region Imports
// endregion

// region Models
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

  // region Factory & Serialization
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Unnest if nested under 'service'
    final Map<String, dynamic> source = json['service'] is Map
        ? Map<String, dynamic>.from(json['service'])
        : json;

    // Image resolution: check image_url, img_icon, service_image, Image, image, etc.
    String img = (source['image_url'] ??
            json['image_url'] ??
            source['img_icon'] ??
            json['img_icon'] ??
            source['service_image'] ??
            json['service_image'] ??
            source['Image'] ??
            json['Image'] ??
            source['image'] ??
            json['image'] ??
            source['service_img'] ??
            json['service_img'] ??
            source['icon'] ??
            json['icon'] ??
            '')
        .toString()
        .trim();

    if (img.isNotEmpty && !img.startsWith('http')) {
      if (img.startsWith('//')) {
        img = 'https:$img';
      } else if (img.startsWith('/')) {
        img = 'https://opsapi.magnetconnects.com$img';
      } else if (img.contains('magnetconnects.com')) {
        img = 'https://$img';
      } else {
        img = 'https://opsapi.magnetconnects.com/public/images/$img';
      }
    }

    final rawId = source['id'] ??
        json['id'] ??
        source['Service_ID'] ??
        json['Service_ID'] ??
        source['serviceId'] ??
        json['serviceId'] ??
        0;
    final int parsedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final String resolvedAssignServiceId = (source['Assign_Service_Id'] ??
            json['Assign_Service_Id'] ??
            source['assign_service_id'] ??
            json['assign_service_id'] ??
            source['id'] ??
            json['id'] ??
            source['serviceId'] ??
            json['serviceId'] ??
            '')
        .toString();

    final String resolvedServiceName = (source['services_name'] ??
            json['services_name'] ??
            source['Service_Name'] ??
            json['Service_Name'] ??
            source['service_name'] ??
            json['service_name'] ??
            source['name'] ??
            json['name'] ??
            '')
        .toString();

    final rawPrice = source['price'] ??
        json['price'] ??
        source['net_price'] ??
        json['net_price'] ??
        source['Price'] ??
        json['Price'] ??
        '0';
    final double parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;

    final String resolvedDuration = (source['uses'] ??
            json['uses'] ??
            source['Usage_Duration'] ??
            json['Usage_Duration'] ??
            source['usage_duration'] ??
            json['usage_duration'] ??
            '')
        .toString();

    return ServiceModel(
      id: parsedId,
      assignServiceId: resolvedAssignServiceId,
      serviceName: resolvedServiceName,
      price: parsedPrice,
      usageDuration: resolvedDuration,
      imagePath: img.isEmpty ? 'assets/images/urinal_female.png' : img,
    );
  }
  // endregion
}
// endregion
