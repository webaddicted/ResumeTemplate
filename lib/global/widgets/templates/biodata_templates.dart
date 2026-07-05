import 'package:flutter/material.dart';

import 'package:template/global/theme/app_theme.dart';
import 'package:template/model/biodata_data.dart';

/// Frame / decoration treatment for a biodata template.
enum BiodataFrame {
  /// Double-line ornamental border ("Heritage").
  heritage,

  /// Single solid border ("Classic").
  classic,

  /// Accent corner brackets ("Regal").
  regal,

  /// Solid accent banner header ("Banner").
  banner,

  /// No frame, minimal rule under the name ("Simple").
  simple,
}

/// One biodata template: palette × frame style.
class BiodataTemplateSpec {
  const BiodataTemplateSpec({
    required this.id,
    required this.name,
    required this.background,
    required this.accent,
    required this.ink,
    required this.frame,
  });

  final String id;
  final String name;
  final Color background;
  final Color accent;
  final Color ink;
  final BiodataFrame frame;

  TemplateInfo toInfo() => TemplateInfo(
        id: id,
        name: name,
        background: background,
        accent: accent,
        isDark: false,
        hint: switch (frame) {
          BiodataFrame.banner => TemplateHint.band,
          BiodataFrame.simple => TemplateHint.centered,
          _ => TemplateHint.frame,
        },
      );
}

// (id, name, background tint, accent, ink)
const _bioPalettes = <(String, String, Color, Color, Color)>[
  ('maroon', 'Maroon', Color(0xFFFFF8F5), Color(0xFF800020), Color(0xFF3B1F24)),
  ('royal', 'Royal Blue', Color(0xFFF4F7FF), Color(0xFF1A3C8B), Color(0xFF1E2A45)),
  ('saffron', 'Saffron', Color(0xFFFFFBF2), Color(0xFFC2410C), Color(0xFF43302B)),
  ('emerald', 'Emerald', Color(0xFFF3FBF7), Color(0xFF1B7A4B), Color(0xFF1F3A2E)),
  ('purple', 'Royal Purple', Color(0xFFFAF6FF), Color(0xFF5B21B6), Color(0xFF2E2440)),
  ('peacock', 'Peacock', Color(0xFFF2FBFC), Color(0xFF0E7490), Color(0xFF164450)),
  ('gold', 'Antique Gold', Color(0xFFFFFDF4), Color(0xFFA16207), Color(0xFF423516)),
  ('coral', 'Coral', Color(0xFFFFF6F4), Color(0xFFC2453A), Color(0xFF462926)),
  ('burgundy', 'Burgundy', Color(0xFFFCF5F7), Color(0xFF6D1A36), Color(0xFF381B26)),
  ('rose', 'Rose Pink', Color(0xFFFFF5FA), Color(0xFFC2185B), Color(0xFF44202F)),
];

const _bioFrames = <(BiodataFrame, String)>[
  (BiodataFrame.heritage, 'Heritage'),
  (BiodataFrame.classic, 'Classic'),
  (BiodataFrame.regal, 'Regal'),
  (BiodataFrame.banner, 'Banner'),
  (BiodataFrame.simple, 'Simple'),
];

/// 50 biodata templates (10 palettes × 5 frame styles).
final List<BiodataTemplateSpec> biodataTemplateSpecs = [
  for (final (pid, pname, bg, accent, ink) in _bioPalettes)
    for (final (frame, fname) in _bioFrames)
      BiodataTemplateSpec(
        id: 'bio_${pid}_${frame.name}',
        name: '$pname $fname',
        background: bg,
        accent: accent,
        ink: ink,
        frame: frame,
      ),
];

final Map<String, BiodataTemplateSpec> biodataSpecById = {
  for (final s in biodataTemplateSpecs) s.id: s,
};

/// Renders [data] with the biodata template identified by [templateId].
Widget buildBiodataTemplate(String templateId, BiodataData data) {
  final spec = biodataSpecById[templateId] ?? biodataTemplateSpecs.first;
  return GenericBiodataTemplate(spec: spec, data: data);
}

class GenericBiodataTemplate extends StatelessWidget {
  const GenericBiodataTemplate({
    super.key,
    required this.spec,
    required this.data,
  });

  final BiodataTemplateSpec spec;
  final BiodataData data;

  Color get _inkSoft => Color.lerp(spec.ink, spec.background, 0.35)!;

  TextStyle _style(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color ?? spec.ink,
        height: 1.45,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      );

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (spec.frame != BiodataFrame.banner) _header(),
          _section('Personal Details', data.personalRows),
          _section('Horoscope Details', data.horoscopeRows),
          _section('Education & Career', data.careerRows),
          _section('Family Details', data.familyRows),
          if (data.expectations.trim().isNotEmpty) ...[
            _sectionTitle('Partner Expectations'),
            Text(data.expectations, style: _style(12)),
          ],
          _section('Contact Details', data.contactRows),
        ],
      ),
    );

    return Container(
      color: spec.background,
      padding: const EdgeInsets.all(12),
      child: switch (spec.frame) {
        BiodataFrame.heritage => Container(
            decoration: BoxDecoration(
              border: Border.all(color: spec.accent, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: spec.accent.withValues(alpha: 0.55),
                ),
              ),
              child: content,
            ),
          ),
        BiodataFrame.classic => Container(
            decoration: BoxDecoration(
              border: Border.all(color: spec.accent, width: 1.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: content,
          ),
        BiodataFrame.regal => Stack(
            children: [
              Padding(padding: const EdgeInsets.all(6), child: content),
              for (final corner in const [
                Alignment.topLeft,
                Alignment.topRight,
                Alignment.bottomLeft,
                Alignment.bottomRight,
              ])
                Align(
                  alignment: corner,
                  child: _CornerBracket(alignment: corner, color: spec.accent),
                ),
            ],
          ),
        BiodataFrame.banner => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: spec.accent,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                child: _headerContent(onAccent: true),
              ),
              content,
            ],
          ),
        BiodataFrame.simple => content,
      },
    );
  }

  Widget _header() => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _headerContent(onAccent: false),
        ),
      );

  Widget _headerContent({required bool onAccent}) {
    final fg = onAccent ? Colors.white : spec.ink;
    final fgAccent = onAccent ? Colors.white : spec.accent;
    return Column(
      children: [
        if (data.invocation.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              data.invocation,
              textAlign: TextAlign.center,
              style: _style(
                11.5,
                weight: FontWeight.w600,
                color: onAccent
                    ? Colors.white.withValues(alpha: 0.9)
                    : spec.accent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        Container(
          width: data.photo != null ? 84 : 58,
          height: data.photo != null ? 84 : 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onAccent
                ? Colors.white.withValues(alpha: 0.2)
                : spec.accent.withValues(alpha: 0.12),
            border: Border.all(color: fgAccent, width: 1.4),
            image: data.photo != null
                ? DecorationImage(
                    image: MemoryImage(data.photo!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: data.photo == null
              ? Text(
                  data.initials,
                  style: _style(20, weight: FontWeight.w800, color: fgAccent),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          data.name,
          textAlign: TextAlign.center,
          style: _style(22, weight: FontWeight.w800, color: fg),
        ),
        const SizedBox(height: 6),
        if (spec.frame != BiodataFrame.banner)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 1,
                color: spec.accent.withValues(alpha: 0.5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child:
                    Icon(Icons.diamond_rounded, size: 9, color: spec.accent),
              ),
              Container(
                width: 52,
                height: 1,
                color: spec.accent.withValues(alpha: 0.5),
              ),
            ],
          ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Flexible(
              child: Text(
                title.toUpperCase(),
                style: _style(
                  12,
                  weight: FontWeight.w800,
                  color: spec.accent,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                color: spec.accent.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      );

  Widget _section(String title, List<(String, String)> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 132,
                  child: Text(
                    label,
                    style: _style(
                      11.5,
                      weight: FontWeight.w700,
                      color: _inkSoft,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: _style(12, weight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// L-shaped accent bracket used by the "Regal" frame.
class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.alignment, required this.color});

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final top = alignment.y < 0;
    final left = alignment.x < 0;
    const side = BorderSide(width: 3);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: top ? side.copyWith(color: color) : BorderSide.none,
          bottom: !top ? side.copyWith(color: color) : BorderSide.none,
          left: left ? side.copyWith(color: color) : BorderSide.none,
          right: !left ? side.copyWith(color: color) : BorderSide.none,
        ),
      ),
    );
  }
}
