import 'dart:io';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/widgets/app_common_excel_viewer.dart';
import 'package:core/widgets/app_common_pdf_viewer.dart';

class AppExportUtils {
  AppExportUtils._();

  /// Exports data to an Excel (.xls) file and opens the in-app viewer.
  static Future<void> exportToExcel({
    required String title,
    required List<String> columns,
    required List<List<dynamic>> rows,
    String? fileName,
  }) async {
    try {
      // Create CSV content
      List<List<dynamic>> csvData = [columns, ...rows];
      String csv = const ListToCsvConverter().convert(csvData);

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final name = fileName ?? '${title.toLowerCase().replaceAll(' ', '_')}_export_${DateTime.now().millisecondsSinceEpoch}';
      final path = "${directory.path}/$name.xls";
      
      final file = File(path);
      await file.writeAsString(csv);

      AppCommonToastMessage.show(
        message: "$title exported to Excel successfully!",
        type: ToastType.success,
      );

      // Navigate to Excel Viewer
      Get.to(() => AppCommonExcelViewer(
            title: title,
            columns: columns,
            rows: rows,
            filePath: path,
          ));
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to export Excel: $e",
        type: ToastType.error,
      );
    }
  }

  /// Exports data to a PDF (currently launches dummy viewer)
  static Future<void> exportToPdf({
    required String title,
    String? pdfUrl,
  }) async {
    try {
      // In a real scenario, this would generate or fetch a PDF
      // For now, we use the standardized dummy flow
      Get.to(() => AppCommonPdfViewer(
            pdfUrl: pdfUrl ?? 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            title: title,
          ));

      AppCommonToastMessage.show(
        message: "$title report ready for viewing!",
        type: ToastType.success,
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to open PDF report: $e",
        type: ToastType.error,
      );
    }
  }
}
