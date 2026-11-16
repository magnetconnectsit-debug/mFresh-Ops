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

  /// Parses an error/exception and returns a clean, user-friendly message.
  static String parseError(dynamic e) {
    if (e == null) return 'Something went wrong. Please try again.';
    
    final String errStr = e.toString();
    if (errStr.contains('DioException') || errStr.contains('DioError')) {
      try {
        final dynamic dioErr = e;
        final response = dioErr.response;
        
        if (response != null && response.data != null) {
          final data = response.data;
          if (data is Map) {
            if (data.containsKey('message') && data['message'] != null) {
              final String msg = data['message'].toString();
              if (msg.isNotEmpty && 
                  !msg.toLowerCase().contains('sqlstate') && 
                  !msg.toLowerCase().contains('database') && 
                  !msg.toLowerCase().contains('exception')) {
                return msg;
              }
            }
          }
        }
        
        final typeStr = dioErr.type.toString();
        if (typeStr.contains('connectionTimeout') || 
            typeStr.contains('sendTimeout') || 
            typeStr.contains('receiveTimeout')) {
          return 'Connection timed out. Please try again.';
        } else if (typeStr.contains('connectionError')) {
          return 'Cannot connect to server. Please check your internet connection.';
        } else if (typeStr.contains('badResponse')) {
          final int? statusCode = response?.statusCode;
          if (statusCode == 404) {
            return 'Requested resource not found.';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
          return 'Something went wrong. Please try again.';
        }
        return 'A network error occurred. Please try again.';
      } catch (_) {
        return 'A network error occurred. Please try again.';
      }
    }
    
    if (errStr.contains('Exception:')) {
      return errStr.replaceAll('Exception:', '').trim();
    }
    
    return 'Something went wrong. Please try again.';
  }
}










