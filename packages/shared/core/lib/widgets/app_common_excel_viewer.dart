import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_string_utils.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class AppCommonExcelViewer extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<List<dynamic>> rows;
  final String filePath;

  const AppCommonExcelViewer({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    required this.filePath,
  });

  Future<void> _shareFile() async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: 'Check out this $title');
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to share file: $e',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        title: Text(title.sanitize),
        actions: [
          IconButton(
            onPressed: _shareFile,
            icon: Icon(Icons.share_outlined, color: AppColors.primary, size: 22.sp),
          ),
          // IconButton(
          //   onPressed: () {
          //     AppCommonToastMessage.show(
          //       message: 'File already saved at: $filePath',
          //       type: ToastType.success,
          //     );
          //   },
          //   icon: Icon(Icons.download_rounded, color: AppColors.primary, size: 24.sp),
          // ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            color: AppColors.white,
            child: Row(
              children: [
                Icon(Icons.table_chart_outlined, color: Colors.green, size: 24.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previewing: ${filePath.split('/').last}',
                        style: AppTextStyle.style_14_600(color: AppColors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${rows.length} rows exported',
                        style: AppTextStyle.style_12_400(color: AppColors.grey300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AppCommonTable(
              columns: columns,
              rows: rows.map((row) => row.map((cell) => cell.toString()).toList()).toList(),
              headingRowColor: AppColors.blue50,
            ),
          ),
        ],
      ),
    );
  }
}
