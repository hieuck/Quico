import 'package:flutter_test/flutter_test.dart';
import 'package:quico/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats 0 as 0d', () {
      expect(CurrencyFormatter.format(0), '0d');
    });

    test('formats 1000 as 1.000d', () {
      expect(CurrencyFormatter.format(1000), '1.000d');
    });

    test('formats 35000 as 35.000d', () {
      expect(CurrencyFormatter.format(35000), '35.000d');
    });

    test('formats 1250000 as 1.250.000d', () {
      expect(CurrencyFormatter.format(1250000), '1.250.000d');
    });
  });
}
