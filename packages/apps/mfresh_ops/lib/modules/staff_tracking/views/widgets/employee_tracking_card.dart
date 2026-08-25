import 'package:flutter/material.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/widgets/app_image_view.dart';

class EmployeeTrackingCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onTap;
  final bool hideBottomRow;
  final bool canViewMap;

  const EmployeeTrackingCard({
    super.key,
    required this.employee,
    required this.onTap,
    this.hideBottomRow = false,
    this.canViewMap = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = employee['name'] ?? 'Unknown';
    final mobile = employee['mobile'] ?? '';
    final status = employee['current_status']?.toString().toLowerCase();
    final lastSeen = employee['last_seen'];
    final liveStatus = employee['live_status'] as Map<String, dynamic>?;
    final battery = employee['battery'] ?? liveStatus?['battery'];
    final speed = employee['speed'] ?? liveStatus?['speed'];

    final bool isOnDuty =
        employee['is_on_duty'] == 1 ||
        employee['is_on_duty'] == true ||
        employee['is_on_duty'] == '1';

    Color statusColor = AppColors.red;
    String statusText = 'Offline';

    if (status == 'moving') {
      statusColor = AppColors.green;
      statusText = 'Moving';
    } else if (status == 'stopped') {
      statusColor = AppColors.orange;
      statusText = 'Stopped';
    } else if (status == 'offline') {
      statusColor = AppColors.red;
      statusText = 'Offline';
    } else if (status == 'duty on' ||
        status == 'on duty' ||
        status == 'onduty' ||
        isOnDuty) {
      statusColor = AppColors.blue500;
      statusText = 'On Duty';
    } else {
      statusColor = AppColors.grey500;
      statusText = 'Off Duty';
    }

    String formattedLastSeen = AppDateUtils.formatToRelativeTimeOrDateTimeAmPm(
      lastSeen?.toString(),
    );

    final imageUrl = employee['image_url']?.toString();
    final hasImage =
        imageUrl != null && !imageUrl.endsWith('/NA') && imageUrl.isNotEmpty;

    final bool isStale10Min = AppDateUtils.isOlderThanMinutes(
      lastSeen?.toString(),
      10,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: isStale10Min
            ? Border.all(color: AppColors.orange, width: 2.0)
            : Border.all(color: AppColors.grey200, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey500.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section (Profile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: !hasImage
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.blue500,
                                        AppColors.blue500.withValues(
                                          alpha: 0.7,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: hasImage ? AppColors.grey200 : null,
                              boxShadow: !hasImage
                                  ? [
                                      BoxShadow(
                                        color: AppColors.blue500.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: hasImage
                                ? AppImageView(
                                    imageUrl: imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      name.toString().isNotEmpty
                                          ? name
                                                .toString()
                                                .substring(0, 1)
                                                .toUpperCase()
                                          : 'U',
                                      style: AppTextStyle.style_16_600(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: statusColor, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (mobile.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_iphone_rounded,
                                  size: 12,
                                  color: AppColors.grey500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mobile,
                                  style: AppTextStyle.style_10_500(
                                    color: AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color:
                                          (employee['is_on_duty'] == 1 ||
                                              employee['is_on_duty'] == true)
                                          ? AppColors.green.withValues(
                                              alpha: 0.5,
                                            )
                                          : AppColors.red.withValues(
                                              alpha: 0.5,
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    (employee['is_on_duty'] == 1 ||
                                            employee['is_on_duty'] == true)
                                        ? 'On Duty'
                                        : 'Off Duty',
                                    style:
                                        AppTextStyle.style_10_600(
                                          color:
                                              (employee['is_on_duty'] == 1 ||
                                                  employee['is_on_duty'] ==
                                                      true)
                                              ? AppColors.green
                                              : AppColors.red,
                                        ).copyWith(
                                          decoration:
                                              (employee['is_on_duty'] == 1 ||
                                                      employee['is_on_duty'] ==
                                                          true) &&
                                                  isStale10Min
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor: AppColors.red,
                                          decorationThickness: 4.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          if (hideBottomRow) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (isStale10Min
                                            ? AppColors.orange
                                            : AppColors.green)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: isStale10Min
                                        ? AppColors.orange
                                        : AppColors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Last Seen: $formattedLastSeen',
                                    style: AppTextStyle.style_10_600(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Call Button
                    if (mobile.isNotEmpty)
                      InkWell(
                        onTap: () async {
                          final Uri url = Uri(scheme: 'tel', path: mobile);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.green.withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.green.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.call_rounded,
                            size: 16,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                  ],
                ),

                if (canViewMap && !hideBottomRow) ...[
                  const SizedBox(height: 6),
                  Divider(color: AppColors.grey50, height: 1, thickness: 1),
                  const SizedBox(height: 6),

                  // Bottom Section (Stats)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: AppTextStyle.style_10_600(
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),

                      Container(width: 1, height: 12, color: AppColors.grey300),

                      // Speed
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 12,
                            color: AppColors.blue500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            speed != null
                                ? '${double.tryParse(speed.toString())?.toStringAsFixed(0) ?? 0} km/h'
                                : 'N/A',
                            style: AppTextStyle.style_10_500(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),

                      Container(width: 1, height: 12, color: AppColors.grey300),

                      // Battery
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.battery_std_rounded,
                            size: 12,
                            color:
                                (battery != null &&
                                    int.tryParse(battery.toString()) != null &&
                                    int.parse(battery.toString()) <= 20)
                                ? AppColors.red
                                : AppColors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            battery != null ? '$battery%' : 'N/A',
                            style: AppTextStyle.style_10_500(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),

                      Container(width: 1, height: 12, color: AppColors.grey300),

                      // Last Seen
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedLastSeen,
                            style: AppTextStyle.style_10_500(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
