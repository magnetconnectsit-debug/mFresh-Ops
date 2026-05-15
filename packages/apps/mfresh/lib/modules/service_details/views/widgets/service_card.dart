import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/service_details/controllers/service_details_controller.dart';

class ServiceCard extends StatelessWidget {
  final ServiceDetailsController controller;
  final int index;

  const ServiceCard({super.key, required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final service = controller.services[index];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: AppColors.appCardDecoration(
        borderColor: AppColors.grey50,
        containerColor: AppColors.white,
        borderRadius: 12,
        isShadow: true,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImageView(
            imageUrl: service.image!,
            height: 50.w,
            width: 50.w,
            borderRadius: 10.r,
            fit: BoxFit.fill,
            backgroundColor: AppColors.primary,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.style_11_500(color: AppColors.black),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      '₹ ${service.price}',
                      style: AppTextStyle.style_10_600(color: AppColors.black),
                    ),
                    Text(
                      ' / use',
                      style: AppTextStyle.style_10_500(
                        color: AppColors.grey300,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Compact Counter
                Obx(() {
                  final bool isAdded = service.quantity.value > 0;
                  final Color themeColor = AppColors.pineBlue;
                  return Container(
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: isAdded ? themeColor : AppColors.white,
                      border: Border.all(color: themeColor, width: 1.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.decrement(index),
                          child: Container(
                            width: 32.w,
                            alignment: Alignment.center,
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: isAdded
                                    ? AppColors.white
                                    : AppColors.black,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${service.quantity.value}',
                          style: AppTextStyle.style_12_700(
                            color: isAdded ? AppColors.white : AppColors.black,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.increment(index),
                          child: Container(
                            width: 32.w,
                            alignment: Alignment.center,
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: isAdded
                                    ? AppColors.white
                                    : AppColors.black,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
