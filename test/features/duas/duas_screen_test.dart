import 'package:flutter_test/flutter_test.dart';
import 'package:imaanly/features/duas/presentation/duas_screen.dart';

void main() {
  test('DuasScreen exposes an optional initial category', () {
    const screen = DuasScreen(initialCategory: 'أذكار الصباح');

    expect(screen.initialCategory, 'أذكار الصباح');
  });

  test('DuasScreen can be created without a category', () {
    const screen = DuasScreen();

    expect(screen.initialCategory, isNull);
  });
}
