// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/service_details/controllers/service_details_controller.dart';
// endregion

// region ServiceCard Class
class ServiceCard extends StatelessWidget {
  // region Dependencies & Fields
  final ServiceDetailsController controller;
  final int index;
  // endregion

  // region Constructor
  const ServiceCard({super.key, required this.controller, required this.index});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final service = controller.services[index];
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Obx(() {
      final bool isOnline = controller.isOnline.value;
      final bool isAdded = service.quantity.value > 0;

      // Online active theme: Orange #F15A24, Card bg #FFF5EE, Counter bg #FFBA87
      // Offline active theme: Blue #0288D1, Card bg #E8F4FD, Counter bg #A6D8F8
      // Unselected theme: Border #E2E8F0, Card bg #FFFFFF, Counter bg #F8FAFC, Counter border #CBD5E1
      final Color activeBorder =
          isOnline ? const Color(0xFFF15A24) : const Color(0xFF0288D1);
      final Color activeCardBg =
          isOnline ? const Color(0xFFFFF5EE) : const Color(0xFFE8F4FD);
      final Color activeCounterBg =
          isOnline ? const Color(0xFFFFBA87) : const Color(0xFFA6D8F8);

      final Color cardBorderColor =
          isAdded ? activeBorder : const Color(0xFFE2E8F0);
      final Color cardBgColor = isAdded ? activeCardBg : AppColors.white;
      final Color counterBorderColor =
          isAdded ? activeBorder : const Color(0xFFCBD5E1);
      final Color counterBgColor =
          isAdded ? activeCounterBg : const Color(0xFFF8FAFC);

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 8.w : 6.w,
          vertical: isTablet ? 6.h : 4.h,
        ),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(isTablet ? 12.r : 10.r),
          border: Border.all(
            color: cardBorderColor,
            width: isAdded ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isAdded
                  ? activeBorder.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image Thumbnail Container
            Container(
              height: isTablet ? 48.r : 46.w,
              width: isTablet ? 48.r : 46.w,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: AppImageView(
                imageUrl: service.image,
                fit: BoxFit.contain,
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox(width: isTablet ? 8.w : 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isTablet
                        ? AppTextStyle.style_12_600(
                            color: const Color(0xFF0F172A),
                          )
                        : AppTextStyle.style_11_600(
                            color: const Color(0xFF0F172A),
                          ),
                  ),
                  SizedBox(height: isTablet ? 2.h : 2.h),
                  Row(
                    children: [
                      Text(
                        '₹ ${service.price}',
                        style: isTablet
                            ? AppTextStyle.style_12_700(
                                color: const Color(0xFF0F172A),
                              )
                            : AppTextStyle.style_10_700(
                                color: const Color(0xFF0F172A),
                              ),
                      ),
                      Text(
                        ' /Use',
                        style: isTablet
                            ? AppTextStyle.style_11_500(
                                color: const Color(0xFF64748B),
                              )
                            : AppTextStyle.style_10_500(
                                color: const Color(0xFF64748B),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 4.h : 3.h),
                  // Compact Counter
                  Container(
                    height: isTablet ? 26.h : 24.h,
                    decoration: BoxDecoration(
                      color: counterBgColor,
                      border: Border.all(
                        color: counterBorderColor,
                        width: 1.1,
                      ),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.decrement(index),
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: isTablet ? 17.sp : 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${service.quantity.value}',
                          style: isTablet
                              ? AppTextStyle.style_12_700(
                                  color: AppColors.black,
                                )
                              : AppTextStyle.style_11_700(
                                  color: AppColors.black,
                                ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.increment(index),
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              child: Text(
                                '+',
                                style: TextStyle(
                                  fontSize: isTablet ? 17.sp : 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
  // endregion
}
