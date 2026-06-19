import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:mfresh_ops/data/models/collections/old_collection_model.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/constants/app_colors.dart';

class OldCollectionsController extends GetxController {
  // Filters
  final selectedUnit = RxnString();
  final selectedMonthYear = RxnString();
  
  final unitOptions = <DropdownOption<String>>[
    DropdownOption(value: 'MM25002', label: 'MM25002'),
    DropdownOption(value: 'MM25003', label: 'MM25003'),
    DropdownOption(value: 'MM2500DEV', label: 'MM2500DEV'),
  ].obs;

  final monthYearOptions = <DropdownOption<String>>[
    DropdownOption(value: '2026-05', label: 'May 2026'),
    DropdownOption(value: '2026-04', label: 'April 2026'),
    DropdownOption(value: '2026-03', label: 'March 2026'),
  ].obs;

  // Search
  final isSearching = false.obs;
  final searchController = TextEditingController();

  // Summary Metrics
  final cashCollected = '₹5,98,035'.obs;
  final cashDeposited = '₹2,34,830'.obs;
  final cashInOffice = '₹3,63,205'.obs;
  final cashInUnits = '₹45,65,665'.obs;

  // Table Data
  final allCollections = <OldCollectionModel>[].obs;
  final filteredCollections = <OldCollectionModel>[].obs;
  final isLoading = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final itemsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

    allCollections.assignAll([
      OldCollectionModel(id: 1, date: '2026-05-11', unit: 'MM25003', dailyCash: '350', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 2, date: '2026-05-09', unit: 'MM25003', dailyCash: '100', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 3, date: '2026-05-08', unit: 'MM25003', dailyCash: '220', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 4, date: '2026-05-07', unit: 'MM25003', dailyCash: '4680', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 5, date: '2026-05-06', unit: 'MM25003', dailyCash: '8410', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 6, date: '2026-05-04', unit: 'MM25003', dailyCash: '750', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 7, date: '2026-05-02', unit: 'MM25002', dailyCash: '1120', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 8, date: '2026-04-16', unit: 'MM2500DEV', dailyCash: '20', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 9, date: '2026-04-15', unit: 'MM25002', dailyCash: '500', isCashCollection: true, isCashDeposit: true),
      OldCollectionModel(id: 10, date: '2026-04-14', unit: 'MM25003', dailyCash: '300', isCashCollection: false, isCashDeposit: false),
      OldCollectionModel(id: 11, date: '2026-04-13', unit: 'MM2500DEV', dailyCash: '1000', isCashCollection: true, isCashDeposit: false),
    ]);

    applyFilters();
    isLoading.value = false;
  }

  void applyFilters() {
    currentPage.value = 1;
    final query = searchController.text.toLowerCase();
    
    filteredCollections.assignAll(allCollections.where((item) {
      bool matchesSearch = query.isEmpty || 
          item.unit.toLowerCase().contains(query) || 
          item.date.toLowerCase().contains(query);
          
      bool matchesUnit = selectedUnit.value == null || item.unit == selectedUnit.value;
      
      // Simple month filter mockup
      bool matchesMonth = selectedMonthYear.value == null || 
          item.date.startsWith(selectedMonthYear.value!);

      return matchesSearch && matchesUnit && matchesMonth;
    }));
  }

  void resetFilters() {
    selectedUnit.value = null;
    selectedMonthYear.value = null;
    searchController.clear();
    applyFilters();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applyFilters();
    }
  }

  Future<void> onRefresh() async {
    resetFilters();
    _loadDummyData();
  }

  void toggleCashCollection(OldCollectionModel item, bool value) {
    item.isCashCollection = value;
    filteredCollections.refresh();
  }

  void toggleCashDeposit(OldCollectionModel item, bool value) {
    item.isCashDeposit = value;
    filteredCollections.refresh();
  }
  
  void showAddCommentSheet(OldCollectionModel item) {
    final commentController = TextEditingController();
    final charsLeft = 90.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        backgroundColor: const Color(0xFFEEF0F2), // Light greyish background from screenshot
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add/Edit Comment',
                style: AppTextStyle.style_18_700(color: const Color(0xFF4A4A4A)),
              ),
              SizedBox(height: 24.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: TextField(
                  controller: commentController,
                  maxLines: 4,
                  maxLength: 90,
                  onChanged: (val) {
                    charsLeft.value = 90 - val.length;
                  },
                  decoration: InputDecoration(
                    counterText: '', // Hide default counter
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.w),
                  ),
                  style: AppTextStyle.style_14_400(color: AppColors.black),
                ),
              ),
              SizedBox(height: 8.h),
              Obx(() => Text(
                    '${charsLeft.value} characters left',
                    style: AppTextStyle.style_12_400(color: Colors.grey.shade600),
                  )),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      AppCommonToastMessage.show(message: 'Comment saved!', type: ToastType.success);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5ECE), // Purple/Blue from screenshot
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      elevation: 0,
                    ),
                    child: Text('Save', style: AppTextStyle.style_14_600(color: Colors.white)),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C757D), // Grey from screenshot
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      elevation: 0,
                    ),
                    child: Text('Cancel', style: AppTextStyle.style_14_600(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pagination Getters
  List<OldCollectionModel> get paginatedItems {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;
    if (startIndex >= filteredCollections.length) return [];
    return filteredCollections.sublist(
        startIndex, endIndex > filteredCollections.length ? filteredCollections.length : endIndex);
  }

  int get totalPages => (filteredCollections.length / itemsPerPage.value).ceil();

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
