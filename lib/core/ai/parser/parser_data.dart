class ParserData {
  ParserData._();

  static const List<String> notes = [
    'it da', 'nhieu da', 'khong duong', 'it duong',
    'nhieu sua', 'nong', 'da',
  ];

  static const List<String> customerPrefixes = [
    'ban cho', 'khach', 'chi', 'anh', 'co', 'chu',
  ];

  static const String separatorPattern = r'[,;+va]|\n';

  static const String thousandUnits = r'k|K|nghin|ngan';

  static const String wordNumberPattern = r'^(mot|hai|ba|bon|nam|sau|bay|tam|chin|muoi)\s+(.*)';
}
