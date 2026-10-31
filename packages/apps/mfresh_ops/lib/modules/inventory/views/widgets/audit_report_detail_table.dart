// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/inventory/audit_report_model.dart';
import '../../controllers/audit_report_controller.dart';
import 'audit_table_widget.dart' show openFullScreenImageViewer;
// endregion

// region View
class AuditReportDetailTable extends StatefulWidget {
  final AuditDetailData detail;

  const AuditReportDetailTable({
    super.key,
    required this.detail,
  });

  @override
  State<AuditReportDetailTable> createState() => _AuditReportDetailTableState();
}
// endregion

// region State
class _AuditReportDetailTableState extends State<AuditReportDetailTable> {
  // region Dependencies & Controllers
  late final ScrollController _hScrollController;
  final AuditReportController controller = Get.find<AuditReportController>();
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);
  late Widget _cachedHeader;
  late List<Widget> _cachedRows;
  // endregion

  // region Dimensions
  static double get itemWidth => 160.w;
  static double get categoryWidth => 140.w;
  static double get unitWidth => 110.w;

  static double get systemQtyWidth => 75.w;
  static double get actualQtyWidth => 75.w;
  static double get diffQtyWidth => 75.w;
  static double get imageWidth => 55.w;
  static double get resultWidth => 75.w;
  static double get perUnitGroupWidth =>
      systemQtyWidth + actualQtyWidth + diffQtyWidth + imageWidth + resultWidth;

  static double get totalSystemQtyWidth => 100.w;
  static double get totalActualQtyWidth => 100.w;
  static double get totalDiffQtyWidth => 100.w;
  static double get overallGroupWidth =>
      totalSystemQtyWidth + totalActualQtyWidth + totalDiffQtyWidth;

  double get totalTableWidth =>
      itemWidth +
      categoryWidth +
      unitWidth +
      (widget.detail.unitList.length * perUnitGroupWidth) +
      overallGroupWidth;

  static double get tier1Height => 22.h;
  static double get tier2Height => 22.h;
  static double get totalHeaderHeight => tier1Height + tier2Height;
  static double get defaultRowHeight => 22.h;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _hScrollController = ScrollController();
    _hScrollController.addListener(_onScroll);
    _cachedHeader = _buildUnifiedHeader();
    _cachedRows = _buildDataRows();
  }

  @override
  void didUpdateWidget(covariant AuditReportDetailTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail != widget.detail) {
      _cachedHeader = _buildUnifiedHeader();
      _cachedRows = _buildDataRows();
    }
  }

  void _onScroll() {
    if (_hScrollController.hasClients &&
        _hScrollController.position.maxScrollExtent > 0) {
      final progress = (_hScrollController.offset /
              _hScrollController.position.maxScrollExtent)
          .clamp(0.0, 1.0);
      if (_scrollProgress.value != progress) {
        _scrollProgress.value = progress;
      }
    }
  }

  @override
  void dispose() {
    _hScrollController.removeListener(_onScroll);
    _hScrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.grey50),
      ),
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Existing Inventory Items — Unit-wise Comparison',
                    style: AppTextStyle.style_14_700(
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Matrix Table
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: widget.detail.matrix.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Center(
                        child: Text(
                          'No existing inventory items found.',
                          style: AppTextStyle.style_13_400(
                            color: AppColors.grey400,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          controller: _hScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          child: SizedBox(
                            width: totalTableWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _cachedHeader,
                                ..._cachedRows,
                              ],
                            ),
                          ),
                        ),
                        _buildTableSlider(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Header Builders
  Widget _buildUnifiedHeader() {
    return Container(
      height: totalHeaderHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFE5EEF8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Spanned Single-block Header Columns (Vertically & Horizontally Center-aligned)
          _buildSpannedHeaderCell('Item', itemWidth),
          _buildSpannedHeaderCell('Category', categoryWidth),
          _buildSpannedHeaderCell('Measurement Unit', unitWidth, isGroupEnd: true),

          // Double-row Header Block for Unit Groups & Overall Total (immune to fractional overflow)
          SizedBox(
            width: (widget.detail.unitList.length * perUnitGroupWidth) +
                overallGroupWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier 1: Group Titles
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...widget.detail.unitList.map((unit) {
                          return _buildGroupHeaderCell(
                            unit.unitName,
                            perUnitGroupWidth,
                            isGroupEnd: true,
                          );
                        }),
                        _buildGroupHeaderCell(
                          'Overall Total',
                          overallGroupWidth,
                        ),
                      ],
                    ),
                  ),
                ),

                // Tier 2: Sub-column Titles
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...widget.detail.unitList.expand((unit) {
                        return [
                          _buildSubHeaderCell('System Qty', systemQtyWidth),
                          _buildSubHeaderCell('Actual Qty', actualQtyWidth),
                          _buildSubHeaderCell('Difference', diffQtyWidth),
                          _buildSubHeaderCell('Image', imageWidth),
                          _buildSubHeaderCell(
                            'Result',
                            resultWidth,
                            isGroupEnd: true,
                          ),
                        ];
                      }),
                      _buildSubHeaderCell('Total System Qty', totalSystemQtyWidth),
                      _buildSubHeaderCell('Total Actual Qty', totalActualQtyWidth),
                      _buildSubHeaderCell('Total Difference', totalDiffQtyWidth),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpannedHeaderCell(
    String title,
    double width, {
    bool isGroupEnd = false,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isGroupEnd ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
            width: isGroupEnd ? 1.5 : 1.0,
          ),
        ),
      ),
      child: Text(
        title,
        style: AppTextStyle.style_11_700(
          color: const Color(0xFF1E293B),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildGroupHeaderCell(
    String title,
    double width, {
    bool isGroupEnd = false,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isGroupEnd ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
            width: isGroupEnd ? 1.5 : 1.0,
          ),
        ),
      ),
      child: Text(
        title,
        style: AppTextStyle.style_11_700(
          color: const Color(0xFF1E293B),
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubHeaderCell(
    String title,
    double width, {
    bool isGroupEnd = false,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isGroupEnd ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
            width: isGroupEnd ? 1.5 : 1.0,
          ),
        ),
      ),
      child: Text(
        title,
        style: AppTextStyle.style_10_600(
          color: const Color(0xFF334155),
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  // endregion

  // region Row Builders
  List<Widget> _buildDataRows() {
    final matrix = widget.detail.matrix;

    return matrix.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isEven = index % 2 == 0;

      return Container(
        height: defaultRowHeight,
        decoration: BoxDecoration(
          color: isEven ? AppColors.white : const Color(0xFFF8FAFC),
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
        ),
        child: Row(
          children: [
            // Fixed Columns Data
            _buildTextCell(item.name, itemWidth, isBold: true),
            _buildTextCell(item.category, categoryWidth),
            _buildTextCell(item.unit, unitWidth, isCenter: true, isGroupEnd: true),

            // Per Unit Cells
            ...widget.detail.unitList.expand((unit) {
              final cellKey1 = unit.auditId.toString();
              final cellKey2 = unit.id.toString();
              final cellKey3 = unit.unitId.toString();

              final cell = item.cells[cellKey1] ??
                  item.cells[cellKey2] ??
                  item.cells[cellKey3];

              final sysDisplay = cell?.systemDisplay.isNotEmpty == true
                  ? cell!.systemDisplay
                  : _formatQty(cell?.system);
              final actDisplay = cell?.actualDisplay.isNotEmpty == true
                  ? cell!.actualDisplay
                  : _formatQty(cell?.actual);
              final diffDisplay = cell?.diffDisplay.isNotEmpty == true
                  ? cell!.diffDisplay
                  : _formatQty(cell?.diff);
              final diffNum = cell?.diff ?? 0;
              final isDiffNegative = diffNum < 0;
              final result = cell?.result ?? '-';

              return [
                _buildTextCell(
                  sysDisplay,
                  systemQtyWidth,
                  isCenter: true,
                ),
                _buildTextCell(
                  actDisplay,
                  actualQtyWidth,
                  isCenter: true,
                ),
                _buildTextCell(
                  diffDisplay,
                  diffQtyWidth,
                  isCenter: true,
                  isBold: isDiffNegative,
                  backgroundColor:
                      isDiffNegative ? const Color(0xFFFEE2E2) : null,
                  textColor: isDiffNegative ? const Color(0xFFDC2626) : null,
                ),
                _buildImageCell(cell, imageWidth),
                _buildResultCell(result, resultWidth, isGroupEnd: true),
              ];
            }),

            // Overall Total Data
            _buildTextCell(
              item.overallTotal.systemDisplay.isNotEmpty
                  ? item.overallTotal.systemDisplay
                  : _formatQty(item.overallTotal.system),
              totalSystemQtyWidth,
              isCenter: true,
              isBold: true,
            ),
            _buildTextCell(
              item.overallTotal.actualDisplay.isNotEmpty
                  ? item.overallTotal.actualDisplay
                  : _formatQty(item.overallTotal.actual),
              totalActualQtyWidth,
              isCenter: true,
              isBold: true,
            ),
            _buildTextCell(
              item.overallTotal.diffDisplay.isNotEmpty
                  ? item.overallTotal.diffDisplay
                  : _formatQty(item.overallTotal.diff),
              totalDiffQtyWidth,
              isCenter: true,
              isBold: true,
              backgroundColor: item.overallTotal.diff < 0
                  ? const Color(0xFFFEE2E2)
                  : null,
              textColor: item.overallTotal.diff < 0
                  ? const Color(0xFFDC2626)
                  : null,
            ),
          ],
        ),
      );
    }).toList();
  }
  // endregion

  // region Cell Builders
  Widget _buildTextCell(
    String text,
    double width, {
    bool isCenter = false,
    bool isBold = false,
    bool isGroupEnd = false,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(
            color: isGroupEnd ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
            width: isGroupEnd ? 1.5 : 1.0,
          ),
        ),
      ),
      child: Text(
        text,
        style: isBold
            ? AppTextStyle.style_11_600(color: textColor ?? AppColors.grey900)
            : AppTextStyle.style_11_400(color: textColor ?? AppColors.grey800),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImageCell(AuditCellData? cell, double width) {
    final imageList = <String>[];
    if (cell?.image != null && cell!.image!.isNotEmpty) {
      imageList.add(cell.image!);
    }
    if (cell?.images != null) {
      for (var img in cell!.images) {
        if (img.isNotEmpty && !imageList.contains(img)) {
          imageList.add(img);
        }
      }
    }

    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: imageList.isNotEmpty
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => openFullScreenImageViewer(context, imageList),
                borderRadius: BorderRadius.circular(3.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: Container(
                    width: 16.w,
                    height: 16.h,
                    color: AppColors.grey100,
                    child: AppImageView(
                      imageUrl: imageList.first,
                      fit: BoxFit.cover,
                      memCacheWidth: 64,
                      memCacheHeight: 64,
                    ),
                  ),
                ),
              ),
            )
          : Text(
              '—',
              style: AppTextStyle.style_11_400(color: AppColors.grey400),
            ),
    );
  }

  Widget _buildResultCell(
    String result,
    double width, {
    bool isGroupEnd = false,
  }) {
    final isShortage = result.toLowerCase() == 'shortage';
    Color textColor;
    Color? backgroundColor;

    switch (result.toLowerCase()) {
      case 'matched':
        textColor = const Color(0xFF0F766E);
        break;
      case 'excess':
        textColor = const Color(0xFFD97706);
        break;
      case 'shortage':
        textColor = const Color(0xFFDC2626);
        backgroundColor = const Color(0xFFFEE2E2);
        break;
      default:
        textColor = AppColors.grey800;
        break;
    }

    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(
            color: isGroupEnd ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
            width: isGroupEnd ? 1.5 : 1.0,
          ),
        ),
      ),
      child: Text(
        result,
        style: isShortage
            ? AppTextStyle.style_10_700(color: textColor)
            : AppTextStyle.style_10_600(color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatQty(num? value) {
    if (value == null) return '0';
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }
  // endregion

  // region Slider Builder
  Widget _buildTableSlider() {
    return Container(
      height: 22.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Left Scroll Arrow
          InkWell(
            onTap: () {
              if (_hScrollController.hasClients) {
                final target = (_hScrollController.offset - 120.w)
                    .clamp(0.0, _hScrollController.position.maxScrollExtent);
                _hScrollController.animateTo(
                  target,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            borderRadius: BorderRadius.circular(4.r),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 16.r,
                color: AppColors.grey600,
              ),
            ),
          ),
          SizedBox(width: 4.w),

          // Interactive Slider Track
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                final thumbWidth = 44.w;
                final maxThumbOffset = (trackWidth - thumbWidth).clamp(0.0, trackWidth);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    if (_hScrollController.hasClients &&
                        _hScrollController.position.maxScrollExtent > 0 &&
                        maxThumbOffset > 0) {
                      final deltaFraction = details.delta.dx / maxThumbOffset;
                      final newOffset = (_hScrollController.offset +
                              deltaFraction *
                                  _hScrollController.position.maxScrollExtent)
                          .clamp(
                        0.0,
                        _hScrollController.position.maxScrollExtent,
                      );
                      _hScrollController.jumpTo(newOffset);
                    }
                  },
                  onTapDown: (details) {
                    if (_hScrollController.hasClients &&
                        _hScrollController.position.maxScrollExtent > 0 &&
                        trackWidth > 0) {
                      final tapFraction =
                          (details.localPosition.dx / trackWidth).clamp(0.0, 1.0);
                      final newOffset =
                          tapFraction * _hScrollController.position.maxScrollExtent;
                      _hScrollController.jumpTo(newOffset);
                    }
                  },
                  child: Container(
                    height: 14.h,
                    alignment: Alignment.center,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        final thumbOffset =
                            (progress * maxThumbOffset).clamp(0.0, maxThumbOffset);

                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Track Line
                            Container(
                              width: double.infinity,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            // Draggable Thumb
                            Positioned(
                              left: thumbOffset,
                              child: Container(
                                width: thumbWidth,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF009BD9),
                                  borderRadius: BorderRadius.circular(5.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 4.w),

          // Right Scroll Arrow
          InkWell(
            onTap: () {
              if (_hScrollController.hasClients) {
                final target = (_hScrollController.offset + 120.w)
                    .clamp(0.0, _hScrollController.position.maxScrollExtent);
                _hScrollController.animateTo(
                  target,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            borderRadius: BorderRadius.circular(4.r),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16.r,
                color: AppColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // endregion
}
// endregion
