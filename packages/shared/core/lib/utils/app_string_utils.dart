extension AppStringSanitize on String {
  String get sanitize => replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '').join(' ');
}






