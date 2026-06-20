import 'package:flutter/material.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeTrackingCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onTap;

  const EmployeeTrackingCard({
    super.key,
    required this.employee,
    required this.onTap,
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

    Color statusColor = Colors.red;
    Color statusBgColor = Colors.red.withValues(alpha: 0.1);
    String statusText = 'Offline';

    if (status == 'moving') {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withValues(alpha: 0.1);
      statusText = 'Moving';
    } else if (status == 'stopped') {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withValues(alpha: 0.1);
      statusText = 'Stopped';
    }

    String formattedLastSeen = AppDateUtils.formatToDateTimeAmPm(lastSeen?.toString());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section (Profile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.blue500, AppColors.blue500.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue500.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          name.toString().isNotEmpty ? name.toString().substring(0, 1).toUpperCase() : 'U',
                          style: AppTextStyle.style_16_700(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyle.style_14_600(color: AppColors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (mobile.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.phone_iphone_rounded, size: 12, color: AppColors.grey500),
                                const SizedBox(width: 4),
                                Text(
                                  mobile,
                                  style: AppTextStyle.style_10_500(color: AppColors.grey600),
                                ),
                              ],
                            ),
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
                            color: Colors.green.withValues(alpha: 0.08),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.call_rounded, size: 16, color: Colors.green),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                Divider(color: Colors.grey[100], height: 1, thickness: 1),
                const SizedBox(height: 10),
                
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
                          style: AppTextStyle.style_10_600(color: statusColor),
                        ),
                      ],
                    ),
                    
                    Container(width: 1, height: 12, color: Colors.grey[300]),
                    
                    // Speed
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed_rounded, size: 12, color: AppColors.blue500),
                        const SizedBox(width: 4),
                        Text(
                          speed != null ? '${double.tryParse(speed.toString())?.toStringAsFixed(0) ?? 0} km/h' : 'N/A',
                          style: AppTextStyle.style_10_500(color: AppColors.grey600),
                        ),
                      ],
                    ),
                    
                    Container(width: 1, height: 12, color: Colors.grey[300]),
                    
                    // Battery
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.battery_std_rounded, 
                          size: 12, 
                          color: (battery != null && int.tryParse(battery.toString()) != null && int.parse(battery.toString()) <= 20) ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          battery != null ? '$battery%' : 'N/A',
                          style: AppTextStyle.style_10_500(color: AppColors.grey600),
                        ),
                      ],
                    ),
                    
                    Container(width: 1, height: 12, color: Colors.grey[300]),
                    
                    // Last Seen
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(
                          formattedLastSeen,
                          style: AppTextStyle.style_10_500(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
