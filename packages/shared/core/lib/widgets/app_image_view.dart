// region Imports
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
// endregion

class AppImageView extends StatelessWidget {
  // region Properties
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
  final bool enableFullScreenOnTap;
  final String? title;
  final VoidCallback? onTap;
  // endregion

  // region Constructor
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
    this.enableFullScreenOnTap = false,
    this.title,
    this.onTap,
  });
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final String trimmed = (imageUrl ?? '').trim();
    final bool isEmpty =
        trimmed.isEmpty || trimmed == "NA" || trimmed == "null";
    final bool isAsset = trimmed.startsWith('assets/') ||
        (!trimmed.startsWith('http://') && !trimmed.startsWith('https://'));

    final imageWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: isEmpty
            ? _buildErrorWidget()
            : isAsset
                ? Image.asset(
                    trimmed,
                    width: width,
                    height: height,
                    fit: fit,
                    errorBuilder: (context, error, stackTrace) =>
                        errorWidget ?? _buildErrorWidget(),
                  )
                : CachedNetworkImage(
                    imageUrl: trimmed,
                    width: width,
                    height: height,
                    fit: fit,
                    memCacheWidth: memCacheWidth,
                    memCacheHeight: memCacheHeight,
                    placeholder: (context, url) =>
                        placeholder ?? _buildPlaceholder(),
                    errorWidget: (context, url, error) =>
                        errorWidget ?? _buildErrorWidget(),
                  ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    if (enableFullScreenOnTap && !isEmpty) {
      return InkWell(
        onTap: () => showFullScreen(
          context,
          imageUrl: trimmed,
          title: title,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
  // endregion

  // region Placeholder & Error Builders
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
  // endregion

  // region Full-Screen Preview
  /// Shows a full-screen image preview dialog with pinch-to-zoom and dark backdrop.
  static Future<void> showFullScreen(
    BuildContext context, {
    String? imageUrl,
    File? imageFile,
    String? title,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.85),
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: imageFile != null
                      ? Image.file(
                          imageFile,
                          fit: BoxFit.contain,
                        )
                      : AppImageView(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          backgroundColor: Colors.transparent,
                          errorWidget: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48.sp,
                              color: AppColors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                ),
              ),
              if (title != null && title.isNotEmpty)
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  right: 60.w,
                  child: Text(
                    title,
                    style: AppTextStyle.style_16_600(color: AppColors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Positioned(
                top: 10.h,
                right: 14.w,
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a full-screen interactive gallery viewer with horizontal paging, pinch-to-zoom, counter, and dark backdrop.
  static Future<void> showGalleryViewer(
    BuildContext context, {
    required List<AppGalleryImageSource> images,
    int initialIndex = 0,
    String? title,
    void Function(int index)? onDelete,
  }) {
    if (images.isEmpty) return Future.value();
    return showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.90),
      builder: (ctx) => _AppFullScreenGalleryDialog(
        images: images,
        initialIndex: initialIndex.clamp(0, images.length - 1),
        title: title,
        onDelete: onDelete,
      ),
    );
  }
  // endregion
}

// region Gallery Image Source & Full Screen Dialog
class AppGalleryImageSource {
  final String? url;
  final File? file;
  final String? title;

  const AppGalleryImageSource({
    this.url,
    this.file,
    this.title,
  });
}

class _AppFullScreenGalleryDialog extends StatefulWidget {
  final List<AppGalleryImageSource> images;
  final int initialIndex;
  final String? title;
  final void Function(int index)? onDelete;

  const _AppFullScreenGalleryDialog({
    required this.images,
    required this.initialIndex,
    this.title,
    this.onDelete,
  });

  @override
  State<_AppFullScreenGalleryDialog> createState() =>
      _AppFullScreenGalleryDialogState();
}

class _AppFullScreenGalleryDialogState
    extends State<_AppFullScreenGalleryDialog> {
  late final PageController _pageController;
  late int _currentIndex;
  late List<AppGalleryImageSource> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.images);
    _currentIndex = widget.initialIndex.clamp(0, (_items.length - 1).clamp(0, 9999));
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleDelete() {
    final deletedIdx = _currentIndex;
    widget.onDelete?.call(deletedIdx);
    setState(() {
      _items.removeAt(deletedIdx);
      if (_items.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      if (_currentIndex >= _items.length) {
        _currentIndex = _items.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    final currentItem = _items[_currentIndex];
    final displayTitle = currentItem.title ?? widget.title ?? 'Image';
    final counterText = _items.length > 1
        ? '$displayTitle (${_currentIndex + 1}/${_items.length})'
        : displayTitle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable PageView
            PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (idx) {
                setState(() => _currentIndex = idx);
              },
              itemBuilder: (context, idx) {
                final item = _items[idx];
                return Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: item.file != null
                        ? Image.file(
                            item.file!,
                            fit: BoxFit.contain,
                          )
                        : AppImageView(
                            imageUrl: item.url,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            backgroundColor: Colors.transparent,
                            errorWidget: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48.sp,
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),

            // Top Bar
            Positioned(
              top: 10.h,
              left: 14.w,
              right: 14.w,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      counterText,
                      style: AppTextStyle.style_15_600(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.onDelete != null) ...[
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppColors.white,
                          size: 18.sp,
                        ),
                      ),
                      onPressed: _handleDelete,
                    ),
                    SizedBox(width: 6.w),
                  ],
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 18.sp,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Left Navigation Arrow
            if (_items.length > 1 && _currentIndex > 0)
              Positioned(
                left: 10.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: AppColors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ),

            // Right Navigation Arrow
            if (_items.length > 1 && _currentIndex < _items.length - 1)
              Positioned(
                right: 10.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Page Indicator Pill
            if (_items.length > 1)
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${_items.length}',
                      style: AppTextStyle.style_12_500(color: AppColors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// endregion
