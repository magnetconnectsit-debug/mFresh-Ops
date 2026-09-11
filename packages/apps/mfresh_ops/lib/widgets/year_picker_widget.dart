import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';

class YearPickerMenuContent extends StatefulWidget {
  final int? selectedYear;
  final Function(int) onYearSelected;

  const YearPickerMenuContent({
    super.key,
    required this.selectedYear,
    required this.onYearSelected,
  });

  @override
  State<YearPickerMenuContent> createState() => _YearPickerMenuContentState();
}

class _YearPickerMenuContentState extends State<YearPickerMenuContent> {
  late int selectedYear;
  int startYearWindow = 2021;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  final List<int> allYears = List.generate(30, (index) => 2010 + index);

  @override
  void initState() {
    super.initState();
    selectedYear = widget.selectedYear ?? DateTime.now().year;
    startYearWindow = (selectedYear ~/ 12) * 12;
    if (startYearWindow < 2010) startYearWindow = 2010;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<int> get displayedYears {
    if (searchQuery.isNotEmpty) {
      return allYears
          .where((y) => y.toString().contains(searchQuery.trim()))
          .toList();
    }
    return List.generate(12, (index) => startYearWindow + index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      width: 240.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Navigation Bar (Prev, Header Year, Next)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (startYearWindow > 2000) {
                      startYearWindow -= 12;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 18.r,
                    color: AppColors.black,
                  ),
                ),
              ),
              Text(
                selectedYear.toString(),
                style: AppTextStyle.style_14_700(color: AppColors.black),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    startYearWindow += 12;
                  });
                },
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18.r,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Search Bar
          SizedBox(
            height: 32.h,
            child: TextField(
              controller: searchController,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              style: AppTextStyle.style_12_400(color: AppColors.black),
              decoration: InputDecoration(
                hintText: 'Search year...',
                hintStyle: AppTextStyle.style_12_400(color: Colors.grey.shade400),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: const BorderSide(color: Color(0xFFF15A24)),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Grid of Years
          displayedYears.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text('No year found',
                      style: AppTextStyle.style_12_400(color: AppColors.grey500)),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.0,
                    crossAxisSpacing: 6.w,
                    mainAxisSpacing: 6.h,
                  ),
                  itemCount: displayedYears.length,
                  itemBuilder: (context, index) {
                    final year = displayedYears[index];
                    final isSelected = year == selectedYear;

                    return InkWell(
                      onTap: () {
                        widget.onYearSelected(year);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE85324)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE85324)
                                : Colors.grey.shade300,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$year',
                          style: AppTextStyle.style_12_500(
                            color: isSelected ? Colors.white : AppColors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
