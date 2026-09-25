import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/widgets/custom_app_loader.dart';

class AppImageView extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color backgroundColor;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor = AppColors.white,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: (imageUrl == null || imageUrl!.isEmpty || imageUrl == "NA")
            ? _buildErrorWidget()
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                width: width,
                height: height,
                fit: fit,
                memCacheWidth: memCacheWidth,
                memCacheHeight: memCacheHeight,
                placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
                errorWidget: (context, url, error) =>
                    errorWidget ?? _buildErrorWidget(),
              ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.grey50,
            AppColors.white,
            AppColors.grey50,
          ],
        ),
      ),
      child: const Center(
        child: CustomAppLoader(size: 24),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.grey50, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
            AppColors.white,
          ],
        ),
      ),
      child: Image.asset(
        AppImages.appLogo,
        fit: BoxFit.contain,
      ),
    );
  }
}










