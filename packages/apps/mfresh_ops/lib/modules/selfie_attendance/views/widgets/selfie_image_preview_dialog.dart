// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/utils/geocoding_service.dart';
import 'package:url_launcher/url_launcher.dart';
// endregion

// region View
class SelfieImagePreviewDialog extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final String? timestamp;
  final String? userName;
  final String? latitude;
  final String? longitude;
  final String? mapUrl;

  const SelfieImagePreviewDialog({
    super.key,
    required this.imageUrl,
    required this.title,
    this.timestamp,
    this.userName,
    this.latitude,
    this.longitude,
    this.mapUrl,
  });

  // region Dialogs & Action Handlers
  static Future<void> show({
    required BuildContext context,
    required String? imageUrl,
    required String title,
    String? timestamp,
    String? userName,
    String? latitude,
    String? longitude,
    String? mapUrl,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.65),
      builder: (ctx) => SelfieImagePreviewDialog(
        imageUrl: imageUrl,
        title: title,
        timestamp: timestamp,
        userName: userName,
        latitude: latitude,
        longitude: longitude,
        mapUrl: mapUrl,
      ),
    );
  }
  // endregion

  @override
  State<SelfieImagePreviewDialog> createState() =>
      _SelfieImagePreviewDialogState();
}

class _SelfieImagePreviewDialogState extends State<SelfieImagePreviewDialog> {
  String? _resolvedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  Future<void> _resolveLocation() async {
    String? latStr = widget.latitude;
    String? lngStr = widget.longitude;

    // Extract from mapUrl if direct lat/lng are empty
    if ((latStr == null || latStr.isEmpty || lngStr == null || lngStr.isEmpty) &&
        widget.mapUrl != null &&
        widget.mapUrl!.isNotEmpty) {
      final match = RegExp(r'[?&]q=([-+]?\d*\.?\d+),([-+]?\d*\.?\d+)')
          .firstMatch(widget.mapUrl!);
      if (match != null) {
        latStr = match.group(1);
        lngStr = match.group(2);
      }
    }

    if (latStr == null || latStr.trim().isEmpty || lngStr == null || lngStr.trim().isEmpty) {
      return;
    }

    final lat = double.tryParse(latStr.trim());
    final lng = double.tryParse(lngStr.trim());
    if (lat == null || lng == null) return;

    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final address =
          await GeocodingService.instance.reverseGeocodeGoogleMaps(lat, lng) ??
              await GeocodingService.instance.resolve('$lat,$lng');
      if (mounted) {
        setState(() {
          _resolvedAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _openExternalMap() async {
    final mapUrl = widget.mapUrl;
    final lat = widget.latitude;
    final lng = widget.longitude;

    Uri? uri;
    if (mapUrl != null && mapUrl.isNotEmpty) {
      uri = Uri.parse(mapUrl);
    } else if (lat != null && lat.isNotEmpty && lng != null && lng.isNotEmpty) {
      uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    }

    if (uri != null) {
      try {
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(uri);
        }
      } catch (_) {}
    }
  }

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 620.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Flexible(child: _buildImageContent(context)),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.boxColor2,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.face_retouching_natural,
                  size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                widget.title,
                style: AppTextStyle.style_14_700(color: AppColors.black),
              ),
            ],
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.close, size: 20.sp, color: AppColors.grey600),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (widget.imageUrl == null || widget.imageUrl!.trim().isEmpty) {
      return Container(
        height: 240.h,
        alignment: Alignment.center,
        color: AppColors.boxColor2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 48.sp, color: AppColors.grey400),
            SizedBox(height: 8.h),
            Text(
              'No selfie image captured',
              style: AppTextStyle.style_12_400(color: AppColors.grey500),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.black,
      child: InteractiveViewer(
        maxScale: 4.0,
        minScale: 0.8,
        child: Center(
          child: AppImageView(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            placeholder: Center(
              child: Padding(
                padding: EdgeInsets.all(40.r),
                child: const CustomAppLoader(size: 36),
              ),
            ),
            errorWidget: Container(
              height: 240.h,
              alignment: Alignment.center,
              child: Text(
                'Failed to load image',
                style: AppTextStyle.style_12_400(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final hasUser = widget.userName != null && widget.userName!.isNotEmpty;
    final hasTime = widget.timestamp != null && widget.timestamp!.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.boxColor2,
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUser || hasTime)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasUser)
                  Expanded(
                    child: Text(
                      widget.userName!,
                      style: AppTextStyle.style_13_600(color: AppColors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (hasTime)
                  Text(
                    widget.timestamp!,
                    style: AppTextStyle.style_11_400(color: AppColors.grey600),
                  ),
              ],
            ),
          if (_isLoadingAddress) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                SizedBox(
                  width: 12.r,
                  height: 12.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Resolving location...',
                  style: AppTextStyle.style_11_400(color: AppColors.grey500),
                ),
              ],
            ),
          ] else if (_resolvedAddress != null &&
              _resolvedAddress!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            InkWell(
              onTap: _openExternalMap,
              borderRadius: BorderRadius.circular(4.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Icon(
                        Icons.location_on,
                        size: 13.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        _resolvedAddress!,
                        style: AppTextStyle.style_11_500(
                          color: AppColors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.open_in_new,
                      size: 11.sp,
                      color: AppColors.grey400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  // endregion
}
// endregion
