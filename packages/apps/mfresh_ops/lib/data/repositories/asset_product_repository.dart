import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';

class AssetProductRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Fetch paginated list — item_type: "" = all, "0" = product, "1" = asset
  Future<Map<String, dynamic>?> fetchList({
    required String itemType,
    required String globalSearch,
    required int perPage,
    required int page,
  }) async {
    final response = await _apiService.post(
      AppConstants.assetProductList,
      data: {
        'item_type': itemType,
        'global_search': globalSearch,
        'per_page': perPage,
        'page': page,
      },
    );
    return response as Map<String, dynamic>?;
  }

  /// Fetch project dropdown options
  Future<Map<String, dynamic>?> fetchProjects() async {
    final response = await _apiService.get(AppConstants.assetProductProjects);
    return response as Map<String, dynamic>?;
  }

  /// Create new asset/product (multipart)
  Future<Map<String, dynamic>?> storeAsset({
    required String itemName,
    required String qty,
    required String brand,
    required String model,
    required String serialNo,
    required String description,
    required String warrantyDate,
    required String warrantyType,
    required String location,
    required String unit,
    required String position,
    required String vendor,
    required String itemType, // "0" = product, "1" = asset
    required String spec,
    required String project,
    List<File> invoiceFiles = const [],
    List<File> warrantyFiles = const [],
    List<File> othersFiles = const [],
  }) async {
    final dataMap = <String, dynamic>{
      'item_name': itemName,
      'qty': qty,
      'brand': brand,
      'model': model,
      'serial_no': serialNo,
      'description': description,
      'warranty_date': warrantyDate,
      'warranty_type': warrantyType,
      'location': location,
      'unit': unit,
      'position': position,
      'vendor': vendor,
      'item_type': itemType,
      'spec': spec,
      'project': project,
    };

    await _attachFiles(dataMap, 'invoice[]', invoiceFiles);
    await _attachFiles(dataMap, 'warrantyimg[]', warrantyFiles);
    await _attachFiles(dataMap, 'othersimg[]', othersFiles);

    final formData = dio.FormData.fromMap(dataMap);
    final response = await _apiService.post(AppConstants.assetProductStore, data: formData);
    return response as Map<String, dynamic>?;
  }

  /// Update existing asset/product (multipart)
  Future<Map<String, dynamic>?> updateAsset({
    required int assetId,
    required String itemName,
    required String qty,
    required String brand,
    required String model,
    required String serialNo,
    required String description,
    required String warrantyDate,
    required String warrantyType,
    required String location,
    required String unit,
    required String position,
    required String vendor,
    required String itemType,
    required String spec,
    required String project,
    List<File> invoiceFiles = const [],
    List<File> warrantyFiles = const [],
    List<File> othersFiles = const [],
  }) async {
    final dataMap = <String, dynamic>{
      'asset_id': assetId.toString(),
      'item_name': itemName,
      'qty': qty,
      'brand': brand,
      'model': model,
      'serial_no': serialNo,
      'description': description,
      'warranty_date': warrantyDate,
      'warranty_type': warrantyType,
      'location': location,
      'unit': unit,
      'position': position,
      'vendor': vendor,
      'item_type': itemType,
      'spec': spec,
      'project': project,
    };

    await _attachFiles(dataMap, 'invoice', invoiceFiles);
    await _attachFiles(dataMap, 'warrantyimg', warrantyFiles);
    await _attachFiles(dataMap, 'othersimg', othersFiles);

    final formData = dio.FormData.fromMap(dataMap);
    final response = await _apiService.post(AppConstants.assetProductUpdate, data: formData);
    return response as Map<String, dynamic>?;
  }

  /// Delete an asset/product
  Future<Map<String, dynamic>?> deleteAsset(int assetId) async {
    final response = await _apiService.post(
      AppConstants.assetProductDelete,
      data: {'asset_id': assetId},
    );
    return response as Map<String, dynamic>?;
  }


  Future<void> _attachFiles(
    Map<String, dynamic> dataMap,
    String key,
    List<File> files,
  ) async {
    if (files.isEmpty) return;
    final multipartFiles = <dio.MultipartFile>[];
    for (final file in files) {
      final fileName = file.path.split('/').last;
      multipartFiles.add(
        await dio.MultipartFile.fromFile(file.path, filename: fileName),
      );
    }
    dataMap[key] = multipartFiles;
  }
}
