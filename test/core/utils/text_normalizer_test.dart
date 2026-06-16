import 'package:flutter_test/flutter_test.dart';
import 'package:quico/core/utils/text_normalizer.dart';

void main() {
  group('TextNormalizer', () {
    test('removes Vietnamese diacritics', () {
      expect(TextNormalizer.normalize('Ca phe sua da'), 'ca phe sua da');
    });

    test('trims and collapses spaces', () {
      expect(TextNormalizer.normalize('  Tra   Dao  '), 'tra dao');
    });

    test('removes punctuation', () {
      expect(TextNormalizer.normalize('Ca-phe_sua!'), 'ca phe sua');
    });

    test('expands cf to cafe', () {
      expect(TextNormalizer.expandAbbreviations('cf sua'), contains('ca phe sua'));
    });
  });
}
