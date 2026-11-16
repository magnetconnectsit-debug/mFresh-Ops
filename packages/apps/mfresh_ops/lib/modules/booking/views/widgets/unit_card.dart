// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region UnitCard Widget
class UnitCard extends StatelessWidget {
  // region Properties
  final String unitName;
  final String description;
  final String image;
  final String date;
  final VoidCallback onTap;
  // endregion

  // region Constructor
  const UnitCard({
    super.key,
    required this.unitName,
    required this.onTap,
    required this.description,
    required this.image,
    required this.date,
  });
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail Image Section
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.r),
                  topRight: Radius.circular(15.r),
                ),
                child: AppImageView(
                  imageUrl: image.isNotEmpty ? image : null,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: Image.asset(
                    AppImages.unitCard,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  errorWidget: Image.asset(
                    AppImages.unitCard,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            // Details Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Unit No.: ",
                              style: AppTextStyle.style_16_700(
                                color: AppColors.grey400,
                              ),
                            ),
                            TextSpan(
                              text: unitName,
                              style: AppTextStyle.style_16_700(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style_12_500(
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (date.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          date,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.style_12_600(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // endregion
}
// endregion
