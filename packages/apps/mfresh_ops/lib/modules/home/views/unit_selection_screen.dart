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
class AttendanceUnitItem {
  final String id;
  final String name;
  final String location;
  final String image;

  AttendanceUnitItem({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
  });
}
// endregion

// region UnitSelectionScreen Widget
class UnitSelectionScreen extends StatefulWidget {
  const UnitSelectionScreen({super.key});

  static Future<AttendanceUnitItem?> show(BuildContext context) async {
    final result = await Get.toNamed(AppRoutes.unitSelection);
    return result is AttendanceUnitItem ? result : null;
  }

  @override
  State<UnitSelectionScreen> createState() => _UnitSelectionScreenState();
}
// endregion

// region UnitSelectionScreenState
class _UnitSelectionScreenState extends State<UnitSelectionScreen> {
  // region Observables & State Variables
  final _apiService = Get.find<ApiService>();
  final _searchController = TextEditingController();
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;
  final _unitList = <AttendanceUnitItem>[].obs;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // endregion

  // region API & Data Operations
  Future<void> _fetchUnits() async {
    _isLoading.value = true;
    try {
      final response = await _apiService.post(AppConstants.supportUnits, data: {});
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        _unitList.assignAll(data.map((e) {
          final id = (e['unitid'] ?? e['id'] ?? e['Unit_Id'])?.toString() ?? '';
          final name =
              (e['unitname'] ?? e['unit_name'] ?? e['Unit_Name'])?.toString() ?? id;
          final location = (e['district_name'] ??
                  e['unit_location'] ??
                  e['location'] ??
                  e['Unit_location'])
              ?.toString() ??
              '';
          var img =
              (e['unit_image'] ?? e['image'] ?? e['Unit_Image'])?.toString() ?? '';
          if (img.isNotEmpty && !img.startsWith('http')) {
            img = 'https://$img';
          }
          return AttendanceUnitItem(
            id: id,
            name: name,
            location: location,
            image: img,
          );
        }));
      }
    } catch (e) {
      debugPrint('Error loading units in UnitSelectionScreen: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  // endregion

  // region Computed Properties
  List<AttendanceUnitItem> get _filteredUnits {
    final query = _searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return _unitList;
    return _unitList.where((u) {
      return u.name.toLowerCase().contains(query) ||
          u.location.toLowerCase().contains(query) ||
          u.id.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<AttendanceUnitItem>> get _groupedUnits {
    final Map<String, List<AttendanceUnitItem>> grouped = {};
    for (final unit in _filteredUnits) {
      final locationKey = unit.location.isNotEmpty ? unit.location : 'Other';
      grouped.putIfAbsent(locationKey, () => []).add(unit);
    }
    return grouped;
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
        'Select Unit',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    final bool isDesktop = screenWidth > 1000;
    final int crossAxisCount = isDesktop ? 5 : (isTablet ? 3 : 2);
    final double childAspectRatio = isDesktop ? 2.2 : (isTablet ? 1.9 : 1.75);

    return Obx(() {
      if (_isLoading.value) {
        return const Center(child: CustomAppLoader(size: 40));
      }

      final grouped = _groupedUnits;
      if (grouped.isEmpty) {
        return Center(
          child: Text(
            'No units available',
            style: AppTextStyle.style_14_500(color: AppColors.grey300),
          ),
        );
      }

      return _buildUnitListView(
        grouped,
        crossAxisCount,
        childAspectRatio,
      );
    });
  }

  Widget _buildUnitListView(
    Map<String, List<AttendanceUnitItem>> grouped,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    final locations = grouped.keys.toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        for (final locationName in locations) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 14.h,
                bottom: 8.h,
              ),
              child: _buildLocationHeader(locationName),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: (grouped[locationName] ?? []).length,
              itemBuilder: (context, idx) {
                final unit = (grouped[locationName] ?? [])[idx];
                return _AttendanceUnitCard(
                  unit: unit,
                  onTap: () => Navigator.of(context).pop(unit),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: 16.h),
        ),
      ],
    );
  }

  Widget _buildLocationHeader(String locationName) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locationName,
            style: AppTextStyle.style_16_700(
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 2.h,
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }
  // endregion
}
// endregion

// region Card Widget
class _AttendanceUnitCard extends StatelessWidget {
  final AttendanceUnitItem unit;
  final VoidCallback onTap;

  const _AttendanceUnitCard({
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = unit.name;
    final subtitle = unit.location.isNotEmpty ? unit.location : '';
    final label = subtitle.isNotEmpty ? '$title, $subtitle' : title;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 1.2.r,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.14),
            blurRadius: 12.r,
            spreadRadius: 1.r,
            offset: Offset(0, 4.h),
          ),
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 4.r,
            spreadRadius: 0,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(9.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8.5.r)),
                  child: AppImageView(
                    imageUrl: unit.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.5.r)),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFF8D6E63),
                      width: 1.r,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Text(
                  label,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.style_11_700(
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// endregion
