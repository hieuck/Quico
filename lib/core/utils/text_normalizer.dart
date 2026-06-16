class TextNormalizer {
  static final _diacriticsMap = {
    'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
    'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
    'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
    'đ': 'd',
    'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
    'ê': 'e', 'ề': 'e', 'ế': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
    'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
    'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
    'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
    'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
    'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
    'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
    'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
  };

  static final _abbreviationMap = {
    'cf': 'cafe',
    'cafe': 'ca phe',
    'caphe': 'ca phe',
    'ts': 'tra sua',
    'td': 'tra dao',
    'st': 'sua tuoi',
  };

  static String removeDiacritics(String input) {
    return input.split('').map((c) => _diacriticsMap[c] ?? c).join('');
  }

  static String normalize(String input) {
    if (input.isEmpty) return input;
    String result = input.toLowerCase().trim();
    result = result.replaceAll(RegExp(r'[^\w\s]'), ' ');
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    result = removeDiacritics(result);
    return result.trim();
  }

  static String expandAbbreviations(String input) {
    String result = input.toLowerCase().trim();
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    final words = result.split(' ');
    final expanded = words.map((w) => _abbreviationMap[w] ?? w).join(' ');
    return normalize(expanded);
  }
}
