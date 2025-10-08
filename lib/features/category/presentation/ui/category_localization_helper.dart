import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entity/category.dart';

List<Category> translateDefaultCategories(
    BuildContext context,
    List<Category> categories,
    ) {
  final l10n = AppLocalizations.of(context)!;

  return categories.map((c) {
    switch (c.id) {
      case 'food':
        return c.copyWith(name: l10n.category_food);
      case 'entertainment':
        return c.copyWith(name: l10n.category_entertainment);
      case 'travel':
        return c.copyWith(name: l10n.category_travel);
      default:
        return c;
    }
  }).toList();
}
