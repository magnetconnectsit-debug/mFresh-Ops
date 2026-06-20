import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DepartmentCollectionRow {
  final String date;
  final Map<String, double?> unitCollections;
  final double totalActual;

  DepartmentCollectionRow({
    required this.date,
    required this.unitCollections,
    required this.totalActual,
  });
}

class CollectionsController extends GetxController {
  final isLoading = false.obs;
  
  final List<String> units = [
    'MM25001',
    'MM25002',
    'MM25003',
    'MM25004',
    'MM25005',
    'MM2500DEV',
    'Other',
  ];

  final collections = <DepartmentCollectionRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate dummy data matching the screenshot
    final List<DepartmentCollectionRow> data = [];
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    for (int i = 1; i <= 30; i++) {
      final dateStr = '2026-06-${i.toString().padLeft(2, '0')}';
      
      // Some units don't have collections, we mark them with null (empty)
      final unitData = <String, double?>{
        'MM25001': null,
        'MM25002': i > 17 ? null : (8000.0 + (i * 250)),
        'MM25003': i > 17 ? null : (9000.0 + (i * 350)),
        'MM25004': i > 17 ? null : (4000.0 + (i * 150)),
        'MM25005': i > 17 ? null : (1500.0 + (i * 100)),
        'MM2500DEV': null,
        'Other': null,
      };

      double total = 0;
      for (var value in unitData.values) {
        if (value != null) {
          total += value;
        }
      }

      data.add(DepartmentCollectionRow(
        date: dateStr,
        unitCollections: unitData,
        totalActual: total,
      ));
    }

    collections.assignAll(data);
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    _loadDummyData();
  }
}
