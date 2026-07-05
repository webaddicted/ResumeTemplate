import 'package:flutter/material.dart';

import '../../constant/card_categories.dart';
import '../../theme/app_theme.dart';

/// One generated card design: category × palette × style variant.
class CardTemplateSpec {
  const CardTemplateSpec({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.background,
    required this.accent,
    required this.ink,
    required this.variant,
  });

  final String id;
  final String name;
  final String categoryId;
  final Color background;
  final Color accent;
  final Color ink;

  /// 0–4 style variant; each family renderer interprets it.
  final int variant;

  TemplateInfo toInfo() => TemplateInfo(
        id: id,
        name: name,
        background: background,
        accent: accent,
        isDark: background.computeLuminance() < 0.4,
        hint: switch (variant) {
          0 => TemplateHint.frame,
          1 => TemplateHint.band,
          2 => TemplateHint.centered,
          3 => TemplateHint.gradient,
          _ => TemplateHint.rule,
        },
      );
}

// (id, name, background, accent, ink)
const _palettes = <(String, String, Color, Color, Color)>[
  ('rose', 'Rose', Color(0xFFFFF5FA), Color(0xFFC2185B), Color(0xFF3E1B2A)),
  ('royal', 'Royal', Color(0xFFF4F7FF), Color(0xFF1A3C8B), Color(0xFF1B2440)),
  ('emerald', 'Emerald', Color(0xFFF3FBF7), Color(0xFF1B7A4B), Color(0xFF193326)),
  ('violet', 'Violet', Color(0xFFFAF6FF), Color(0xFF6D28D9), Color(0xFF2A2140)),
  ('gold', 'Gold', Color(0xFFFFFDF4), Color(0xFFA16207), Color(0xFF3E3214)),
  ('teal', 'Teal', Color(0xFFF2FBFC), Color(0xFF0E7490), Color(0xFF143C46)),
  ('coral', 'Coral', Color(0xFFFFF6F4), Color(0xFFC2453A), Color(0xFF40231F)),
  ('slate', 'Slate', Color(0xFFF6F7F9), Color(0xFF334155), Color(0xFF1C2530)),
  ('plum', 'Plum', Color(0xFFFCF5F8), Color(0xFF7A1F4F), Color(0xFF37182A)),
  ('midnight', 'Midnight', Color(0xFF12121C), Color(0xFFE9B949), Color(0xFFF3F3F7)),
];

const _variantNames = ['Ornate', 'Banner', 'Classic', 'Gradient', 'Minimal'];

/// 50 specs per category (10 palettes × 5 variants).
List<CardTemplateSpec> specsFor(String categoryId) => [
      for (final (pid, pname, bg, accent, ink) in _palettes)
        for (var v = 0; v < _variantNames.length; v++)
          CardTemplateSpec(
            id: '${categoryId}__${pid}_$v',
            name: '$pname ${_variantNames[v]}',
            categoryId: categoryId,
            background: bg,
            accent: accent,
            ink: ink,
            variant: v,
          ),
    ];

/// Cached catalogues + lookup, built once per category on first access.
class CardCatalogue {
  CardCatalogue._();

  static final Map<String, List<CardTemplateSpec>> _byCategory = {
    for (final c in CardCategories.all) c.id: specsFor(c.id),
  };

  static final Map<String, CardTemplateSpec> _byId = {
    for (final list in _byCategory.values)
      for (final s in list) s.id: s,
  };

  static List<CardTemplateSpec> forCategory(String categoryId) =>
      _byCategory[categoryId] ?? const [];

  static List<TemplateInfo> infosFor(String categoryId) =>
      forCategory(categoryId).map((s) => s.toInfo()).toList();

  static CardTemplateSpec byId(String id) =>
      _byId[id] ?? _byCategory.values.first.first;

  static String defaultTemplateId(String categoryId) =>
      forCategory(categoryId).first.id;
}
