import 'package:core/constants/app_colors.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/booking/controllers/booking_history_controller.dart';
import 'package:mfresh/data/models/booking_history_model.dart';
import 'package:intl/intl.dart';
import 'package:core/widgets/custom_app_loader.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingHistoryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        title: const Text('Booking History'),
        hasBackButton: true,
        backgroundColor: AppColors.background,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomAppLoader(size: 60));
        }

        if (controller.bookings.isEmpty) {
          return Center(
            child: Text(
              'No bookings found',
              style: AppTextStyle.style_14_400(color: AppColors.grey300),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: Column(
            children: [
              if (controller.showFilters) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  child: Row(
                    children: [
                      // Date Filter Dropdown
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.grey50),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedDateFilter.value,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                              style: AppTextStyle.style_12_400(color: AppColors.black),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedDateFilter.value = newValue;
                                }
                              },
                              items: ['All', 'Today', 'Yesterday'].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Mode Filter Dropdown
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.grey50),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedModeFilter.value,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                              style: AppTextStyle.style_12_400(color: AppColors.black),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedModeFilter.value = newValue;
                                }
                              },
                              items: ['All', 'Cash', 'Online'].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.grey50, thickness: 1),
              ],
              Expanded(
                child: Obx(() {
                  final list = controller.filteredBookings;
                  if (list.isEmpty) {
                    return Center(child: Text('No matching bookings', style: AppTextStyle.style_12_400(color: AppColors.grey200)));
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final booking = list[index];
                      return _BookingCard(booking: booking);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingHistoryModel booking;

  const _BookingCard({required this.booking});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.bookingConfirmed,
          arguments: {
            'bookingId': booking.bookingId,
            'encryptBookingId': booking.encryptBookingId,
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: AppColors.appCardDecoration(
          borderColor: AppColors.grey50,
          containerColor: AppColors.white,
          borderRadius: 8,
          isShadow: true,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Booking ID + Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BOOKING ID: ${booking.bookingId}',
                  style: AppTextStyle.style_14_600(color: AppColors.black),
                ),
                Text(
                  'Rs ${booking.totalAmount}',
                  style: AppTextStyle.style_14_600(color: AppColors.primary),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Date & Time
            Row(
              children: [
                Text(
                  _formatDate(booking.createdAt),
                  style: AppTextStyle.style_10_400(color: AppColors.grey200),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    '●',
                    style: AppTextStyle.style_10_400(color: AppColors.grey200),
                  ),
                ),
                Text(
                  _formatTime(booking.createdAt),
                  style: AppTextStyle.style_10_400(color: AppColors.grey200),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Unit No
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unit No.: ${booking.unitNo}',
                  style: AppTextStyle.style_10_400(color: AppColors.grey200),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More Details',
                        style: AppTextStyle.style_10_600(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.description,
                        size: 12.sp,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
