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
}
