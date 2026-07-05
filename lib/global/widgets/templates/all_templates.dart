import 'package:flutter/material.dart';

import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/templates/resume_template_specs.dart';
import 'package:template/global/widgets/templates/template_base.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';

/// Renders [data] with the template identified by [templateId].
/// Hand-crafted ids map to dedicated widgets; generated ids (`gen_*`)
/// render via [GenericResumeTemplate]. Unknown ids fall back to Modern Dark.
Widget buildTemplate(String templateId, ResumeData data) {
  final spec = resumeSpecById[templateId];
  if (spec != null) return GenericResumeTemplate(spec: spec, data: data);
  return switch (templateId) {
    'clean_minimal' => CleanMinimalTemplate(data: data),
    'corporate' => CorporateTemplate(data: data),
    'creative_side' => CreativeSplitTemplate(data: data),
    'bold_yellow' => BoldAccentTemplate(data: data),
    'teal_elegant' => TealElegantTemplate(data: data),
    'two_column' => TwoColumnTemplate(data: data),
    'tech_mono' => TechMonoTemplate(data: data),
    'executive' => ExecutiveTemplate(data: data),
    'gradient' => GradientTemplate(data: data),
    _ => ModernDarkTemplate(data: data),
  };
}

const _pagePadding = EdgeInsets.fromLTRB(26, 28, 26, 32);

/// Stacks two-pane layouts vertically on narrow widths (responsive).
const double _splitBreakpoint = 480;

// ---------------------------------------------------------------------------
// 1. Modern Dark — left accent border, Playfair header, crimson highlights
// ---------------------------------------------------------------------------
class ModernDarkTemplate extends StatelessWidget {
  const ModernDarkTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: const Color(0xFF1A1A2E),
      accent: const Color(0xFFE94560),
      ink: const Color(0xFFEDEDF2),
      inkSoft: const Color(0xFF9A9AB0),
      serifHeadings: true,
    );
    return Container(
      color: style.background,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFFE94560), width: 5)),
        ),
        padding: _pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResumePhoto(data, borderColor: style.accent),
            Text(data.name, style: style.heading(size: 30)),
            if (data.jobTitle.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  data.jobTitle,
                  style: style.body(
                    size: 14,
                    weight: FontWeight.w600,
                    color: style.accent,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Clean Minimal — pure white, serif header, thin rules, green accents
// ---------------------------------------------------------------------------
class CleanMinimalTemplate extends StatelessWidget {
  const CleanMinimalTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: Colors.white,
      accent: const Color(0xFF2D6A4F),
      ink: const Color(0xFF1B1B1B),
      inkSoft: const Color(0xFF6B6B6B),
      serifHeadings: true,
      sectionRuleFull: true,
    );
    return Container(
      color: style.background,
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumePhoto(data, borderColor: style.accent),
          Text(data.name,
              style: style.heading(size: 30, weight: FontWeight.w700)),
          if (data.jobTitle.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data.jobTitle,
                style: style.body(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: style.accent,
                ),
              ),
            ),
          if (data.tagline.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                data.tagline,
                style: style.body(
                  size: 11.5,
                  color: style.inkSoft,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (data.hasContact)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ContactWrap(data, style),
            ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFE0E0E0)),
          StandardBody(data, style),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Corporate Blue — solid blue header band, boxed section labels
// ---------------------------------------------------------------------------
class CorporateTemplate extends StatelessWidget {
  const CorporateTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: Colors.white,
      accent: const Color(0xFF1565C0),
      ink: const Color(0xFF202124),
      inkSoft: const Color(0xFF5F6368),
      sectionTitleBoxed: true,
    );
    return Container(
      color: style.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF1565C0),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      data.jobTitle,
                      style: style.body(
                        size: 13.5,
                        weight: FontWeight.w600,
                        color: const Color(0xFFBBDEFB),
                      ),
                    ),
                  ),
                if (data.tagline.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      data.tagline,
                      style: style.body(
                        size: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                if (data.hasContact)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ContactWrap(
                      data,
                      TemplateStyle(
                        background: const Color(0xFF1565C0),
                        accent: const Color(0xFFBBDEFB),
                        ink: Colors.white,
                        inkSoft: Colors.white,
                      ),
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 4, 26, 32),
            child: StandardBody(data, style),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Creative Split — dark sidebar with initials avatar + skills panel
// ---------------------------------------------------------------------------
class CreativeSplitTemplate extends StatelessWidget {
  const CreativeSplitTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final main = TemplateStyle(
      background: Colors.white,
      accent: const Color(0xFFFF6B6B),
      ink: const Color(0xFF222222),
      inkSoft: const Color(0xFF6B6B6B),
    );
    final side = TemplateStyle(
      background: const Color(0xFF1A1A1A),
      accent: const Color(0xFFFF6B6B),
      ink: const Color(0xFFEDEDED),
      inkSoft: const Color(0xFFB5B5B5),
    );

    final sidebar = Container(
      color: side.background,
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: side.accent,
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
                      style: side.heading(size: 26, color: Colors.white),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              data.name,
              textAlign: TextAlign.center,
              style: side.heading(size: 18),
            ),
          ),
          if (data.jobTitle.trim().isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  data.jobTitle,
                  textAlign: TextAlign.center,
                  style: side.body(
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: side.accent,
                  ),
                ),
              ),
            ),
          if (data.hasContact) ...[
            SectionTitle('Contact', side),
            ContactWrap(data, side, vertical: true),
          ],
          ResumeSection(
            visible: data.filledExpertise.isNotEmpty,
            title: 'Expertise',
            style: side,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in data.filledExpertise)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('—  $e', style: side.body(size: 11.5)),
                  ),
              ],
            ),
          ),
          ResumeSection(
            visible: data.filledTechSkills.isNotEmpty,
            title: 'Skills',
            style: side,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final g in data.filledTechSkills)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.category,
                          style: side.body(
                            size: 11,
                            weight: FontWeight.w700,
                            color: side.accent,
                          ),
                        ),
                        Text(g.skills, style: side.body(size: 11)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumeSection(
            visible: data.summary.trim().isNotEmpty,
            title: 'About Me',
            style: main,
            child: Text(data.summary, style: main.body(size: 12.5)),
          ),
          ResumeSection(
            visible: data.filledExperience.isNotEmpty,
            title: 'Work Experience',
            style: main,
            child: Column(
              children: [
                for (final e in data.filledExperience) ExpBlock(e, main),
              ],
            ),
          ),
          ResumeSection(
            visible: data.filledProjects.isNotEmpty,
            title: 'Projects',
            style: main,
            child: Column(
              children: [
                for (final pr in data.filledProjects) ProjBlock(pr, main),
              ],
            ),
          ),
          ResumeSection(
            visible: data.filledEducation.isNotEmpty,
            title: 'Education',
            style: main,
            child: Column(
              children: [
                for (final ed in data.filledEducation) EduBlock(ed, main),
              ],
            ),
          ),
          TailSections(data, main),
        ],
      ),
    );

    return Container(
      color: main.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _splitBreakpoint) {
            // Narrow phones: stack the sidebar above the main column.
            return Column(children: [sidebar, body]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 210, child: sidebar),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Bold Accent — dark bg, bold yellow rule underline, heavy weight name
// ---------------------------------------------------------------------------
class BoldAccentTemplate extends StatelessWidget {
  const BoldAccentTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: const Color(0xFF111111),
      accent: const Color(0xFFF59E0B),
      ink: const Color(0xFFF2F2F2),
      inkSoft: const Color(0xFFA3A3A3),
    );
    return Container(
      color: style.background,
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumePhoto(data, borderColor: style.accent),
          Text(
            data.name.toUpperCase(),
            style: style.heading(size: 30, weight: FontWeight.w900,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(width: 80, height: 6, color: style.accent),
          if (data.jobTitle.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                data.jobTitle,
                style: style.body(
                  size: 14,
                  weight: FontWeight.w700,
                  color: style.accent,
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
}

// ---------------------------------------------------------------------------
// 6. Teal Elegant — centred header, soft teal rule, serif feel
// ---------------------------------------------------------------------------
class TealElegantTemplate extends StatelessWidget {
  const TealElegantTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: const Color(0xFFFAFAFA),
      accent: const Color(0xFF0D9488),
      ink: const Color(0xFF26323A),
      inkSoft: const Color(0xFF64748B),
      serifHeadings: true,
    );
    return Container(
      color: style.background,
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ResumePhoto(data, borderColor: style.accent),
                Text(
                  data.name,
                  textAlign: TextAlign.center,
                  style: style.heading(size: 28, weight: FontWeight.w700),
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
                        color: style.accent,
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
                  color: style.accent.withValues(alpha: 0.6),
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
}

// ---------------------------------------------------------------------------
// 7. Two Column — purple header band, balanced 2-column content grid
// ---------------------------------------------------------------------------
class TwoColumnTemplate extends StatelessWidget {
  const TwoColumnTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: Colors.white,
      accent: const Color(0xFF7C3AED),
      ink: const Color(0xFF1F2230),
      inkSoft: const Color(0xFF6B7280),
    );

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResumeSection(
          visible: data.summary.trim().isNotEmpty,
          title: 'Summary',
          style: style,
          child: Text(data.summary, style: style.body(size: 12.5)),
        ),
        ResumeSection(
          visible: data.filledExperience.isNotEmpty,
          title: 'Work Experience',
          style: style,
          child: Column(
            children: [
              for (final e in data.filledExperience) ExpBlock(e, style),
            ],
          ),
        ),
        ResumeSection(
          visible: data.filledProjects.isNotEmpty,
          title: 'Projects',
          style: style,
          child: Column(
            children: [
              for (final pr in data.filledProjects) ProjBlock(pr, style),
            ],
          ),
        ),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResumeSection(
          visible: data.filledExpertise.isNotEmpty,
          title: 'Expertise',
          style: style,
          child: ChipsWrap(data.filledExpertise, style),
        ),
        ResumeSection(
          visible: data.filledTechSkills.isNotEmpty,
          title: 'Technical Skills',
          style: style,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final g in data.filledTechSkills)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.category,
                        style: style.body(
                          size: 11.5,
                          weight: FontWeight.w700,
                          color: style.accent,
                        ),
                      ),
                      Text(g.skills, style: style.body(size: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ResumeSection(
          visible: data.filledEducation.isNotEmpty,
          title: 'Education',
          style: style,
          child: Column(
            children: [
              for (final ed in data.filledEducation) EduBlock(ed, style),
            ],
          ),
        ),
        TailSections(data, style),
      ],
    );

    return Container(
      color: style.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF7C3AED),
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
                      color: const Color(0xFFDDD6FE),
                    ),
                  ),
                if (data.hasContact)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ContactWrap(
                      data,
                      TemplateStyle(
                        background: const Color(0xFF7C3AED),
                        accent: const Color(0xFFDDD6FE),
                        ink: Colors.white,
                        inkSoft: Colors.white,
                      ),
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 4, 26, 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < _splitBreakpoint) {
                  return Column(children: [left, right]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: left),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: right),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Tech Mono — monospace font, code-style const object header
// ---------------------------------------------------------------------------
class TechMonoTemplate extends StatelessWidget {
  const TechMonoTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: const Color(0xFF0F172A),
      accent: const Color(0xFF22D3EE),
      ink: const Color(0xFFE2E8F0),
      inkSoft: const Color(0xFF94A3B8),
      mono: true,
    );

    TextSpan code(String text, Color color, {FontWeight? weight}) => TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            color: color,
            fontWeight: weight ?? FontWeight.w400,
            height: 1.6,
            letterSpacing: 0.4,
          ),
        );

    const kw = Color(0xFFF472B6); // keyword pink
    const str = Color(0xFFA5F3A5); // string green

    return Container(
      color: style.background,
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumePhoto(data, borderColor: style.accent),
          // const resume = { name: '…', role: '…' };
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: style.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Text.rich(
              TextSpan(children: [
                code('const ', kw),
                code('resume', style.accent, weight: FontWeight.w700),
                code(' = {\n', style.ink),
                code('  name: ', style.inkSoft),
                code("'${data.name}'", str),
                code(',\n', style.ink),
                if (data.jobTitle.trim().isNotEmpty) ...[
                  code('  role: ', style.inkSoft),
                  code("'${data.jobTitle}'", str),
                  code(',\n', style.ink),
                ],
                if (data.tagline.trim().isNotEmpty) ...[
                  code('  tagline: ', style.inkSoft),
                  code("'${data.tagline}'", str),
                  code(',\n', style.ink),
                ],
                code('};', style.ink),
              ]),
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
}

// ---------------------------------------------------------------------------
// 9. Executive — centred serif name, diamond rule dividers, brown ink
// ---------------------------------------------------------------------------
class ExecutiveTemplate extends StatelessWidget {
  const ExecutiveTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: const Color(0xFFFFF8F0),
      accent: const Color(0xFF92400E),
      ink: const Color(0xFF3F2A14),
      inkSoft: const Color(0xFF8A6F52),
      serifHeadings: true,
      diamondRule: true,
    );
    return Container(
      color: style.background,
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ResumePhoto(data, borderColor: style.accent),
                Text(
                  data.name,
                  textAlign: TextAlign.center,
                  style: style.heading(size: 30, weight: FontWeight.w700),
                ),
                if (data.jobTitle.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      data.jobTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: style.body(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: style.accent,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 1,
                      color: style.accent.withValues(alpha: 0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.diamond_rounded,
                          size: 10, color: style.accent),
                    ),
                    Container(
                      width: 60,
                      height: 1,
                      color: style.accent.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                if (data.tagline.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
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
}

// ---------------------------------------------------------------------------
// 10. Gradient Header — purple→pink banner, pill-style contact tags
// ---------------------------------------------------------------------------
class GradientTemplate extends StatelessWidget {
  const GradientTemplate({super.key, required this.data});
  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    final style = TemplateStyle(
      background: Colors.white,
      accent: const Color(0xFF7C3AED),
      ink: const Color(0xFF1F2230),
      inkSoft: const Color(0xFF6B7280),
    );
    return Container(
      color: style.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResumePhoto(data, borderColor: Colors.white),
                Text(
                  data.name,
                  style: style.heading(size: 28, color: Colors.white),
                ),
                if (data.jobTitle.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      data.jobTitle,
                      style: style.body(
                        size: 13.5,
                        weight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
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
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (kind, value) in data.contactItems)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(contactIcon(kind),
                                    size: 11, color: Colors.white),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    style: style.body(
                                      size: 10.5,
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 4, 26, 32),
            child: StandardBody(data, style),
          ),
        ],
      ),
    );
  }
}
