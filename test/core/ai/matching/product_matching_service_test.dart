import 'package:flutter_test/flutter_test.dart';
import 'package:quico/core/ai/parser/product_matching_service.dart';
import 'package:quico/core/ai/parser/parsed_order_models.dart';

void main() {
  late ProductMatchingService service;
  final catalog = [
    {'id': '1', 'name': 'Ca phe sua', 'normalized_name': 'ca phe sua'},
    {'id': '2', 'name': 'Tra dao', 'normalized_name': 'tra dao'},
    {'id': '3', 'name': 'Tra dao cam sa', 'normalized_name': 'tra dao cam sa'},
  ];

  setUp(() {
    service = ProductMatchingService();
  });

  group('Exact Match', () {
    test('returns exact for identical normalized name', () async {
      final result = await service.matchProduct(
        storeId: 'store1',
        rawName: 'Ca phe sua',
        catalog: catalog,
      );
      expect(result.match?.confidence, ProductMatchConfidence.exact);
    });

    test('returns exact for normalized input', () async {
      final result = await service.matchProduct(
        storeId: 'store1',
        rawName: 'ca phe sua',
        catalog: catalog,
      );
      expect(result.match?.confidence, ProductMatchConfidence.exact);
    });
  });

  group('Abbreviation Match', () {
    test('matches cf to ca phe sua', () async {
      final result = await service.matchProduct(
        storeId: 'store1',
        rawName: 'cf sua',
        catalog: catalog,
      );
      expect(result.match, isNotNull);
      expect(result.match!.confidence, isNot(ProductMatchConfidence.unknown));
    });
  });

  group('Unknown Match', () {
    test('returns unknown for non-existent product', () async {
      final result = await service.matchProduct(
        storeId: 'store1',
        rawName: 'banh trang tron',
        catalog: catalog,
      );
      expect(result.match, isNull);
    });
  });
}
