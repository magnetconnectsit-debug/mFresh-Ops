// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/selfie_attendance/selfie_attendance_logs_model.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_detail_controller.dart';
import 'package:mfresh_ops/modules/selfie_attendance/views/widgets/selfie_image_preview_dialog.dart';
// endregion

// region View
class SelfieAttendanceDetailTable extends StatelessWidget {
  const SelfieAttendanceDetailTable({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelfieAttendanceDetailController>();

    return Obx(() {
      final summary = controller.summary;
      final logs = controller.logs;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableCard(context, controller, logs),
          SizedBox(height: 8.h),
          _buildDailyTotalFooter(summary),
        ],
      );
    });
  }
  // endregion

  // region Section Builders
  Widget _buildTableCard(
    BuildContext context,
    SelfieAttendanceDetailController controller,
    List<SelfieAttendanceLogItem> logs,
  ) {
    return AppCommonTable<SelfieAttendanceLogItem>(
      items: logs,
      headingRowHeight: 24.h,
      cellVerticalPadding: 2.h,
      headingRowColor: AppColors.blue50,
      borderColor: AppColors.borderColor,
      headingTextStyle: AppTextStyle.style_11_700(color: AppColors.black),
      dataTextStyle: AppTextStyle.style_11_400(color: AppColors.black87),
      columns: _buildColumns(context, controller),
      emptyWidget: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'No check-in / check-out logs found for this date.',
            style: AppTextStyle.style_13_400(color: AppColors.grey500),
          ),
        ),
      ),
    );
  }

  List<AppTableColumn<SelfieAttendanceLogItem>> _buildColumns(
    BuildContext context,
    SelfieAttendanceDetailController controller,
  ) {
    return [
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'sl_no',
        title: 'Sl No.',
        width: 55.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            '${index + 1}',
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'unit',
        title: 'Unit',
        width: 90.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.unitName,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'check_in_time',
        title: 'Check-in Time',
        width: 140.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.checkInTime,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'check_in_selfie',
        title: 'Check-in Selfie',
        width: 100.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return _buildSelfieAction(
            context: context,
            controller: controller,
            imageUrl: item.checkInImageUrl,
            title: 'Check-in Selfie',
            timestamp: item.checkInTime,
            latitude: item.checkInLatitude,
            longitude: item.checkInLongitude,
            mapUrl: item.checkInMapUrl,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'check_in_gps',
        title: 'Check-in GPS',
        width: 90.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return _buildGpsAction(
            controller: controller,
            mapUrl: item.checkInMapUrl,
            latitude: item.checkInLatitude,
            longitude: item.checkInLongitude,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'check_out_time',
        title: 'Check-out Time',
        width: 140.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.checkoutTime.isNotEmpty ? item.checkoutTime : '—',
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'check_out_selfie',
        title: 'Check-out Selfie',
        width: 100.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return _buildSelfieAction(
            context: context,
            controller: controller,
            imageUrl: item.checkoutImageUrl,
            title: 'Check-out Selfie',
            timestamp: item.checkoutTime,
            latitude: item.checkoutLatitude,
            longitude: item.checkoutLongitude,
            mapUrl: item.checkoutMapUrl,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'check_out_gps',
        title: 'Check-out GPS',
        width: 90.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return _buildGpsAction(
            controller: controller,
            mapUrl: item.checkoutMapUrl,
            latitude: item.checkoutLatitude,
            longitude: item.checkoutLongitude,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'break_before',
        title: 'Break Before',
        width: 100.w,
        alignment: Alignment.center,
        sortable: false,
        cellColorGetter: (_) => AppColors.yellow.withValues(alpha: 0.15),
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.breakBefore,
            style: AppTextStyle.style_11_500(color: AppColors.orange),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceLogItem>(
        key: 'duration',
        title: 'Actual Duration',
        width: 110.w,
        alignment: Alignment.center,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.duration,
            style: AppTextStyle.style_11_500(color: AppColors.primary),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
    ];
  }

  Widget _buildSelfieAction({
    required BuildContext context,
    required SelfieAttendanceDetailController controller,
    required String? imageUrl,
    required String title,
    required String timestamp,
    String? latitude,
    String? longitude,
    String? mapUrl,
  }) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    if (!hasImage) {
      return Text(
        '—',
        style: AppTextStyle.style_11_400(color: AppColors.grey400),
      );
    }

    return InkWell(
      onTap: () => _showSelfiePreview(
        context: context,
        controller: controller,
        imageUrl: imageUrl,
        title: title,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
        mapUrl: mapUrl,
      ),
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16.r,
              height: 16.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.r),
                border: Border.all(color: AppColors.borderColor, width: 1.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppImageView(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget:
                    Icon(Icons.person, size: 12.r, color: AppColors.grey400),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'View',
              style: AppTextStyle.style_11_600(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsAction({
    required SelfieAttendanceDetailController controller,
    required String? mapUrl,
    required String? latitude,
    required String? longitude,
  }) {
    final hasCoords = (mapUrl != null && mapUrl.isNotEmpty) ||
        (latitude != null &&
            latitude.isNotEmpty &&
            longitude != null &&
            longitude.isNotEmpty);

    if (!hasCoords) {
      return Text(
        '—',
        style: AppTextStyle.style_11_400(color: AppColors.grey400),
      );
    }

    return InkWell(
      onTap: () => _openGpsMap(
        controller: controller,
        mapUrl: mapUrl,
        latitude: latitude,
        longitude: longitude,
      ),
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Map',
              style: AppTextStyle.style_11_600(color: AppColors.primary),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.location_on,
              size: 12.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTotalFooter(SelfieAttendanceSummary summary) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.aliceBlue,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.fieldBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.summarize_outlined, size: 13.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                'Daily Totals',
                style: AppTextStyle.style_11_700(color: AppColors.black),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Break: ',
                style: AppTextStyle.style_11_500(color: AppColors.grey600),
              ),
              Text(
                summary.breakDuration,
                style: AppTextStyle.style_11_700(color: AppColors.orange),
              ),
              SizedBox(width: 14.w),
              Text(
                'Worked: ',
                style: AppTextStyle.style_11_500(color: AppColors.grey600),
              ),
              Text(
                summary.actualDuration,
                style: AppTextStyle.style_11_700(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  void _showSelfiePreview({
    required BuildContext context,
    required SelfieAttendanceDetailController controller,
    required String? imageUrl,
    required String title,
    required String timestamp,
    String? latitude,
    String? longitude,
    String? mapUrl,
  }) {
    SelfieImagePreviewDialog.show(
      context: context,
      imageUrl: imageUrl,
      title: title,
      timestamp: timestamp,
      userName: controller.userName.value,
      latitude: latitude,
      longitude: longitude,
      mapUrl: mapUrl,
    );
  }

  void _openGpsMap({
    required SelfieAttendanceDetailController controller,
    required String? mapUrl,
    required String? latitude,
    required String? longitude,
  }) {
    controller.openMap(
      mapUrl: mapUrl,
      latitude: latitude,
      longitude: longitude,
    );
  }
  // endregion
}
// endregion
