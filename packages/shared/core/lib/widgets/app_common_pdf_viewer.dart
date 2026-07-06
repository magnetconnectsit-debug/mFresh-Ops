import 'dart:io';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_string_utils.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';

class AppCommonPdfViewer extends StatefulWidget {
  final String? pdfUrl;
  final String? filePath;
  final String title;

  const AppCommonPdfViewer({
    super.key,
    this.pdfUrl,
    this.filePath,
    required this.title,
  }) : assert(pdfUrl != null || filePath != null, 'Either pdfUrl or filePath must be provided');

  @override
  State<AppCommonPdfViewer> createState() => _AppCommonPdfViewerState();
}

class _AppCommonPdfViewerState extends State<AppCommonPdfViewer> {
  final RxBool _isDownloading = false.obs;
  final RxBool _isLoading = true.obs;
  late final PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<String?> _downloadPdf({bool silent = false}) async {
    if (_isDownloading.value) return null;

    _isDownloading.value = true;
    try {
      final dio = Dio();
      Directory? directory;

      if (Platform.isAndroid) {
        // Use standard Downloads folder for Android
        directory = Directory('/storage/emulated/0/Download/mFresh/Reports');
      } else {
        final baseDir = await getApplicationDocumentsDirectory();
        directory = Directory('${baseDir.path}/mFresh/Reports');
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName =
          '${widget.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';

      await dio.download(widget.pdfUrl!, filePath);

      if (!silent) {
        AppCommonToastMessage.show(
            message: 'Report saved to: $filePath',
            type: ToastType.success);
      }
      return filePath;
    } catch (e) {
      if (!silent) {
        AppCommonToastMessage.show(
            message: 'Failed to download report: $e',
            type: ToastType.error);
      }
      return null;
    } finally {
      _isDownloading.value = false;
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    final path = widget.filePath ?? await _downloadPdf(silent: true);
    if (path != null) {
      final box = context.findRenderObject() as RenderBox?;
      final rect = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Check out this ${widget.title}',
        sharePositionOrigin: rect,
      );
    } else {
      AppCommonToastMessage.show(message: 'Failed to prepare file for sharing', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(widget.title.sanitize),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => _sharePdf(ctx),
              icon: Icon(Icons.share_outlined, color: AppColors.primary, size: 22.sp),
            ),
          ),
          Obx(() => IconButton(
                onPressed: (_isDownloading.value || widget.filePath != null) ? null : () => _downloadPdf(),
                icon: _isDownloading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(Icons.download_rounded,
                        color: widget.filePath != null ? AppColors.grey300 : AppColors.primary, size: 24.sp),
              )),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          widget.filePath != null
              ? SfPdfViewer.file(
                  File(widget.filePath!),
                  controller: _pdfViewerController,
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    _isLoading.value = false;
                  },
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    _isLoading.value = false;
                    AppCommonToastMessage.show(message: 'Failed to load PDF: ${details.error}', type: ToastType.error);
                  },
                )
              : SfPdfViewer.network(
                  widget.pdfUrl!,
                  controller: _pdfViewerController,
                  key: ValueKey(widget.pdfUrl),
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    _isLoading.value = false;
                  },
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    _isLoading.value = false;
                    AppCommonToastMessage.show(message: 'Failed to load PDF: ${details.error}', type: ToastType.error);
                  },
                ),
          Obx(() => _isLoading.value
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomAppLoader(size: 40),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading Report...',
                          style: AppTextStyle.style_14_600(
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
