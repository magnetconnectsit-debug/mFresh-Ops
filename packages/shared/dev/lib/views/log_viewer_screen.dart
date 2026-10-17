import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:services/log_service.dart';
import 'package:dev/controllers/log_viewer_controller.dart';

class LogViewerScreen extends GetView<LogViewerController> {
  const LogViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppCommonAppBar(
        title: const Text('Network Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            onPressed: controller.shareLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: controller.clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.filteredLogs.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.filteredLogs.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) => _buildLogTile(controller.filteredLogs[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search by URL or status...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.grey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLogTile(LogMessage log) {
    final color = log.isError ? Colors.red : (log.statusCode == 200 ? Colors.green : Colors.orange);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                log.request.method,
                style: AppTextStyle.style_10_700(color: color),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                log.request.path,
                style: AppTextStyle.style_14_600(color: AppColors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${log.statusCode ?? "ERR"} • ${log.timestamp.toString().split('.').first}',
          style: AppTextStyle.style_12_400(color: AppColors.grey300),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection(
                  'URL',
                  log.request.uri.toString(),
                  onCopy: () => controller.copyCurl(log),
                  copyButtonText: 'Copy cURL',
                ),
                SizedBox(height: 12.h),
                _buildDetailSection(
                  'Request Body',
                  controller.prettyJson(log.request.data),
                ),
                SizedBox(height: 12.h),
                _buildDetailSection(
                  log.isError ? 'Error Response' : 'Response Body',
                  controller.prettyJson(log.response?.data ?? log.error?.response?.data ?? log.error?.message),
                  onCopy: () => controller.copyResponse(log),
                  copyButtonText: 'Copy JSON',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content, {
    VoidCallback? onCopy,
    String copyButtonText = 'Copy',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
            if (onCopy != null)
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: Icon(Icons.copy_rounded, size: 14.sp, color: AppColors.primary),
                label: Text(copyButtonText, style: AppTextStyle.style_12_500(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SelectableText(
            content.isEmpty ? 'null' : content,
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: 'monospace',
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64.r, color: AppColors.grey200),
          SizedBox(height: 16.h),
          Text(
            'No Logs Captured',
            style: AppTextStyle.style_16_600(color: AppColors.grey300),
          ),
        ],
      ),
    );
  }
}
