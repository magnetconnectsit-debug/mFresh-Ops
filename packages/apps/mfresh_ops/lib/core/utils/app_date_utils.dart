class AppDateUtils {
  static String formatToOrdinalDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return rawDate;
      
      final day = parsed.day;
      final suffix = _getDaySuffix(day);
      final monthName = _getMonthName(parsed.month);
      final year = parsed.year;
      
      return '$day$suffix $monthName $year';
    } catch (_) {
      return rawDate;
    }
  }

  static String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  static String formatToApiDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return rawDate;
      
      final day = parsed.day.toString().padLeft(2, '0');
      final monthName = _getShortMonthName(parsed.month);
      final year = parsed.year;
      
      return '$day-$monthName-$year';
    } catch (_) {
      return rawDate;
    }
  }

  static String _getShortMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  static String formatToDateTimeAmPm(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Never';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return rawDate;

      final local = parsed.toLocal();
      final day = local.day.toString().padLeft(2, '0');
      final monthName = _getShortMonthName(local.month);
      
      int hour = local.hour;
      final minute = local.minute.toString().padLeft(2, '0');
      final amPm = hour >= 12 ? 'PM' : 'AM';
      
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      
      final hourStr = hour.toString().padLeft(2, '0');

      return '$hourStr:$minute $amPm, $day $monthName';
    } catch (_) {
      return rawDate;
    }
  }

  static String formatToTimeAmPm(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Never';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return rawDate;

      final local = parsed.toLocal();
      
      int hour = local.hour;
      final minute = local.minute.toString().padLeft(2, '0');
      final amPm = hour >= 12 ? 'PM' : 'AM';
      
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      
      final hourStr = hour.toString().padLeft(2, '0');

      return '$hourStr:$minute $amPm';
    } catch (_) {
      return rawDate;
    }
  }

  static String formatToRelativeTimeOrDateTimeAmPm(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Never';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return rawDate;

      final local = parsed.toLocal();
      final now = DateTime.now();
      final difference = now.difference(local);

      // If less than 24 hours ago and on the same or previous day within 24h
      if (difference.inHours < 24 && difference.inDays == 0) {
        if (difference.isNegative || difference.inSeconds < 5) {
          return 'Just now';
        } else if (difference.inSeconds < 60) {
          final secs = difference.inSeconds;
          return '$secs sec${secs > 1 ? 's' : ''} ago';
        } else if (difference.inMinutes < 60) {
          final mins = difference.inMinutes;
          return '$mins min${mins > 1 ? 's' : ''} ago';
        } else {
          final hours = difference.inHours;
          return '$hours hr${hours > 1 ? 's' : ''} ago';
        }
      }

      return formatToDateTimeAmPm(rawDate);
    } catch (_) {
      return rawDate;
    }
  }

  static bool isOlderThanMinutes(String? rawDate, int minutes) {
    if (rawDate == null || rawDate.isEmpty) return true;
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return true;
      
      final local = parsed.toLocal();
      final now = DateTime.now();
      return now.difference(local).inMinutes >= minutes;
    } catch (_) {
      return true;
    }
  }
}
