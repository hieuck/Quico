import '../../utils/text_normalizer.dart';
import 'parsed_order_models.dart';

class ProductMatchingService {
  Future<ProductMatchResult> matchProduct({
    required String storeId,
    required String rawName,
    required List<Map<String, dynamic>> catalog,
  }) async {
    final normalized = TextNormalizer.expandAbbreviations(rawName);

    for (final product in catalog) {
      final productName = product['normalized_name'] as String;

      if (normalized == productName) {
        return ProductMatchResult(
          match: ProductMatch(
            productId: product['id'] as String,
            productName: product['name'] as String,
            confidence: ProductMatchConfidence.exact,
            score: 1.0,
          ),
        );
      }

      final score = _tokenOverlapScore(normalized, productName);
      if (score >= 0.90) {
        return ProductMatchResult(
          match: ProductMatch(
            productId: product['id'] as String,
            productName: product['name'] as String,
            confidence: score >= 1.0 ? ProductMatchConfidence.exact : ProductMatchConfidence.high,
            score: score,
          ),
        );
      }
      if (score >= 0.75) {
        return ProductMatchResult(
          match: ProductMatch(
            productId: product['id'] as String,
            productName: product['name'] as String,
            confidence: ProductMatchConfidence.medium,
            score: score,
          ),
        );
      }
      if (score >= 0.55) {
        return ProductMatchResult(
          match: ProductMatch(
            productId: product['id'] as String,
            productName: product['name'] as String,
            confidence: ProductMatchConfidence.low,
            score: score,
          ),
        );
      }
    }

    return ProductMatchResult(
      match: null,
    );
  }

  double _tokenOverlapScore(String a, String b) {
    final tokensA = a.split(' ')..sort();
    final tokensB = b.split(' ')..sort();
    if (tokensA.isEmpty || tokensB.isEmpty) return 0.0;
    final intersection = tokensA.where((t) => tokensB.contains(t)).length;
    return 2.0 * intersection / (tokensA.length + tokensB.length);
  }
}

class ProductMatchResult {
  final ProductMatch? match;

  const ProductMatchResult({this.match});
}
