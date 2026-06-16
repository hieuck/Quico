import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';

class MoneyText extends StatelessWidget {
  final int amount;
  final TextStyle? style;

  const MoneyText({super.key, required this.amount, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(amount),
      style: (style ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
