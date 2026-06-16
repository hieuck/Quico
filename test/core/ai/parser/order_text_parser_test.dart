import 'package:flutter_test/flutter_test.dart';
import 'package:quico/core/ai/parser/rule_based_order_text_parser.dart';

void main() {
  late RuleBasedOrderTextParser parser;

  setUp(() {
    parser = RuleBasedOrderTextParser();
  });

  group('Basic Quantity Parsing', () {
    test('parses quantity with digit prefix', () async {
      final result = await parser.parse('2 ca phe sua');
      expect(result.items.length, 1);
      expect(result.items[0].quantity, 2);
      expect(result.items[0].rawName, '2 ca phe sua');
    });

    test('parses Vietnamese number words', () async {
      final result = await parser.parse('hai ca phe sua');
      expect(result.items.length, 1);
      expect(result.items[0].quantity, 2);
    });

    test('parses "ba" as 3', () async {
      final result = await parser.parse('ba tra dao');
      expect(result.items.length, 1);
      expect(result.items[0].quantity, 3);
    });
  });

  group('Price Parsing', () {
    test('parses price with k suffix', () async {
      final result = await parser.parse('2 tra dao 35k');
      expect(result.items.length, 1);
      expect(result.items[0].unitPrice, 35000);
    });

    test('parses price with "nghin" suffix', () async {
      final result = await parser.parse('1 banh mi 20 nghin');
      expect(result.items.length, 1);
      expect(result.items[0].unitPrice, 20000);
    });

    test('parses full number price', () async {
      final result = await parser.parse('1 tra sua 35000');
      expect(result.items.length, 1);
      expect(result.items[0].unitPrice, 35000);
    });
  });

  group('Multiple Items', () {
    test('parses comma separated items', () async {
      final result = await parser.parse('2 ca phe sua, 1 tra dao');
      expect(result.items.length, 2);
      expect(result.items[0].quantity, 2);
      expect(result.items[1].quantity, 1);
    });

    test('parses plus separated items', () async {
      final result = await parser.parse('2 ca phe sua + 1 tra dao');
      expect(result.items.length, 2);
    });

    test('parses "va" separated items', () async {
      final result = await parser.parse('2 ca phe sua va 1 tra dao');
      expect(result.items.length, 2);
    });
  });

  group('Customer Hint', () {
    test('detects customer hint with "ban cho"', () async {
      final result = await parser.parse('ban cho chi Lan 2 tra dao');
      expect(result.customerHint, 'chi');
    });
  });

  group('Empty Input', () {
    test('returns empty items for empty input', () async {
      final result = await parser.parse('');
      expect(result.items.isEmpty, true);
    });

    test('returns blocking warning for empty input', () async {
      final result = await parser.parse('');
      expect(result.warnings.any((w) => w.blocking), true);
    });
  });
}
