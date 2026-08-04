import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';

class ContactRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Store a new contact (multipart form data with optional attachments)
  Future<Map<String, dynamic>?> storeContact({
    required String name,
    required String workedOn,
    required String level,
    required String brand,
    required String designation,
    required String department,
    required String mobile1,
    required String mobile2,
    required String email,
    required String location,
    required String address,
    required String weblinks,
    required String typeService,
    required String company,
    required String description,
    required String gstin,
    required String contactType,
    List<File> attachments = const [],
  }) async {
    final dataMap = <String, dynamic>{
      'cname': name,
      'workon': workedOn,
      'level': level,
      'brand': brand,
      'desng': designation,
      'cdept': department,
      'mobl1': mobile1,
      'mobl2': mobile2,
      'cmail': email,
      'clocation': location,
      'address': address,
      'weblink': weblinks,
      'typservc': typeService,
      'company': company,
      'cdesc': description,
      'gstin': gstin,
      'cont_type': contactType,
    };

    if (attachments.isNotEmpty) {
      final multipartFiles = <dio.MultipartFile>[];
      for (final file in attachments) {
        final fileName = file.path.split('/').last;
        multipartFiles.add(
          await dio.MultipartFile.fromFile(file.path, filename: fileName),
        );
      }
      dataMap['cattch[]'] = multipartFiles;
    }

    final formData = dio.FormData.fromMap(dataMap);
    final response = await _apiService.post(
      AppConstants.contactStore,
      data: formData,
    );
    return response;
  }

  /// Update an existing contact
  Future<Map<String, dynamic>?> updateContact({
    required String id,
    required String name,
    required String workedOn,
    required String level,
    required String brand,
    required String designation,
    required String department,
    required String mobile1,
    required String mobile2,
    required String email,
    required String location,
    required String address,
    required String weblinks,
    required String typeService,
    required String company,
    required String description,
    required String gstin,
    required String contactType,
    List<File> attachments = const [],
  }) async {
    final dataMap = <String, dynamic>{
      'contact_id': id,
      'cname': name,
      'workon': workedOn,
      'level': level,
      'brand': brand,
      'desng': designation,
      'cdept': department,
      'mobl1': mobile1,
      'mobl2': mobile2,
      'cmail': email,
      'clocation': location,
      'address': address,
      'weblink': weblinks,
      'typservc': typeService,
      'company': company,
      'cdesc': description,
      'gstin': gstin,
      'cont_type': contactType,
    };

    if (attachments.isNotEmpty) {
      final multipartFiles = <dio.MultipartFile>[];
      for (final file in attachments) {
        final fileName = file.path.split('/').last;
        multipartFiles.add(
          await dio.MultipartFile.fromFile(file.path, filename: fileName),
        );
      }
      dataMap['cattch[]'] = multipartFiles;
    }

    final formData = dio.FormData.fromMap(dataMap);
    final response = await _apiService.post(
      AppConstants.contactUpdate,
      data: formData,
    );
    return response;
  }

  /// Delete a contact by id
  Future<Map<String, dynamic>?> deleteContact({required String id}) async {
    final response = await _apiService.post(
      AppConstants.contactDelete,
      data: {'contact_id': id},
    );
    return response;
  }

  /// Fetch contacts with optional filters
  Future<Map<String, dynamic>?> fetchContacts({
    List<String> company = const [],
    List<String> brand = const [],
    String contactType = '',
    String globalSearch = '',
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiService.post(
      AppConstants.contactList,
      data: {
        'company': company,
        'brand': brand,
        'contact_type': contactType,
        'global_search': globalSearch,
        'page': page,
        'per_page': perPage,
      },
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return null;
  }

  /// Fetch company list
  Future<List<Map<String, dynamic>>> fetchCompanyList() async {
    try {
      final response = await _apiService.get(AppConstants.companyList);
      if (response != null && response['status'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((e) => {
                  'id': e['id'],
                  'name': e['company_name']?.toString() ?? '',
                })
            .where((e) => (e['name'] as String).isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching company list: $e');
    }
    return [];
  }

  /// Fetch brand list
  Future<List<Map<String, dynamic>>> fetchBrandList() async {
    try {
      final response = await _apiService.get(AppConstants.brandList);
      if (response != null && response['status'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((e) => {
                  'id': e['id'],
                  'name': e['brand_name']?.toString() ?? '',
                })
            .where((e) => (e['name'] as String).isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching brand list: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> createCompany({required String companyName}) async {
    try {
      return await _apiService.post(
        AppConstants.companyCreate,
        data: {'company_name': companyName},
      );
    } catch (e) {
      debugPrint('Error creating company: $e');
      return {'status': false, 'message': 'Failed to create company: $e'};
    }
  }

  Future<Map<String, dynamic>?> updateCompany({required int companyId, required String companyName}) async {
    try {
      return await _apiService.post(
        AppConstants.companyUpdate,
        data: {
          'company_id': companyId,
          'company_name': companyName,
        },
      );
    } catch (e) {
      debugPrint('Error updating company: $e');
      return {'status': false, 'message': 'Failed to update company: $e'};
    }
  }

  Future<Map<String, dynamic>?> deleteCompany({required int companyId}) async {
    try {
      return await _apiService.post(
        AppConstants.companyDelete,
        data: {'company_id': companyId},
      );
    } catch (e) {
      debugPrint('Error deleting company: $e');
      return {'status': false, 'message': 'Failed to delete company: $e'};
    }
  }

  Future<Map<String, dynamic>?> createBrand({required String brandName}) async {
    try {
      return await _apiService.post(
        AppConstants.brandCreate,
        data: {'brand_name': brandName},
      );
    } catch (e) {
      debugPrint('Error creating brand: $e');
      return {'status': false, 'message': 'Failed to create brand: $e'};
    }
  }

  Future<Map<String, dynamic>?> updateBrand({required int brandId, required String brandName}) async {
    try {
      return await _apiService.post(
        AppConstants.brandUpdate,
        data: {
          'brand_id': brandId,
          'brand_name': brandName,
        },
      );
    } catch (e) {
      debugPrint('Error updating brand: $e');
      return {'status': false, 'message': 'Failed to update brand: $e'};
    }
  }

  Future<Map<String, dynamic>?> deleteBrand({required int brandId}) async {
    try {
      return await _apiService.post(
        AppConstants.brandDelete,
        data: {'brand_id': brandId},
      );
    } catch (e) {
      debugPrint('Error deleting brand: $e');
      return {'status': false, 'message': 'Failed to delete brand: $e'};
    }
  }
}
