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

  static String formatToShortOrdinalDate(dynamic rawDate) {
    if (rawDate == null) return '';
    try {
      DateTime? parsed;
      if (rawDate is DateTime) {
        parsed = rawDate;
      } else if (rawDate is String && rawDate.isNotEmpty) {
        parsed = DateTime.tryParse(rawDate) ?? _tryParseCustomFormat(rawDate);
      }
      if (parsed == null) return rawDate.toString();

      final day = parsed.day;
      final suffix = _getDaySuffix(day);
      final monthName = _getShortMonthName(parsed.month);
      final year = parsed.year;

      return '$day$suffix $monthName $year';
    } catch (_) {
      return rawDate.toString();
    }
  }

  static DateTime? _tryParseCustomFormat(String str) {
    try {
      final clean = str.trim();
      final parts = clean.split(RegExp(r'[-/ ]+'));
      if (parts.length >= 3) {
        int? day;
        int? month;
        int? year;

        final p0 = int.tryParse(parts[0].replaceAll(RegExp(r'[^\d]'), ''));
        final p2 = int.tryParse(parts[2].replaceAll(RegExp(r'[^\d]'), ''));

        if (p0 != null && p2 != null) {
          if (parts[2].length == 4) {
            year = p2;
            day = p0;
            month = _parseMonthStr(parts[1]);
          } else if (parts[0].length == 4) {
            year = p0;
            month = _parseMonthStr(parts[1]);
            day = p2;
          }
        }
        if (year != null && month != null && day != null && day >= 1 && day <= 31 && month >= 1 && month <= 12) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }

  static int? _parseMonthStr(String m) {
    final num = int.tryParse(m);
    if (num != null && num >= 1 && num <= 12) return num;
    const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    final lower = m.toLowerCase();
    for (int i = 0; i < months.length; i++) {
      if (lower.startsWith(months[i])) return i + 1;
    }
    return null;
  }

  static String formatDateRangeOrdinal(dynamic start, dynamic end, {String defaultText = 'Date Range'}) {
    final startStr = formatToShortOrdinalDate(start);
    final endStr = formatToShortOrdinalDate(end);
    if (startStr.isEmpty && endStr.isEmpty) return defaultText;
    if (startStr.isEmpty) return endStr;
    if (endStr.isEmpty) return startStr;
    return '$startStr - $endStr';
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

  static String formatToDateDayMonth(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Never';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return rawDate;

      final local = parsed.toLocal();
      final day = local.day.toString().padLeft(2, '0');
      final monthName = _getShortMonthName(local.month);
      
      return '$day $monthName';
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

      if (difference.isNegative || difference.inSeconds < 5) {
        return 'Just now';
      } else if (difference.inSeconds < 60) {
        final secs = difference.inSeconds;
        return '$secs sec${secs > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes < 60) {
        final mins = difference.inMinutes;
        return '$mins min${mins > 1 ? 's' : ''} ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours hr${hours > 1 ? 's' : ''} ago';
      } else {
        final days = difference.inDays > 0 ? difference.inDays : (difference.inHours ~/ 24);
        final dayVal = days < 1 ? 1 : days;
        return '$dayVal day${dayVal > 1 ? 's' : ''} ago';
      }
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
