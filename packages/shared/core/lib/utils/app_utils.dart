import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:core/utils/app_common_toast_message.dart';

class AppUtils {
  AppUtils._(); // Private constructor

  /// Sanitizes URLs by removing quotes and ensuring protocol
  static String? sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    String cleanUrl = url.replaceAll('"', '').trim();
    // Filter out invalid placeholders
    if (cleanUrl.contains('s3-url')) return null;

    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }
    return Uri.encodeFull(cleanUrl);
  }

  /// Launches the Phone Dialer
  static Future<void> launchDialer(BuildContext context, String mobile) async {
    final Uri launchUri = Uri(scheme: 'tel', path: mobile);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
        AppCommonToastMessage.show(message: 'Could not launch dialer.', type: ToastType.error);
      }
    }

    /// Launches an external URL (Browser/PDF Viewer)
    static Future<void> launchURL(BuildContext context, String urlString,
        {LaunchMode mode = LaunchMode.externalApplication}) async {
      String? clean = sanitizeUrl(urlString);
      if (clean != null) {
        final Uri uri = Uri.parse(clean);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: mode);
        } else {
          AppCommonToastMessage.show(message: 'Could not open link.', type: ToastType.error);
        }
      } else {
        AppCommonToastMessage.show(message: 'Invalid URL.', type: ToastType.error);
      }
    }
}










