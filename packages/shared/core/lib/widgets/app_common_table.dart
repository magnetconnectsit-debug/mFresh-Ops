import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

enum AppTableSortOrder { none, ascending, descending }

class AppTableColumn<T> {
  final String key;
  final String title;
  final Widget? headerWidget;
  final double? width;
  final double minWidth;
  final bool sortable;
  final AlignmentGeometry alignment;
  final Widget Function(BuildContext context, T item, int index, bool isExpanded)? cellBuilder;
  final String Function(T item)? valueGetter;
  final Color? Function(T item)? cellColorGetter;

  const AppTableColumn({
    required this.key,
    required this.title,
    this.headerWidget,
    this.width,
    this.minWidth = 40.0,
    this.sortable = true,
    this.alignment = Alignment.centerLeft,
    this.cellBuilder,
    this.valueGetter,
    this.cellColorGetter,
  });
}

class AppCommonTable<T> extends StatefulWidget {
  /// Typed data items list. If provided, rows are generated from items & columns.
  final List<T>? items;

  /// Dynamic column definitions.
  final List<AppTableColumn<T>>? columns;

  /// Legacy String column titles (if columns is null).
  final List<String>? columnTitles;

  /// Legacy raw row matrix (if items is null).
  final List<List<dynamic>>? rows;

  /// Custom initial column widths map: column index -> width double
  final Map<int, double>? columnWidths;

  /// Callback when column title sort is clicked (columnKey, sortOrder)
  final void Function(String columnKey, AppTableSortOrder sortOrder)? onSort;

  /// Currently sorted column key
  final String? currentSortColumn;

  /// Currently active sort order
  final AppTableSortOrder? currentSortOrder;

  /// Callback when a row is clicked (item, index)
  final void Function(T item, int index)? onRowTap;

  /// Custom expanded row indices. If null, managed internally.
  final Set<int>? expandedRowIndices;

  /// Callback when row expansion state toggles
  final void Function(int index, bool isExpanded)? onRowExpandToggle;

  /// Custom background color builder per row item
  final Color Function(T item, int index)? rowColorBuilder;

  /// Custom decoration builder per row item (for custom row borders, status highlights)
  final BoxDecoration Function(T item, int index)? rowDecorationBuilder;

  /// Heading row background color (Defaults to reference soft blue: Color(0xFFDCE5F8))
  final Color? headingRowColor;

  /// Heading row border/divider color (Defaults to white)
  final Color? headingBorderColor;

  /// Heading text style
  final TextStyle? headingTextStyle;

  /// Data text style
  final TextStyle? dataTextStyle;

  /// Table grid border color
  final Color? borderColor;

  /// Height of heading row
  final double? headingRowHeight;

  /// Empty state widget
  final Widget? emptyWidget;

  /// Empty text message
  final String? emptyText;

  /// Loading state flag
  final bool isLoading;

  /// Enable draggable column width resizing handles
  final bool enableColumnResizing;

  /// Show alternating striped rows
  final bool showStripedRows;

  /// Horizontal padding inside data cells
  final double? cellHorizontalPadding;

  /// Vertical padding inside data cells
  final double? cellVerticalPadding;

  const AppCommonTable({
    super.key,
    this.items,
    this.columns,
    this.columnTitles,
    this.rows,
    this.columnWidths,
    this.onSort,
    this.currentSortColumn,
    this.currentSortOrder,
    this.onRowTap,
    this.expandedRowIndices,
    this.onRowExpandToggle,
    this.rowColorBuilder,
    this.rowDecorationBuilder,
    this.headingRowColor,
    this.headingBorderColor,
    this.headingTextStyle,
    this.dataTextStyle,
    this.borderColor,
    this.headingRowHeight,
    this.emptyWidget,
    this.emptyText,
    this.isLoading = false,
    this.enableColumnResizing = false,
    this.showStripedRows = false,
    this.cellHorizontalPadding,
    this.cellVerticalPadding,
  });

  @override
  State<AppCommonTable<T>> createState() => _AppCommonTableState<T>();
}

class _AppCommonTableState<T> extends State<AppCommonTable<T>> {
  final Map<int, double> _widths = {};
  late Set<int> _internalExpandedRows;

  // Internal sort state if not controlled externally
  String? _internalSortColumn;
  AppTableSortOrder _internalSortOrder = AppTableSortOrder.none;

  @override
  void initState() {
    super.initState();
    _internalExpandedRows = {};
    _internalSortColumn = widget.currentSortColumn;
    _internalSortOrder = widget.currentSortOrder ?? AppTableSortOrder.none;
    _initWidths();
  }

  @override
  void didUpdateWidget(covariant AppCommonTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initWidths(oldWidget);
    if (widget.currentSortColumn != null) {
      _internalSortColumn = widget.currentSortColumn;
    }
    if (widget.currentSortOrder != null) {
      _internalSortOrder = widget.currentSortOrder!;
    }
  }

  void _initWidths([AppCommonTable<T>? oldWidget]) {
    if (widget.columns != null) {
      for (int i = 0; i < widget.columns!.length; i++) {
        final col = widget.columns![i];
        final oldCol = (oldWidget?.columns != null && i < oldWidget!.columns!.length)
            ? oldWidget.columns![i]
            : null;
        final customW = widget.columnWidths?[i];

        if (customW != null) {
          _widths[i] = customW;
        } else if (!_widths.containsKey(i) ||
            (oldCol != null && oldCol.width != col.width)) {
          if (col.width != null) {
            _widths[i] = col.width!;
          } else if (!_widths.containsKey(i)) {
            _widths[i] = 100.w;
          }
        }
      }
    } else if (widget.columnTitles != null) {
      for (int i = 0; i < widget.columnTitles!.length; i++) {
        final customW = widget.columnWidths?[i];
        if (customW != null) {
          _widths[i] = customW;
        } else if (!_widths.containsKey(i)) {
          _widths[i] = 100.w;
        }
      }
    }
  }

  Set<int> get _activeExpandedRows =>
      widget.expandedRowIndices ?? _internalExpandedRows;

  String? get _activeSortColumn =>
      widget.currentSortColumn ?? _internalSortColumn;

  AppTableSortOrder get _activeSortOrder =>
      widget.currentSortOrder ?? _internalSortOrder;

  void _toggleExpand(int index) {
    final currentlyExpanded = _activeExpandedRows.contains(index);
    if (widget.expandedRowIndices == null) {
      setState(() {
        if (currentlyExpanded) {
          _internalExpandedRows.remove(index);
        } else {
          _internalExpandedRows.add(index);
        }
      });
    }
    widget.onRowExpandToggle?.call(index, !currentlyExpanded);
  }

  void _handleSortTap(String columnKey) {
    AppTableSortOrder nextOrder;
    if (_activeSortColumn == columnKey) {
      switch (_activeSortOrder) {
        case AppTableSortOrder.none:
          nextOrder = AppTableSortOrder.ascending;
          break;
        case AppTableSortOrder.ascending:
          nextOrder = AppTableSortOrder.descending;
          break;
        case AppTableSortOrder.descending:
          nextOrder = AppTableSortOrder.none;
          break;
      }
    } else {
      nextOrder = AppTableSortOrder.ascending;
    }

    if (widget.currentSortColumn == null) {
      setState(() {
        _internalSortColumn =
            nextOrder == AppTableSortOrder.none ? null : columnKey;
        _internalSortOrder = nextOrder;
      });
    }

    widget.onSort?.call(columnKey, nextOrder);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.borderColor ?? AppColors.borderColor;
    final effectiveHeaderBg =
        widget.headingRowColor ?? const Color(0xFFDCE5F8);
    final effectiveHeaderBorder =
        widget.headingBorderColor ?? AppColors.white;

    final numColumns = widget.columns?.length ??
        widget.columnTitles?.length ??
        (widget.rows?.isNotEmpty == true ? widget.rows![0].length : 0);

    final hasItems = (widget.items != null && widget.items!.isNotEmpty) ||
        (widget.rows != null && widget.rows!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedHeight =
                constraints.maxHeight != double.infinity &&
                    constraints.maxHeight > 0;
            final headerHeight = widget.headingRowHeight ?? 24.h;
            final double? availableBodyHeight = hasBoundedHeight
                ? (constraints.maxHeight - headerHeight).clamp(0.0, double.infinity)
                : null;

            double totalTableWidth = 0;
            final double sepW = widget.enableColumnResizing ? 8.w : 1.0;
            for (int i = 0; i < numColumns; i++) {
              totalTableWidth += (_widths[i] ?? 100.w);
            }
            if (numColumns > 1) {
              totalTableWidth += (numColumns - 1) * sepW;
            }

            Widget bodyContent;
            if (!hasItems && !widget.isLoading) {
              bodyContent = _buildEmptyWidget(numColumns);
            } else if (widget.items != null) {
              bodyContent = _buildTypedRows(effectiveBorderColor, availableBodyHeight, totalTableWidth);
            } else if (widget.rows != null) {
              bodyContent = _buildRawRows(effectiveBorderColor, availableBodyHeight, totalTableWidth);
            } else {
              bodyContent = const SizedBox.shrink();
            }

            final headerRow = RepaintBoundary(
              child: Container(
              height: widget.headingRowHeight ?? 24.h,
              decoration: BoxDecoration(
                color: effectiveHeaderBg,
                border: Border(
                  bottom: BorderSide(color: effectiveHeaderBorder, width: 1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int colIndex = 0; colIndex < numColumns; colIndex++) ...[
                    Builder(
                      builder: (context) {
                        final colDef = widget.columns != null &&
                                colIndex < widget.columns!.length
                            ? widget.columns![colIndex]
                            : null;
                        final title = colDef?.title ??
                            (widget.columnTitles != null &&
                                    colIndex < widget.columnTitles!.length
                                ? widget.columnTitles![colIndex]
                                : 'Col $colIndex');
                        final sortKey = colDef?.key ?? title;
                        final isSortable = colDef?.sortable ?? true;
                        final colWidth = _widths[colIndex] ?? 100.w;

                        final isSorted = _activeSortColumn == sortKey;
                        final currentOrder =
                            isSorted ? _activeSortOrder : AppTableSortOrder.none;

                        return SizedBox(
                          width: colWidth,
                          child: InkWell(
                            onTap: isSortable
                                ? () => _handleSortTap(sortKey)
                                : null,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: colDef?.headerWidget ??
                                        Text(
                                          title,
                                          style: widget.headingTextStyle ??
                                              AppTextStyle.style_11_700(
                                                color: AppColors.black4,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                  ),
                                  if (isSortable) ...[
                                    SizedBox(width: 2.w),
                                    _buildSortIcon(currentOrder),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildColumnSeparator(
                      colIndex,
                      numColumns,
                      (widget.columns != null && colIndex < widget.columns!.length)
                          ? widget.columns![colIndex].minWidth
                          : 40.0,
                      effectiveHeaderBorder,
                      isHeader: true,
                    ),
                  ],
                ],
              ),
            ),
          );

          final horizontalView = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
              children: [
                headerRow,
                bodyContent,
              ],
            ),
          );

          if (hasBoundedHeight) {
            return SizedBox(
              height: constraints.maxHeight,
              child: horizontalView,
            );
          }

          return horizontalView;
          },
        ),
      ),
    );
  }

  // ── Sort Indicator Icon ──────────────────────────────────────────────────

  Widget _buildSortIcon(AppTableSortOrder order) {
    switch (order) {
      case AppTableSortOrder.ascending:
        return Icon(
          Icons.arrow_upward,
          size: 12.r,
          color: AppColors.black4,
        );
      case AppTableSortOrder.descending:
        return Icon(
          Icons.arrow_downward,
          size: 12.r,
          color: AppColors.black4,
        );
      case AppTableSortOrder.none:
        return Icon(
          Icons.unfold_more,
          size: 12.r,
          color: AppColors.black200,
        );
    }
  }

  // ── Single Vertical Column Separator & Resize Handle ─────────────────────

  Widget _buildColumnSeparator(
    int colIndex,
    int totalCols,
    double minWidth,
    Color borderColor, {
    bool isHeader = false,
  }) {
    if (colIndex >= totalCols - 1) {
      return const SizedBox.shrink();
    }

    final double sepWidth = widget.enableColumnResizing ? 8.w : 1.0;

    if (widget.enableColumnResizing && isHeader) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          final currentW = _widths[colIndex] ?? 100.w;
          final newW = (currentW + details.delta.dx).clamp(minWidth, 600.0);
          setState(() {
            _widths[colIndex] = newW;
          });
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: SizedBox(
            width: sepWidth,
            child: Center(
              child: Container(
                width: 1.5,
                color: borderColor,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: sepWidth,
      color: borderColor,
    );
  }

  // Empty State

  Widget _buildEmptyWidget(int numColumns) {
    double totalWidth = 0;
    final double sepW = widget.enableColumnResizing ? 8.w : 1.0;
    for (int i = 0; i < numColumns; i++) {
      totalWidth += (_widths[i] ?? 100.w) + sepW;
    }

    return SizedBox(
      width: totalWidth > 0 ? totalWidth : 300.w,
      child: widget.emptyWidget ??
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            child: Center(
              child: Text(
                widget.emptyText ?? 'No records found.',
                style: AppTextStyle.style_14_400(color: AppColors.grey300),
              ),
            ),
          ),
    );
  }

  // Typed Rows

  Widget _buildTypedRows(
    Color borderColor,
    double? availableHeight,
    double totalWidth,
  ) {
    final items = widget.items!;

    if (availableHeight == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          items.length,
          (rowIndex) => _buildTypedRow(items[rowIndex], rowIndex, borderColor),
        ),
      );
    }

    final rowHeight = widget.headingRowHeight ?? 24.h;
    final hasExpandedRows = _activeExpandedRows.isNotEmpty;

    return SizedBox(
      width: totalWidth,
      height: availableHeight,
      child: ListView.builder(
        itemCount: items.length,
        itemExtent: hasExpandedRows ? null : rowHeight,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, rowIndex) {
          return _buildTypedRow(items[rowIndex], rowIndex, borderColor);
        },
      ),
    );
  }

  Widget _buildTypedRow(T item, int rowIndex, Color borderColor) {
    final cols = widget.columns ?? [];
    final isExpanded = _activeExpandedRows.contains(rowIndex);
    final isEven = rowIndex % 2 == 0;
    final customDecoration = widget.rowDecorationBuilder?.call(item, rowIndex);
    final customBg = widget.rowColorBuilder?.call(item, rowIndex);
    final rowBg = customBg ??
        (widget.showStripedRows && !isEven
            ? AppColors.boxColor2
            : AppColors.white);

    final defaultDecoration = BoxDecoration(
      color: rowBg,
      border: Border(
        bottom: BorderSide(color: borderColor),
      ),
    );

    final activeDecoration = customDecoration ?? defaultDecoration;
    final effectiveBgColor = activeDecoration.color ?? rowBg;

    final rowFlex = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int colIndex = 0; colIndex < cols.length; colIndex++) ...[
          Builder(
            builder: (context) {
              final col = cols[colIndex];
              final colWidth = _widths[colIndex] ?? col.width ?? 100.w;
              final cellBgColor = col.cellColorGetter?.call(item);

              Widget cellContent;
              if (col.cellBuilder != null) {
                cellContent = col.cellBuilder!(
                  context,
                  item,
                  rowIndex,
                  isExpanded,
                );
              } else {
                final textValue = col.valueGetter != null
                    ? col.valueGetter!(item)
                    : (item.toString());
                cellContent = Text(
                  textValue,
                  style: widget.dataTextStyle ??
                      AppTextStyle.style_11_500(color: AppColors.black),
                  maxLines: isExpanded ? null : 1,
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                );
              }

              return Container(
                width: colWidth,
                color: cellBgColor,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.cellHorizontalPadding ?? 6.w,
                  vertical: widget.cellVerticalPadding ?? 2.h,
                ),
                alignment: col.alignment,
                child: cellContent,
              );
            },
          ),
          _buildColumnSeparator(
            colIndex,
            cols.length,
            cols[colIndex].minWidth,
            borderColor,
            isHeader: false,
          ),
        ],
      ],
    );

    final Widget sizedRowFlex = isExpanded
        ? IntrinsicHeight(child: rowFlex)
        : SizedBox(
            height: widget.headingRowHeight ?? 24.h,
            child: rowFlex,
          );

    final rowContent = Container(
      color: effectiveBgColor,
      child: InkWell(
        onTap: () {
          widget.onRowTap?.call(item, rowIndex);
          _toggleExpand(rowIndex);
        },
        child: sizedRowFlex,
      ),
    );

    return RepaintBoundary(
      child: Stack(
        children: [
          rowContent,
          if (activeDecoration.border != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: activeDecoration.border,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Raw Matrix Rows (List<List<dynamic>>) ───────────────────────────────

  Widget _buildRawRows(
    Color borderColor,
    double? availableHeight,
    double totalWidth,
  ) {
    final rawRows = widget.rows!;

    if (availableHeight == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          rawRows.length,
          (rowIndex) => _buildRawRow(rawRows[rowIndex], rowIndex, borderColor),
        ),
      );
    }

    final rowHeight = widget.headingRowHeight ?? 24.h;
    final hasExpandedRows = _activeExpandedRows.isNotEmpty;

    return SizedBox(
      width: totalWidth,
      height: availableHeight,
      child: ListView.builder(
        itemCount: rawRows.length,
        itemExtent: hasExpandedRows ? null : rowHeight,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, rowIndex) {
          return _buildRawRow(rawRows[rowIndex], rowIndex, borderColor);
        },
      ),
    );
  }

  Widget _buildRawRow(List<dynamic> row, int rowIndex, Color borderColor) {
    final numCols = row.length;
    final isExpanded = _activeExpandedRows.contains(rowIndex);
    final isEven = rowIndex % 2 == 0;
    final rowBg = widget.showStripedRows && !isEven
        ? AppColors.boxColor2
        : AppColors.white;

    final rowFlex = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int colIndex = 0; colIndex < numCols; colIndex++) ...[
          Builder(
            builder: (context) {
              final cellVal = colIndex < row.length ? row[colIndex] : '';
              final colWidth = _widths[colIndex] ?? 100.w;

              Widget cellContent;
              if (cellVal is Widget) {
                cellContent = cellVal;
              } else {
                cellContent = Text(
                  cellVal.toString(),
                  style: widget.dataTextStyle ??
                      AppTextStyle.style_11_500(color: AppColors.black),
                  maxLines: isExpanded ? null : 1,
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                );
              }

              return Container(
                width: colWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.cellHorizontalPadding ?? 6.w,
                  vertical: widget.cellVerticalPadding ?? 2.h,
                ),
                child: cellContent,
              );
            },
          ),
          _buildColumnSeparator(
            colIndex,
            numCols,
            40.0,
            borderColor,
            isHeader: false,
          ),
        ],
      ],
    );

    final Widget sizedRowFlex = isExpanded
        ? IntrinsicHeight(child: rowFlex)
        : SizedBox(
            height: widget.headingRowHeight ?? 24.h,
            child: rowFlex,
          );

    return RepaintBoundary(
      child: Stack(
        children: [
          Container(
            color: rowBg,
            child: InkWell(
              onTap: () => _toggleExpand(rowIndex),
              child: sizedRowFlex,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
