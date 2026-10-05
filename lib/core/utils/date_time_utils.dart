import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  static String formatDate(DateTime dt) {
    return DateFormat('EEE, MMM d').format(dt);
  }

  static String formatFullDate(DateTime dt) {
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  static String formatDuration(Duration d) {
    if (d.inHours > 0) {
      final mins = d.inMinutes % 60;
      return mins > 0 ? '${d.inHours}h ${mins}m' : '${d.inHours}h';
    }
    return '${d.inMinutes}m';
  }

  static String getRelativeTimeStatus(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isAfter(start) && now.isBefore(end)) {
      final remaining = end.difference(now);
      return 'Happening now • ${remaining.inMinutes}m left';
    } else if (now.isBefore(start)) {
      final diff = start.difference(now);
      if (diff.inDays > 0) {
        return 'In ${diff.inDays}d';
      } else if (diff.inHours > 0) {
        return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        return 'Starts in ${diff.inMinutes}m';
      }
    } else {
      return 'Ended';
    }
  }

  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }
}
