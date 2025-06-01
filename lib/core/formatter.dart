import 'package:intl/intl.dart';

class Formatter {
  static String formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }
}
