import 'package:flutter/material.dart';

import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/templates/template_base.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';

/// Header treatment for a generated resume template.
enum ResumeHeaderVariant {
  /// Solid accent band behind the header (like Corporate Blue).
  band,

  /// Thick accent border on the left edge of the page.
  edge,

  /// Centred header with a thin rule underneath.
  classic,

  /// Left-aligned header with a full-width accent rule.
  line,

  /// Accent → secondary gradient band.
  flow,
}

/// A generated resume template: palette × header variant.
class ResumeTemplateSpec {
  const ResumeTemplateSpec({
    required this.id,
    required this.name,
    required this.accent,
    required this.accent2,
    required this.header,
  });

  final String id;
  final String name;
  final Color accent;
  final Color accent2;
  final ResumeHeaderVariant header;

  TemplateInfo toInfo() => TemplateInfo(
        id: id,
        name: name,
        background: Colors.white,
        accent: accent,
        secondaryAccent: header == ResumeHeaderVariant.flow ? accent2 : null,
        isDark: false,
        hint: switch (header) {
          ResumeHeaderVariant.band => TemplateHint.band,
          ResumeHeaderVariant.edge => TemplateHint.leftBorder,
          ResumeHeaderVariant.classic => TemplateHint.centered,
          ResumeHeaderVariant.line => TemplateHint.rule,
          ResumeHeaderVariant.flow => TemplateHint.gradient,
        },
      );
}

const _palettes = <(String, String, Color, Color)>[
  ('sapphire', 'Sapphire', Color(0xFF1565C0), Color(0xFF42A5F5)),
  ('emerald', 'Emerald', Color(0xFF2D6A4F), Color(0xFF52B788)),
  ('crimson', 'Crimson', Color(0xFFC0392B), Color(0xFFE74C3C)),
  ('violet', 'Violet', Color(0xFF7C3AED), Color(0xFFA78BFA)),
  ('amber', 'Amber', Color(0xFFB45309), Color(0xFFF59E0B)),
  ('slate', 'Slate', Color(0xFF334155), Color(0xFF64748B)),
  ('lagoon', 'Lagoon', Color(0xFF0E7490), Color(0xFF22D3EE)),
  ('rosewood', 'Rosewood', Color(0xFFBE185D), Color(0xFFF472B6)),
];

const _headerVariants = <(ResumeHeaderVariant, String)>[
  (ResumeHeaderVariant.band, 'Band'),
  (ResumeHeaderVariant.edge, 'Edge'),
  (ResumeHeaderVariant.classic, 'Classic'),
  (ResumeHeaderVariant.line, 'Line'),
  (ResumeHeaderVariant.flow, 'Flow'),
];

/// 40 generated specs (8 palettes × 5 header styles). Together with the
/// 10 hand-crafted templates this yields the 50-template resume catalogue.
final List<ResumeTemplateSpec> resumeTemplateSpecs = [
  for (final (pid, pname, accent, accent2) in _palettes)
    for (final (variant, vname) in _headerVariants)
      ResumeTemplateSpec(
        id: 'gen_${pid}_${variant.name}',
        name: '$pname $vname',
        accent: accent,
        accent2: accent2,
        header: variant,
      ),
];

final Map<String, ResumeTemplateSpec> resumeSpecById = {
  for (final s in resumeTemplateSpecs) s.id: s,
};

/// Renders any generated resume template from its spec.
class GenericResumeTemplate extends StatelessWidget {
  const GenericResumeTemplate({
    super.key,
    required this.spec,
    required this.data,
  });

  final ResumeTemplateSpec spec;
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: Colors.white,
      accent: spec.accent,
      ink: const Color(0xFF1F2430),
      inkSoft: const Color(0xFF6B7280),
      sectionTitleBoxed: spec.header == ResumeHeaderVariant.band,
      sectionRuleFull: spec.header == ResumeHeaderVariant.line,
      diamondRule: spec.header == ResumeHeaderVariant.classic,
    );

    return Container(
      color: style.background,
      child: switch (spec.header) {
        ResumeHeaderVariant.band ||
        ResumeHeaderVariant.flow =>
          _bandLayout(style),
        ResumeHeaderVariant.edge => _edgeLayout(style),
        ResumeHeaderVariant.classic => _classicLayout(style),
        ResumeHeaderVariant.line => _lineLayout(style),
      },
    );
  }

  static const _pagePadding = EdgeInsets.fromLTRB(26, 28, 26, 32);

  Widget _bandLayout(TemplateStyle style) {
    final isFlow = spec.header == ResumeHeaderVariant.flow;
    final onBand = TemplateStyle(
      background: spec.accent,
      accent: Colors.white,
      ink: Colors.white,
      inkSoft: Colors.white,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isFlow ? null : spec.accent,
            gradient: isFlow
                ? LinearGradient(
                    colors: [spec.accent, spec.accent2],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
          ),
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResumePhoto(data, borderColor: Colors.white),
              Text(
                data.name,
                style: style.heading(size: 27, color: Colors.white),
              ),
              if (data.jobTitle.trim().isNotEmpty)
                Text(
                  data.jobTitle,
                  style: style.body(
                    size: 13.5,
                    weight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              if (data.tagline.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    data.tagline,
                    style: style.body(
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              if (data.hasContact)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ContactWrap(data, onBand, color: Colors.white),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 4, 26, 32),
          child: StandardBody(data, style),
        ),
      ],
    );
  }

  Widget _edgeLayout(TemplateStyle style) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: spec.accent, width: 5)),
      ),
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumePhoto(data, borderColor: spec.accent),
          Text(data.name, style: style.heading(size: 29)),
          if (data.jobTitle.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data.jobTitle,
                style: style.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: spec.accent,
                ),
              ),
            ),
          if (data.tagline.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                data.tagline,
                style: style.body(size: 11.5, color: style.inkSoft),
              ),
            ),
          if (data.hasContact)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ContactWrap(data, style),
            ),
          StandardBody(data, style),
        ],
      ),
    );
  }

  Widget _classicLayout(TemplateStyle style) {
    return Padding(
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ResumePhoto(data, borderColor: spec.accent),
                Text(
                  data.name,
                  textAlign: TextAlign.center,
                  style: style.heading(size: 28),
                ),
                if (data.jobTitle.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      data.jobTitle,
                      textAlign: TextAlign.center,
                      style: style.body(
                        size: 13,
                        weight: FontWeight.w600,
                        color: spec.accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                if (data.tagline.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      data.tagline,
                      textAlign: TextAlign.center,
                      style: style.body(
                        size: 11.5,
                        color: style.inkSoft,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  width: 120,
                  height: 2,
                  color: spec.accent.withValues(alpha: 0.6),
                ),
                if (data.hasContact)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ContactWrap(data, style),
                  ),
              ],
            ),
          ),
          StandardBody(data, style),
        ],
      ),
    );
  }

  Widget _lineLayout(TemplateStyle style) {
    return Padding(
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumePhoto(data, borderColor: spec.accent),
          Text(data.name, style: style.heading(size: 29)),
          if (data.jobTitle.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data.jobTitle,
                style: style.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: spec.accent,
                ),
              ),
            ),
          if (data.tagline.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                data.tagline,
                style: style.body(size: 11.5, color: style.inkSoft),
              ),
            ),
          const SizedBox(height: 10),
          Container(height: 3, color: spec.accent),
          if (data.hasContact)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ContactWrap(data, style),
            ),
          StandardBody(data, style),
        ],
      ),
    );
  }
}
