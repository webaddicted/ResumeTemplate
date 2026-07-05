import 'package:flutter/material.dart';

import 'package:template/global/widgets/templates/biodata_templates.dart';
import 'package:template/global/widgets/templates/resume_template_specs.dart';

/// Layout hint used to draw the miniature preview on template cards.
enum TemplateHint {
  leftBorder,
  band,
  gradient,
  centered,
  sidebar,
  rule,
  code,

  /// Ornamental frame around the whole page (biodata styles).
  frame,
}

/// Metadata for one template (catalogue entry) — resume or biodata.
class TemplateInfo {
  const TemplateInfo({
    required this.id,
    required this.name,
    required this.background,
    required this.accent,
    required this.isDark,
    this.secondaryAccent,
    this.hint = TemplateHint.rule,
  });

  final String id;
  final String name;
  final Color background;
  final Color accent;
  final Color? secondaryAccent;
  final bool isDark;
  final TemplateHint hint;
}

class AppTheme {
  AppTheme._();

  // ---- App chrome palette (dark UI) ----
  static const Color bg = Color(0xFF0E0E16);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceAlt = Color(0xFF22223A);
  static const Color accent = Color(0xFFE94560);
  static const Color textPrimary = Color(0xFFF1F1F5);
  static const Color textSecondary = Color(0xFF9A9AB0);
  static const Color outline = Color(0xFF31314D);

  // ---- Semantic status colors (ATS scores, severities) ----
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  /// ATS score colour band: red &lt; 60, orange 60–80, green &gt; 80.
  static Color scoreColor(int score) => score > 80
      ? success
      : score >= 60
          ? warning
          : danger;

  /// Resume content max width (PR-08).
  static const double resumeMaxWidth = 680;

  /// Form content max width on large screens.
  static const double formMaxWidth = 560;

  /// Bundled font family (assets/fonts/Nunito-*.ttf) — works fully offline.
  static const String fontFamily = 'Nunito';

  // ---- Hand-crafted resume templates (Appendix 13) ----
  static const List<TemplateInfo> _legacyTemplates = [
    TemplateInfo(
      id: 'modern_dark',
      name: 'Modern Dark',
      background: Color(0xFF1A1A2E),
      accent: Color(0xFFE94560),
      isDark: true,
      hint: TemplateHint.leftBorder,
    ),
    TemplateInfo(
      id: 'clean_minimal',
      name: 'Clean Minimal',
      background: Color(0xFFFFFFFF),
      accent: Color(0xFF2D6A4F),
      isDark: false,
      hint: TemplateHint.rule,
    ),
    TemplateInfo(
      id: 'corporate',
      name: 'Corporate Blue',
      background: Color(0xFFFFFFFF),
      accent: Color(0xFF1565C0),
      isDark: false,
      hint: TemplateHint.band,
    ),
    TemplateInfo(
      id: 'creative_side',
      name: 'Creative Split',
      background: Color(0xFFFFFFFF),
      accent: Color(0xFFFF6B6B),
      isDark: false,
      hint: TemplateHint.sidebar,
    ),
    TemplateInfo(
      id: 'bold_yellow',
      name: 'Bold Accent',
      background: Color(0xFF111111),
      accent: Color(0xFFF59E0B),
      isDark: true,
      hint: TemplateHint.rule,
    ),
    TemplateInfo(
      id: 'teal_elegant',
      name: 'Teal Elegant',
      background: Color(0xFFFAFAFA),
      accent: Color(0xFF0D9488),
      isDark: false,
      hint: TemplateHint.centered,
    ),
    TemplateInfo(
      id: 'two_column',
      name: 'Two Column',
      background: Color(0xFFFFFFFF),
      accent: Color(0xFF7C3AED),
      isDark: false,
      hint: TemplateHint.band,
    ),
    TemplateInfo(
      id: 'tech_mono',
      name: 'Tech Mono',
      background: Color(0xFF0F172A),
      accent: Color(0xFF22D3EE),
      isDark: true,
      hint: TemplateHint.code,
    ),
    TemplateInfo(
      id: 'executive',
      name: 'Executive',
      background: Color(0xFFFFF8F0),
      accent: Color(0xFF92400E),
      isDark: false,
      hint: TemplateHint.centered,
    ),
    TemplateInfo(
      id: 'gradient',
      name: 'Gradient Header',
      background: Color(0xFFFFFFFF),
      accent: Color(0xFF7C3AED),
      secondaryAccent: Color(0xFFDB2777),
      isDark: false,
      hint: TemplateHint.gradient,
    ),
  ];

  /// Full resume catalogue: 10 hand-crafted + 40 generated = 50.
  static final List<TemplateInfo> templates = [
    ..._legacyTemplates,
    for (final spec in resumeTemplateSpecs) spec.toInfo(),
  ];

  /// Biodata catalogue: 50 generated (10 palettes × 5 frame styles).
  static final List<TemplateInfo> biodataTemplates = [
    for (final spec in biodataTemplateSpecs) spec.toInfo(),
  ];

  static TemplateInfo templateById(String id) => templates.firstWhere(
        (t) => t.id == id,
        orElse: () => templates.first,
      );

  static TemplateInfo biodataTemplateById(String id) =>
      biodataTemplates.firstWhere(
        (t) => t.id == id,
        orElse: () => biodataTemplates.first,
      );

  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
        onSurface: textPrimary,
        outline: outline,
      ),
      scaffoldBackgroundColor: bg,
    );

    final textTheme = base.textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(44, 52),
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(44, 44),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceAlt,
        contentTextStyle:
            const TextStyle(fontFamily: fontFamily, color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
