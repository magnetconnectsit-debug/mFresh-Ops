import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class TicketDetailsScreen extends StatelessWidget {
  const TicketDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TicketDetailsController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Ticket Details',
          style: AppTextStyle.style_18_700(color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              _buildTicketIdHeader(context, controller),
              SizedBox(height: 12.h),
              _buildTopInfoCard(context, controller),
              SizedBox(height: 24.h),
              _buildCommentsModule(controller),
              SizedBox(height: 24.h),
              _buildTimelineSection(controller),
              SizedBox(height: 32.h),
              _buildHistoryModule(controller),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketIdHeader(BuildContext context, TicketDetailsController controller) {
    return Row(
      children: [
        Text('TICKET ID: ', style: AppTextStyle.style_16_700(color: AppColors.primary)),
        Text('123789456', style: AppTextStyle.style_16_600(color: AppColors.black)),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.editTicket),
          child: Icon(Icons.edit, size: 18.r, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTopInfoCard(BuildContext context, TicketDetailsController controller) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue100, width: 1.2),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoGrid(context, controller),
          SizedBox(height: 16.h),
          _buildDetailRow('Subject', 'Lorem Ipsum is simply dummy text of the printing.'),
          SizedBox(height: 12.h),
          _buildDetailRow('Description', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s htyn th unknown printer took a galley of type and scrambled type specimen book.'),
          SizedBox(height: 16.h),
          _buildAttachmentsRow(),
          SizedBox(height: 16.h),
          _buildInterestPartyRow(),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, TicketDetailsController controller) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.1),
        1: FlexColumnWidth(1.4),
        2: FlexColumnWidth(1.1),
        3: FlexColumnWidth(1.4),
      },
      children: [
        _buildTableRow('Status', 'WIP', 'Created By', 'Soumya Sahoo'),
        _buildTableRow('Priority', 'High', 'Created On', '12-03-2025, 12:33'),
        _buildTableRow('Category', 'Electrical', 'Modified On', '12-03-2025, 12:33'),
        _buildTableRow('Sub Category', 'Short Circuit', 'Resolved', '12-03-2025, 01:33'),
        _buildTableRow('Assignee', 'Tapas Ranjan', 'Follow-up', '12-03-2025, 13:33', isAssignee: true),
        _buildTableRow('Unit', 'MM25001', 'Ticket Age', '12-03-2025, 14:33'),
        TableRow(
          children: [
            _buildGridLabel('Project'),
            _buildGridValue('mFresh'),
            _buildGridLabel('Reminder'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: GestureDetector(
                onTap: () => _showReminderDialog(context),
                child: Row(
                  children: [
                    _buildInputBox(width: 28.w, child: Icon(Icons.calendar_today, size: 8.r, color: AppColors.grey300)),
                    SizedBox(width: 3.w),
                    _buildInputBox(width: 28.w, child: Icon(Icons.access_time, size: 8.r, color: AppColors.grey300)),
                  ],
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const SizedBox(),
            const SizedBox(),
            _buildGridLabel('Link Ticket'),
            _buildInputBox(height: 16.h),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String l1, String v1, String l2, String v2, {bool isAssignee = false}) {
    return TableRow(
      children: [
        _buildGridLabel(l1),
        _buildGridValue(v1),
        _buildGridLabel(l2),
        _buildGridValue(v2, color: isAssignee ? AppColors.primary : AppColors.black),
      ],
    );
  }

  Widget _buildGridLabel(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Text(text, style: AppTextStyle.style_8_700(color: AppColors.primary)),
    );
  }

  Widget _buildGridValue(String text, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Text(text, style: AppTextStyle.style_8_700(color: color ?? AppColors.black)),
    );
  }

  Widget _buildInputBox({double? width, double? height, Widget? child}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Container(
        width: width,
        height: height ?? 16.h,
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4.r)),
        child: child,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.style_11_700(color: AppColors.primary)),
        SizedBox(height: 4.h),
        Text(value, style: AppTextStyle.style_10_400(color: AppColors.black)),
      ],
    );
  }

  Widget _buildAttachmentsRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        Text('Attachments', style: AppTextStyle.style_11_700(color: AppColors.primary)),
        _buildAttachmentPill('Document.jpeg'),
        _buildAttachmentPill('Document.jpeg'),
      ],
    );
  }

  Widget _buildAttachmentPill(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: AppColors.orange50, borderRadius: BorderRadius.circular(15.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 12.r, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(name, style: AppTextStyle.style_10_500(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildInterestPartyRow() {
    return Row(
      children: [
        Text('Interest Party', style: AppTextStyle.style_11_700(color: AppColors.primary)),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 28.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6.r)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Email', style: AppTextStyle.style_10_400(color: AppColors.grey300)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsModule(TicketDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 40.w),
          child: Text('Comments', style: AppTextStyle.style_10_400(color: AppColors.grey400)),
        ),
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.h, right: 12.w),
              width: 12.r, height: 12.r,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12.r)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('COMMENTS', style: AppTextStyle.style_11_700(color: AppColors.primary)),
                        Obx(() => Row(
                          children: [
                            SizedBox(
                              width: 20.r, height: 20.r,
                              child: Checkbox(
                                value: controller.isInternal.value,
                                onChanged: (val) => controller.isInternal.value = val!,
                                activeColor: AppColors.primary,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Text('Mark Internal', style: AppTextStyle.style_10_700(color: AppColors.primary)),
                          ],
                        )),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 70.h,
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: AppColors.borderColor)),
                      child: Stack(
                        children: [
                          TextField(
                            controller: controller.commentController,
                            maxLines: 3,
                            style: AppTextStyle.style_11_400(color: AppColors.black),
                            decoration: InputDecoration(hintText: 'Write your comment', hintStyle: AppTextStyle.style_11_400(color: AppColors.grey300), border: InputBorder.none),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _showImagePickerOptions(controller),
                                  child: Icon(Icons.link, size: 18.r, color: AppColors.info),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () => controller.addComment(),
                                  child: Icon(Icons.send, size: 18.r, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => controller.selectedImages.isNotEmpty 
                      ? _buildSelectedImagesPreview(controller) 
                      : const SizedBox.shrink()),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => _showImagePickerOptions(controller),
                      child: _buildAttachmentPill('Upload Images'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedImagesPreview(TicketDetailsController controller) {
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(top: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.file(controller.selectedImages[index], width: 50.w, height: 50.h, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 0, right: 0,
                  child: GestureDetector(
                    onTap: () => controller.removeImage(index),
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 10.r, color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showImagePickerOptions(TicketDetailsController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Image', style: AppTextStyle.style_16_700(color: AppColors.black)),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(Icons.camera_alt, 'Camera', () {
                  Get.back();
                  controller.captureImage();
                }),
                _buildPickerOption(Icons.photo_library, 'Gallery', () {
                  Get.back();
                  controller.pickImages();
                }),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(color: AppColors.blue50, shape: BoxShape.circle),
            child: Icon(icon, size: 30.r, color: AppColors.info),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyle.style_12_600(color: AppColors.black)),
        ],
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reminder/ Notifications', style: AppTextStyle.style_16_700(color: AppColors.black)),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Text('Notification Type:', style: AppTextStyle.style_12_400(color: AppColors.black)),
                  const Spacer(),
                  Icon(Icons.chat_bubble_outline, size: 20.r, color: AppColors.success),
                  Checkbox(value: false, onChanged: (v) {}, activeColor: AppColors.primary),
                  Icon(Icons.notifications_none, size: 20.r, color: AppColors.black),
                  Checkbox(value: false, onChanged: (v) {}, activeColor: AppColors.primary),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text('Date/ Time:', style: AppTextStyle.style_12_400(color: AppColors.black)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.grey50), borderRadius: BorderRadius.circular(4.r)),
                      child: Row(
                        children: [
                          Text('Date', style: AppTextStyle.style_10_400(color: AppColors.grey200)),
                          const Spacer(),
                          Icon(Icons.calendar_today, size: 14.r, color: AppColors.grey200),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 80.w,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.grey50), borderRadius: BorderRadius.circular(4.r)),
                    child: Row(
                      children: [
                        Text('09:00 A.M.', style: AppTextStyle.style_10_400(color: AppColors.black)),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, size: 18.r),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.grey50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                      child: Text('Cancel', style: AppTextStyle.style_12_600(color: AppColors.white)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                      child: Text('Apply', style: AppTextStyle.style_12_600(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(TicketDetailsController controller) {
    return Stack(
      children: [
        Positioned(
          left: 5.5.w, top: 0, bottom: 0,
          child: Container(width: 1.w, color: AppColors.grey50),
        ),
        Obx(() => Column(
          children: controller.activities.map((activity) => _buildTimelineCard(activity)).toList(),
        )),
      ],
    );
  }

  Widget _buildTimelineCard(ActivityModel activity) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.h, right: 12.w),
            width: 12.r, height: 12.r,
            decoration: BoxDecoration(color: activity.color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.blue50),
                boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0, left: 12.w,
                    child: Icon(Icons.bookmark, size: 24.r, color: AppColors.info),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 32.h, 12.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimelineHeader(activity),
                        SizedBox(height: 12.h),
                        _buildTimelineContent('COMMENTS', activity.comment, isComment: true),
                        SizedBox(height: 12.h),
                        _buildTimelineAttachments(activity),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text('Updated On: ${activity.timestamp}', style: AppTextStyle.style_8_400(color: AppColors.grey200)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader(ActivityModel activity) {
    final String displayText = activity.isReverseAction 
        ? '${activity.action} ${activity.user}'
        : '${activity.user} ${activity.action}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90.w,
          child: Text('ACTIVITY', style: AppTextStyle.style_10_700(color: AppColors.primary)),
        ),
        Expanded(
          child: Text(
            displayText, 
            style: AppTextStyle.style_10_700(color: AppColors.primary),
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 18.r, color: AppColors.grey200),
          padding: EdgeInsets.zero,
          onSelected: (value) {
            Get.snackbar(value, 'Action triggered: $value');
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Edit', child: Text('Edit')),
            const PopupMenuItem(value: 'Delete', child: Text('Delete')),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineContent(String label, String value, {bool isComment = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(label, style: AppTextStyle.style_10_700(color: AppColors.primary)),
        ),
        Expanded(
          child: isComment ? _buildRichComment(value) : Text(value, style: AppTextStyle.style_10_400(color: AppColors.black)),
        ),
      ],
    );
  }

  Widget _buildRichComment(String text) {
    final List<TextSpan> spans = [];
    final parts = text.split(' ');
    for (final part in parts) {
      if (part.startsWith('@')) {
        spans.add(TextSpan(text: '$part ', style: AppTextStyle.style_10_700(color: AppColors.info)));
      } else {
        spans.add(TextSpan(text: '$part ', style: AppTextStyle.style_10_400(color: AppColors.black)));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildTimelineAttachments(ActivityModel activity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90.w,
          child: Text('ATTACHMENTS', style: AppTextStyle.style_10_700(color: AppColors.primary)),
        ),
        Expanded(
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildTimelineThumb(),
              _buildTimelineThumb(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineThumb() {
    return AppImageView(
      imageUrl: 'https://via.placeholder.com/150',
      width: 44.w,
      height: 44.w,
      borderRadius: 6.r,
    );
  }

  Widget _buildHistoryModule(TicketDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: AppTextStyle.style_10_400(color: AppColors.grey300)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.blue100)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(color: AppColors.blue100, borderRadius: BorderRadius.vertical(top: Radius.circular(12.r))),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text('Date', style: AppTextStyle.style_10_700(color: AppColors.grey200))),
                    Expanded(flex: 2, child: Text('User', style: AppTextStyle.style_10_700(color: AppColors.grey200))),
                    Expanded(flex: 5, child: Text('Action', style: AppTextStyle.style_10_700(color: AppColors.grey200))),
                  ],
                ),
              ),
              Obx(() => Column(
                children: controller.history.map((item) => _buildHistoryRow(item)).toList(),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryRow(HistoryModel item) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.white, width: 1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(item.date, style: AppTextStyle.style_10_700(color: AppColors.primary))),
          Expanded(flex: 2, child: Text(item.user, style: AppTextStyle.style_10_700(color: AppColors.primary))),
          Expanded(flex: 5, child: Text(item.action, style: AppTextStyle.style_10_700(color: AppColors.black))),
        ],
      ),
    );
  }
}
