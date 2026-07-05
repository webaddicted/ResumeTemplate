extension StringExtension on String {
  bool get isValidEmail {
    final pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(pattern).hasMatch(this);
  }

  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}
