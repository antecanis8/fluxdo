import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxdo/utils/svg_utils.dart';

void main() {
  group('SvgUtils.isSvgBytes', () {
    test('detects SVG content behind a misleading file extension', () {
      final bytes = utf8.encode('''
<?xml version="1.0"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500">
  <path d="M0 0h10v10z" />
</svg>
''');

      expect(SvgUtils.isSvgBytes(bytes), isTrue);
    });

    test('skips UTF-8 BOM and leading whitespace', () {
      final bytes = <int>[
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode('\n  <svg viewBox="0 0 1 1"></svg>'),
      ];

      expect(SvgUtils.isSvgBytes(bytes), isTrue);
    });

    test('does not treat arbitrary XML as SVG', () {
      final bytes = utf8.encode('<?xml version="1.0"?><rss></rss>');

      expect(SvgUtils.isSvgBytes(bytes), isFalse);
    });

    test('does not treat PNG bytes as SVG', () {
      final bytes = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

      expect(SvgUtils.isSvgBytes(bytes), isFalse);
    });
  });

  group('SvgUtils.decodeSvgBytes', () {
    test('removes UTF-8 BOM before parsing', () {
      final bytes = <int>[
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode('<svg viewBox="0 0 1 1"></svg>'),
      ];

      expect(SvgUtils.decodeSvgBytes(bytes), startsWith('<svg'));
    });
  });
}
