import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const iconFiles = [
  'assets/icon/app_icon.png',
  'assets/icon/app_icon_foreground.png',
  'assets/icon/store_icon.png',
];

void main() {
  test('every icon asset exists and is a real PNG', () {
    for (final path in iconFiles) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path is missing');
      expect(file.lengthSync(), greaterThan(1000), reason: path);
      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(24), reason: path);
      expect([bytes[0], bytes[1]], [0x89, 0x50], reason: path);
      expect(String.fromCharCodes(bytes.sublist(1, 4)), 'PNG', reason: path);
    }
  });
}
