import 'parser_data.dart';
import 'parsed_order_models.dart';
import 'menu_text_parser.dart';

class RuleBasedMenuTextParser implements MenuTextParser {
  static final _pricePatterns = [
    RegExp(r'^(.+?)\s+(\d+)\s*(k|K)$'),
    RegExp(r'^(.+?)\s+(\d+)\.(\d+)$'),
    RegExp(r'^(.+?)\s+(\d+),(\d+)$'),
    RegExp(r'^(.+?)\s+(\d+)\s*(nghin|ngan)\s*$', caseSensitive: false),
  ];

  @override
  Future<List<ParsedMenuProduct>> parse(String input) async {
    final lines = input.split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final results = <ParsedMenuProduct>[];

    for (final line in lines) {
      final product = _parseLine(line);
      if (product != null) {
        results.add(product);
      }
    }

    return results;
  }

  ParsedMenuProduct? _parseLine(String line) {
    for (final pattern in _pricePatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final name = match.group(1)!.trim();
        final priceNum = int.parse(match.group(2)!);

        int price;
        final suffix = match.groupCount >= 3 ? match.group(3) : null;
        if (suffix == 'k' || suffix == 'K') {
          price = priceNum * 1000;
        } else if (suffix != null && suffix.length > 1) {
          price = priceNum * 1000;
        } else if (suffix == null && match.groupCount >= 4) {
          final decimal = match.group(3)!;
          price = priceNum * 1000 + int.parse(decimal.padRight(3, '0').substring(0, 3));
        } else {
          price = priceNum;
        }
        return ParsedMenuProduct(name: name, salePrice: price);
      }
    }

    return null;
  }
}
