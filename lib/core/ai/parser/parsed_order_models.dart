class ParsedOrderDraft {
  final String originalInput;
  final String source;
  final String? customerHint;
  final List<ParsedOrderItem> items;
  final String? note;
  final List<AiWarning> warnings;

  const ParsedOrderDraft({
    required this.originalInput,
    required this.source,
    required this.items,
    this.customerHint,
    this.note,
    this.warnings = const [],
  });
}

class ParsedOrderItem {
  final String rawName;
  final int quantity;
  final int? unitPrice;
  final String? note;
  final ProductMatch? productMatch;
  final List<AiWarning> warnings;

  const ParsedOrderItem({
    required this.rawName,
    required this.quantity,
    this.unitPrice,
    this.note,
    this.productMatch,
    this.warnings = const [],
  });
}

class ProductMatch {
  final String? productId;
  final String productName;
  final ProductMatchConfidence confidence;
  final double score;

  const ProductMatch({
    required this.productId,
    required this.productName,
    required this.confidence,
    required this.score,
  });
}

enum ProductMatchConfidence {
  exact,
  high,
  medium,
  low,
  unknown,
}

class AiWarning {
  final AiWarningType type;
  final String message;
  final bool blocking;

  const AiWarning({
    required this.type,
    required this.message,
    required this.blocking,
  });
}

enum AiWarningType {
  unknownProduct,
  lowConfidenceProduct,
  missingPrice,
  invalidQuantity,
  duplicateItem,
  unclearText,
  ocrLowConfidence,
  speechLowConfidence,
}

class ParsedMenuProduct {
  final String name;
  final int salePrice;
  final bool isDuplicate;

  const ParsedMenuProduct({
    required this.name,
    required this.salePrice,
    this.isDuplicate = false,
  });
}
