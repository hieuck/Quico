import 'parser_data.dart';
import '../../utils/text_normalizer.dart';
import 'order_text_parser.dart';
import 'parsed_order_models.dart';

class RuleBasedOrderTextParser implements OrderTextParser {
  static final Map<String, int> _numberWords = {
    'mot': 1, 'mot_alt': 1, 'hai': 2, 'ba': 3,
    'bon': 4, 'tu': 4, 'nam': 5, 'lam': 5,
    'sau': 6, 'bay': 7, 'bay_alt': 7, 'tam': 8,
    'chin': 9, 'muoi': 10,
  };

  static final _separators = RegExp(ParserData.separatorPattern);

  @override
  Future<ParsedOrderDraft> parse(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return ParsedOrderDraft(
        originalInput: input,
        source: 'text',
        items: [],
        warnings: [AiWarning(
          type: AiWarningType.unclearText,
          message: 'No products detected.',
          blocking: true,
        )],
      );
    }

    String remaining = TextNormalizer.removeDiacritics(trimmed.toLowerCase());
    String? customerHint;
    for (final prefix in ParserData.customerPrefixes) {
      final idx = remaining.indexOf(prefix);
      if (idx != -1) {
        final afterPrefix = remaining.substring(idx + prefix.length).trim();
        final spaceIdx = afterPrefix.indexOf(' ');
        customerHint = afterPrefix.substring(0, spaceIdx > 0 ? spaceIdx : afterPrefix.length).trim();
        remaining =
            remaining.replaceFirst('$prefix $customerHint', '').trim();
        break;
      }
    }

    final parts = remaining.split(_separators)
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return ParsedOrderDraft(
        originalInput: input,
        source: 'text',
        items: [],
        warnings: [AiWarning(
          type: AiWarningType.unclearText,
          message: 'No products detected.',
          blocking: true,
        )],
      );
    }

    final items = <ParsedOrderItem>[];
    final warnings = <AiWarning>[];

    for (final part in parts) {
      final item = _parseItem(part);
      items.add(item);
      warnings.addAll(item.warnings);
    }

    String? orderNote;
    final noteParts = <String>[];
    for (final item in items) {
      if (item.note != null && !noteParts.contains(item.note)) {
        noteParts.add(item.note!);
      }
    }
    if (noteParts.isNotEmpty) {
      orderNote = noteParts.join(', ');
    }

    return ParsedOrderDraft(
      originalInput: input,
      source: 'text',
      customerHint: customerHint,
      items: items,
      note: orderNote,
      warnings: warnings,
    );
  }

  ParsedOrderItem _parseItem(String raw) {
    int quantity = 1;
    int? unitPrice;
    String? note;
    String remaining = raw.trim();
    final warnings = <AiWarning>[];

    final quantityMatch = RegExp(r'^(\d+)\s+(.*)').firstMatch(remaining);
    if (quantityMatch != null) {
      quantity = int.parse(quantityMatch.group(1)!);
      remaining = quantityMatch.group(2)!.trim();
    } else {
      final wordMatch = RegExp(ParserData.wordNumberPattern).firstMatch(remaining);
      if (wordMatch != null) {
        quantity = _numberWords[wordMatch.group(1)!] ?? 1;
        remaining = wordMatch.group(2)!.trim();
      }
    }

    final priceMatch = RegExp(r'^(.*?)\s+(\d+)\s*$').firstMatch(remaining);
    if (priceMatch != null) {
      productName = priceMatch.group(1)!.trim();
      unitPrice = int.parse(priceMatch.group(2)!);
      remaining = productName;
    }

    final kPrice = RegExp(r'^(.*?)\s+(\d+)\s*(k|K)\s*$').firstMatch(remaining);
    if (kPrice != null) {
      productName = kPrice.group(1)!.trim();
      unitPrice = int.parse(kPrice.group(2)!) * 1000;
      remaining = productName;
    }

    final priceWithUnit = RegExp(r'^(.*?)\s+(\d+)\s+(nghin|ngan)\s*$').firstMatch(remaining);
    if (priceWithUnit != null) {
      productName = priceWithUnit.group(1)!.trim();
      unitPrice = int.parse(priceWithUnit.group(2)!) * 1000;
      remaining = productName;
    }

    for (final n in ParserData.notes) {
      if (remaining.contains(n)) {
        note = n;
        remaining = remaining.replaceFirst(n, '').trim();
        break;
      }
    }

    productName = remaining;

    if (productName.isEmpty) {
      warnings.add(const AiWarning(
        type: AiWarningType.unclearText,
        message: 'Could not identify product.',
        blocking: true,
      ));
    }

    return ParsedOrderItem(
      rawName: raw,
      quantity: quantity,
      unitPrice: unitPrice,
      note: note,
      productMatch: null,
      warnings: warnings,
    );
  }
}
