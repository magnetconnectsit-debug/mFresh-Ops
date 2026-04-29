import 'package:core/constants/app_colors.dart';
import 'package:core/routes/app_routes.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/home/controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Section
              Container(
                height: 220.h,
                color: AppColors.grey50,
                child: Stack(
                  children: [
                    // Placeholder Image
                    Center(
                      child: Icon(Icons.image, size: 80.sp, color: AppColors.grey200),
                    ),
                    // Dark Overlay
                    Container(color: AppColors.black.withValues(alpha: 0.4)),
                    // Banner Content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'WHEN LUXURY SANITATION,\nANYTIME, ANYWHERE!',
                            style: AppTextStyle.style_18_600(color: AppColors.white),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Elevate your comfort with premium,\nwell-maintained toilets, locker\nfacilities, and hygiene solutions from\nmFresh.',
                            style: AppTextStyle.style_10_400(color: AppColors.white),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.white),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              'EXPERIENCE NOW',
                              style: AppTextStyle.style_10_600(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Title and Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Text(
                          'Select a Unit',
                          style: AppTextStyle.style_18_600(color: AppColors.primary),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: AppColors.appCardDecoration(
                                borderColor: AppColors.grey200,
                                containerColor: AppColors.white,
                                borderRadius: 4,
                                isShadow: true,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.qr_code_scanner, size: 14.sp, color: AppColors.black),
                                  SizedBox(width: 4.w),
                                  Text('Scan', style: AppTextStyle.style_12_400(color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'State-of-the-art sanitation facilities, where luxury meets immaculate cleanliness.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.style_10_400(color: AppColors.black),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: AppColors.appCardDecoration(
                    borderColor: AppColors.primary,
                    containerColor: AppColors.primary,
                    borderRadius: 8,
                    isShadow: true,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Search',
                        style: AppTextStyle.style_14_600(color: AppColors.white),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Container(
                          decoration: AppColors.appCardDecoration(
                            borderColor: AppColors.grey50,
                            containerColor: AppColors.white,
                            borderRadius: 4,
                            isShadow: true,
                          ),
                          child: TextField(
                            onChanged: (val) => controller.cityController.value = val,
                            style: AppTextStyle.style_12_400(color: AppColors.black),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'City',
                              hintStyle: AppTextStyle.style_10_400(color: AppColors.grey300),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'OR',
                          style: AppTextStyle.style_12_600(color: AppColors.white),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: AppColors.appCardDecoration(
                            borderColor: AppColors.grey50,
                            containerColor: AppColors.white,
                            borderRadius: 4,
                            isShadow: true,
                          ),
                          child: TextField(
                            onChanged: (val) => controller.unitNumberController.value = val,
                            style: AppTextStyle.style_12_400(color: AppColors.black),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Unit Number',
                              hintStyle: AppTextStyle.style_10_400(color: AppColors.grey300),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Units Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.units.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.75, // Adjust this to match the screenshot ratio
                  ),
                  itemBuilder: (context, index) {
                    final unit = controller.units[index];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.serviceDetails,
                          arguments: {
                            'unitNo': unit['unitNo'],
                            'location': unit['location'],
                          },
                        );
                      },
                      child: Container(
                      decoration: AppColors.appCardDecoration(
                        borderColor: AppColors.grey50,
                        containerColor: AppColors.white,
                        borderRadius: 16,
                        isShadow: true,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Placeholder Image for Unit
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                              child: Container(
                                width: double.infinity,
                                color: AppColors.grey50,
                                child: Icon(Icons.image, size: 50.sp, color: AppColors.grey200),
                              ),
                            ),
                          ),
                          
                          // Unit Details
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Unit No.: ',
                                        style: AppTextStyle.style_10_400(color: AppColors.primary),
                                      ),
                                      TextSpan(
                                        text: unit['unitNo'],
                                        style: AppTextStyle.style_10_600(color: AppColors.primaryVariant), // Blue color
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  unit['location'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.style_10_400(color: AppColors.black),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  unit['timing'] ?? '',
                                  style: AppTextStyle.style_12_700(color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
