// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:services/api_services.dart';
// endregion

// region Model
class AttendanceEmployeeItem {
  final int id;
  final String name;
  final String mobile;
  final String role;
  final bool isOnDuty;
  final bool isCheckedIn;
  final String? imageUrl;

  AttendanceEmployeeItem({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    required this.isOnDuty,
    required this.isCheckedIn,
    this.imageUrl,
  });

  factory AttendanceEmployeeItem.fromJson(Map<String, dynamic> json) {
    final dynamic rawChecked = json['is_checked_in'];
    final bool isCheckedIn = rawChecked == true ||
        rawChecked == 1 ||
        rawChecked == '1' ||
        rawChecked == 'true';

    final dynamic rawDuty = json['is_on_duty'] ?? json['is_duty_on'];
    final bool isOnDuty = rawDuty == 1 ||
        rawDuty == '1' ||
        rawDuty == true ||
        rawDuty == 'true';

    final id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    var img = json['image_url']?.toString();
    if (img != null && (img.endsWith('/NA') || img.isEmpty)) {
      img = null;
    }

    return AttendanceEmployeeItem(
      id: id,
      name: json['name']?.toString() ?? 'Unknown',
      mobile: json['mobile']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isOnDuty: isOnDuty,
      isCheckedIn: isCheckedIn,
      imageUrl: img,
    );
  }
}
// endregion

// region EmployeeSelectionScreen Widget
class EmployeeSelectionScreen extends StatefulWidget {
  const EmployeeSelectionScreen({super.key});

  static Future<AttendanceEmployeeItem?> show(BuildContext context) async {
    final dynamic result = await Get.toNamed(AppRoutes.employeeSelection);
    if (result != null && result is AttendanceEmployeeItem) {
      return result;
    }
    return null;
  }

  @override
  State<EmployeeSelectionScreen> createState() => _EmployeeSelectionScreenState();
}
// endregion

// region EmployeeSelectionScreenState
class _EmployeeSelectionScreenState extends State<EmployeeSelectionScreen> {
  // region Observables & State Variables
  final _apiService = Get.find<ApiService>();
  final _searchController = TextEditingController();
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;
  final _employeeList = <AttendanceEmployeeItem>[].obs;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // endregion

  // region API & Data Operations
  Future<void> _fetchEmployees() async {
    _isLoading.value = true;
    try {
      final response = await _apiService.post(AppConstants.staffEmployees);
      if (response != null && response is Map && response['status'] == true) {
        final List emps = response['employees'] ?? [];
        _employeeList.assignAll(emps
            .whereType<Map>()
            .map((e) => AttendanceEmployeeItem.fromJson(Map<String, dynamic>.from(e)))
            .toList());
      }
    } catch (e) {
      debugPrint('Error loading employees in EmployeeSelectionScreen: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  // endregion

  // region Computed Properties
  List<AttendanceEmployeeItem> get _filteredEmployees {
    final query = _searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return _employeeList;
    return _employeeList.where((emp) {
      return emp.name.toLowerCase().contains(query) ||
          emp.mobile.toLowerCase().contains(query) ||
          emp.id.toString().contains(query);
    }).toList();
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: false,
      hasBackButton: true,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      title: Text(
        'Select Employee',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: Obx(() {
            if (_isLoading.value) {
              return const Center(child: CustomAppLoader());
            }

            final list = _filteredEmployees;
            if (list.isEmpty) {
              return Center(
                child: Text(
                  'No employees found',
                  style: AppTextStyle.style_13_400(color: AppColors.grey500),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _fetchEmployees,
              color: AppColors.primary,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: list.length,
                separatorBuilder: (_, __) => SizedBox(height: 6.h),
                itemBuilder: (context, index) {
                  final emp = list[index];
                  return _AttendanceEmployeeCard(
                    employee: emp,
                    onTap: () => Navigator.of(context).pop(emp),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: AppCommonSearchBar(
        controller: _searchController,
        hintText: 'Search employee name, mobile...',
        onChanged: (val) => _searchQuery.value = val,
        onClose: () {
          _searchController.clear();
          _searchQuery.value = '';
        },
      ),
    );
  }
  // endregion
}
// endregion

// region Card Widget
class _AttendanceEmployeeCard extends StatelessWidget {
  final AttendanceEmployeeItem employee;
  final VoidCallback onTap;

  const _AttendanceEmployeeCard({
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actionText = employee.isCheckedIn ? 'Check Out' : 'Check In';
    final actionColor = employee.isCheckedIn ? AppColors.red : AppColors.primaryGreen;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.grey200,
          width: 1.r,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: Offset(0, 1.5.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                // Employee Name
                Expanded(
                  child: Text(
                    employee.name,
                    style: AppTextStyle.style_13_600(color: AppColors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10.w),
                // Compact Solid Color Check In / Check Out Button with Fixed Width
                Container(
                  width: 82.w,
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  decoration: BoxDecoration(
                    color: actionColor,
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: [
                      BoxShadow(
                        color: actionColor.withValues(alpha: 0.3),
                        blurRadius: 4.r,
                        offset: Offset(0, 1.5.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        actionText,
                        style: AppTextStyle.style_11_700(color: AppColors.white),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 9.sp,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// endregion
