import 'parsed_order_models.dart';

abstract class MenuTextParser {
  Future<List<ParsedMenuProduct>> parse(String input);
}
