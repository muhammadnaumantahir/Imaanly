import 'package:flutter/material.dart';

import 'package:imaanly/src/screen/azkar/azkar_categories_screen.dart';

/// Imaanly entry point for Duas & Adhkar.
///
/// The mature bundled Adhkar experience remains the source of truth for the
/// content, categories, search, detail and sharing flows. This feature-level
/// entry point gives the app a stable Duas surface without duplicating that
/// implementation.
class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  Widget build(BuildContext context) {
    return AzkarCategoriesScreen(initialCategory: initialCategory);
  }
}
