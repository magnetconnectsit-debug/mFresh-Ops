import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/inventory_audit_controller.dart';
import 'widgets/audit_filter_widget.dart';
import 'widgets/audit_table_widget.dart';
import 'package:core/widgets/app_common_search_bar.dart';

class InventoryAuditScreen extends StatefulWidget {
  const InventoryAuditScreen({super.key});

  @override
  State<InventoryAuditScreen> createState() => _InventoryAuditScreenState();
}

class _InventoryAuditScreenState extends State<InventoryAuditScreen> {
  late final InventoryAuditController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InventoryAuditController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search Item or Category...',
                  onChanged: (v) => controller.searchQuery.value = v,
                )
              : Text(
                  'Inventory Audit',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
        child: Obx(() {
          if (controller.selectedUnitIds.isEmpty) {
            return _buildUnitSelectionView(context, controller);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuditFilterWidget(),
              SizedBox(height: 12.h),
              const Flexible(child: AuditTableWidget()),
              SizedBox(height: 30.h),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUnitSelectionView(
    BuildContext context,
    InventoryAuditController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final bool isTablet = screenWidth > 600;
        final bool isDesktop = screenWidth > 1000;
        final int crossAxisCount = isDesktop ? 5 : (isTablet ? 3 : 2);

        return Obx(() {
          if (controller.isLoadingUnits.value) {
            return const Center(child: CustomAppLoader(size: 50));
          }

          final grouped = controller.groupedUnitCards;
          if (grouped.isEmpty) {
            return Center(
              child: Text(
                'No units available',
                style: AppTextStyle.style_14_500(color: Colors.grey),
              ),
            );
          }

          final locations = grouped.keys.toList();

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 24.h),
            itemCount: locations.length,
            separatorBuilder: (context, index) => SizedBox(height: 20.h),
            itemBuilder: (context, index) {
              final locationName = locations[index];
              final unitsList = grouped[locationName] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location section header with underline (matching user sketch)
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
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
                  ),
                  SizedBox(height: 12.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: isDesktop ? 2.2 : (isTablet ? 1.9 : 1.75),
                    ),
                    itemCount: unitsList.length,
                    itemBuilder: (context, uIdx) {
                      final unit = unitsList[uIdx];
                      return _AuditSmallUnitCard(
                        unit: unit,
                        onTap: () {
                          controller.onUnitChanged({unit.id});
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }
}

class _AuditSmallUnitCard extends StatelessWidget {
  final AuditUnitCardItem unit;
  final VoidCallback onTap;

  const _AuditSmallUnitCard({
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = unit.shortForm.isNotEmpty ? unit.shortForm : unit.name;
    final subtitle = unit.location.isNotEmpty ? unit.location : '';
    final label = subtitle.isNotEmpty ? '$title, $subtitle' : title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                child: AppImageView(
                  imageUrl: unit.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF8D6E63), width: 1.0),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Text(
                label,
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
