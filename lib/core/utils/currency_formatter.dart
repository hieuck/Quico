import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.decimalPattern('vi');

  static String format(int amount) {
    return '${_formatter.format(amount)}đ';
  }

  static String formatShort(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}tr';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 0)}k';
    }
    return '$amountđ';
  }
}
