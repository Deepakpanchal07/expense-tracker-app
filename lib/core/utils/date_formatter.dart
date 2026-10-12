import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    } else if (itemDate == yesterday) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    }
  }

  static String formatDateOnly(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }
}
