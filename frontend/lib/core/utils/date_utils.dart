import 'package:intl/intl.dart';

class RentoDateUtils {
  RentoDateUtils._();

  static final _display = DateFormat('dd MMM yyyy');
  static final _short = DateFormat('dd MMM');

  /// e.g. "15 Jan 2025"
  static String display(DateTime date) => _display.format(date);

  /// e.g. "15 Jan"
  static String short(DateTime date) => _short.format(date);

  /// Parse ISO string safely
  static DateTime? parse(String? iso) {
    if (iso == null) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final diff = end.difference(start);
    // Use seconds to handle partial days accurately
    return (diff.inSeconds / 86400).ceil().clamp(1, 9999);
  }

  /// "15 Jan – 20 Jan" range label
  static String range(DateTime start, DateTime end) => '${short(start)} – ${short(end)}';

  /// "2 days ago" / "just now"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return display(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
