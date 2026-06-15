import 'package:flutter_test/flutter_test.dart';
import 'package:fluxdo/utils/number_utils.dart';

void main() {
  group('NumberUtils.formatSignedInt', () {
    test('正数会补充加号', () {
      expect(NumberUtils.formatSignedInt(12), '+12');
    });

    test('负数只保留原始负号', () {
      expect(NumberUtils.formatSignedInt(-12), '-12');
    });

    test('零不补充符号', () {
      expect(NumberUtils.formatSignedInt(0), '0');
    });
  });
}
