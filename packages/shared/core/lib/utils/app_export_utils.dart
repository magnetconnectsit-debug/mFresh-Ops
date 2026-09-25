import 'dart:io';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/widgets/app_common_excel_viewer.dart';
import 'package:core/widgets/app_common_pdf_viewer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  /// Exports data to a PDF file and opens the in-app viewer.
  static Future<void> exportToPdf({
    required String title,
    required List<String> columns,
    required List<List<dynamic>> rows,
    String? fileName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape.copyWith(
            marginBottom: 0.5 * PdfPageFormat.cm,
            marginLeft: 0.5 * PdfPageFormat.cm,
            marginRight: 0.5 * PdfPageFormat.cm,
            marginTop: 0.5 * PdfPageFormat.cm,
          ),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: columns,
              data: rows,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 20,
              cellAlignments: {
                for (var i = 0; i < columns.length; i++) i: pw.Alignment.centerLeft,
              },
            ),
          ],
        ),
      );

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final name = fileName ?? '${title.toLowerCase().replaceAll(' ', '_')}_export_${DateTime.now().millisecondsSinceEpoch}';
      final path = "${directory.path}/$name.pdf";
      
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      AppCommonToastMessage.show(
        message: "$title exported to PDF successfully!",
        type: ToastType.success,
      );

      // Navigate to PDF Viewer
      Get.to(() => AppCommonPdfViewer(
            filePath: path,
            title: title,
          ));
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to export PDF: $e",
        type: ToastType.error,
      );
    }
  }
}
