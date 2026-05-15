import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _inrDecimal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  /// Format as ₹1,500
  static String format(num amount) => _inr.format(amount);

  /// Format as ₹1,500.00
  static String formatDecimal(num amount) => _inrDecimal.format(amount);

  /// Format per day: ₹500/day
  static String perDay(num amount) => '${format(amount)}/day';
}
