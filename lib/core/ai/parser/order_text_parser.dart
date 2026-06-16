import 'parsed_order_models.dart';

abstract class OrderTextParser {
  Future<ParsedOrderDraft> parse(String input);
}
