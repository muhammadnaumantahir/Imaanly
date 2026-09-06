import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_furkan/src/theme/imaanly_tokens.dart';
import 'package:al_furkan/src/theme/imaanly_components.dart';

void main() {
  group('Imaanly design tokens', () {
    test('spacing scale is ordered and stable', () {
      expect(ImaanlySpacing.xxs, 4);
      expect(ImaanlySpacing.xs, 8);
      expect(ImaanlySpacing.sm, 12);
      expect(ImaanlySpacing.md, 16);
      expect(ImaanlySpacing.lg, 20);
      expect(ImaanlySpacing.xl, 24);
      expect(ImaanlySpacing.xxl, 32);
      expect(ImaanlySpacing.xxxl, 40);
    });

    test('radius scale is ordered', () {
      expect(ImaanlyRadius.sm, lessThan(ImaanlyRadius.md));
      expect(ImaanlyRadius.md, lessThan(ImaanlyRadius.lg));
      expect(ImaanlyRadius.lg, lessThan(ImaanlyRadius.xl));
      expect(ImaanlyRadius.xl, lessThan(ImaanlyRadius.pill));
    });
  });

  testWidgets('ImaanlyProgress clamps values safely', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ImaanlyProgress(value: 1.5, label: 'Daily worship'),
        ),
      ),
    );

    expect(find.text('Daily worship'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 1.0);
  });
}
