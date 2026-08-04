import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_brands_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_brand_dialog.dart';

class MContactBrandsTable extends StatefulWidget {
  final MContactBrandsController controller;

  const MContactBrandsTable({super.key, required this.controller});

  @override
  State<MContactBrandsTable> createState() => _MContactBrandsTableState();
}

class _MContactBrandsTableState extends State<MContactBrandsTable> {
  final Set<int> _expandedRows = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(60.w),
      1: const FlexColumnWidth(),
      2: FixedColumnWidth(65.w),
    };

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.grey.shade300),
            ),
            columnWidths: columnWidths,
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFC5D5F0)),
                children: [
                  _HeaderCell(text: 'Sl No'),
                  _HeaderCell(text: 'Name'),
                  _HeaderCell(text: 'Action'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.controller.fetchBrands(),
            child: Obx(() {
              final isLoadingInitial =
                  widget.controller.isLoading.value &&
                  widget.controller.brands.isEmpty;
              final showEmpty =
                  !isLoadingInitial && widget.controller.brands.isEmpty;

              if (showEmpty) {
                return Center(
                  child: Text(
                    'No brands found.',
                    style: AppTextStyle.style_14_400(color: AppColors.grey600),
                  ),
                );
              }

              final listCount = isLoadingInitial
                  ? 10
                  : widget.controller.brands.length;

              return Skeletonizer(
                enabled: isLoadingInitial,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  interactive: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: listCount,
                    itemBuilder: (context, index) {
                    final brand = isLoadingInitial
                        ? {'id': 0, 'name': 'Loading Name...'}
                        : widget.controller.brands[index];
                    final isExpanded = _expandedRows.contains(index);
                    void toggleExpanded() {
                      setState(() {
                        if (isExpanded) {
                          _expandedRows.remove(index);
                        } else {
                          _expandedRows.add(index);
                        }
                      });
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                          left: BorderSide(color: AppColors.borderColor),
                          right: BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: TableBorder.symmetric(
                          inside: BorderSide(color: Colors.grey.shade300),
                        ),
                        columnWidths: columnWidths,
                        children: [
                          TableRow(
                            children: [
                              _DataCell(
                                text: '${index + 1}',
                                isExpanded: isExpanded,
                                onTap: toggleExpanded,
                              ),
                              _DataCell(
                                text: brand['name']?.toString() ?? '',
                                isExpanded: isExpanded,
                                onTap: toggleExpanded,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await showMContactBrandDialog(
                                          context,
                                          widget.controller,
                                          brand: brand,
                                        );
                                        widget.controller.fetchBrands();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(Icons.edit, size: 16),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    InkWell(
                                      onTap: () {
                                        Get.dialog(
                                          AlertDialog(
                                            backgroundColor: Colors.white,
                                            surfaceTintColor:
                                                Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            title: Row(
                                              children: [
                                                const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red,
                                                  size: 28,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'Delete Brand',
                                                  style:
                                                      AppTextStyle.style_16_700(
                                                        color: AppColors.black,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete this brand?',
                                              style: AppTextStyle.style_14_400(
                                                color: AppColors.grey700,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style:
                                                      AppTextStyle.style_14_500(
                                                        color:
                                                            AppColors.grey600,
                                                      ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  widget.controller.deleteBrand(
                                                    brand['id'] as int,
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Delete',
                                                  style:
                                                      AppTextStyle.style_14_500(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          size: 16,)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.grey900),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const _DataCell({
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
