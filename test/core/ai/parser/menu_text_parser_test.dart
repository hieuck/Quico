import 'package:flutter_test/flutter_test.dart';
import 'package:quico/core/ai/parser/rule_based_menu_text_parser.dart';

void main() {
  late RuleBasedMenuTextParser parser;

  setUp(() {
    parser = RuleBasedMenuTextParser();
  });

  group('Menu Parser', () {
    test('parses simple menu items with k price', () async {
      final result = await parser.parse('Ca phe den 25k');
      expect(result.length, 1);
      expect(result[0].name, 'Ca phe den');
      expect(result[0].salePrice, 25000);
    });

    test('parses multiple menu items', () async {
      final input = 'Ca phe den 25k\nCa phe sua 30k\nTra dao cam sa 35k';
      final result = await parser.parse(input);
      expect(result.length, 3);
      expect(result[0].salePrice, 25000);
      expect(result[1].salePrice, 30000);
      expect(result[2].salePrice, 35000);
    });

    test('parses dot price format', () async {
      final result = await parser.parse('Ca phe sua 30.000');
      expect(result.length, 1);
      expect(result[0].salePrice, 30000);
    });
  });
}
