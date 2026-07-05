import 'package:flutter/material.dart';

import 'package:template/global/theme/app_theme.dart';
import 'package:template/model/resume_data.dart';

/// Visual configuration consumed by the shared blocks below.
/// Each of the 10 templates builds one of these, so the content blocks
/// (experience, projects, education, …) are written once.
class TemplateStyle {
  TemplateStyle({
    required this.background,
    required this.accent,
    required this.ink,
    required this.inkSoft,
    this.divider,
    this.mono = false,
    this.serifHeadings = false,
    this.uppercaseSectionTitles = true,
    this.sectionTitleBoxed = false,
    this.sectionRuleFull = false,
    this.diamondRule = false,
  });

  final Color background;
  final Color accent;

  /// Primary body ink.
  final Color ink;

  /// Secondary / muted ink.
  final Color inkSoft;

  final Color? divider;
  final bool mono;
  final bool serifHeadings;
  final bool uppercaseSectionTitles;
  final bool sectionTitleBoxed;
  final bool sectionRuleFull;
  final bool diamondRule;

  // All text uses the bundled Nunito family (fully offline). The `mono`
  // and `serifHeadings` flags are expressed through letter spacing and
  // weight instead of separate font files.
  TextStyle body({
    double size = 12.5,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color ?? ink,
      height: height ?? 1.45,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing ?? (mono ? 0.4 : null),
    );
  }

  TextStyle heading({
    double size = 26,
    FontWeight weight = FontWeight.w800,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: size,
      // Serif-styled templates get the heaviest Nunito cut for contrast.
      fontWeight: serifHeadings ? FontWeight.w900 : weight,
      color: color ?? ink,
      height: 1.15,
      letterSpacing: letterSpacing ?? (mono ? 0.4 : null),
    );
  }
}

/// Circular profile photo for template headers — renders nothing when the
/// user hasn't added one (photo is optional).
class ResumePhoto extends StatelessWidget {
  const ResumePhoto(
    this.data, {
    super.key,
    this.size = 64,
    this.borderColor,
    this.padding = const EdgeInsets.only(bottom: 10),
  });

  final ResumeData data;
  final double size;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final photo = data.photo;
    if (photo == null) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 2),
          image: DecorationImage(
            image: MemoryImage(photo),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

IconData contactIcon(String kind) => switch (kind) {
      'phone' => Icons.phone_rounded,
      'email' => Icons.email_rounded,
      'location' => Icons.location_on_rounded,
      'web' => Icons.language_rounded,
      'linkedin' => Icons.business_center_rounded,
      'github' => Icons.code_rounded,
      _ => Icons.link_rounded,
    };

/// "EXPERIENCE" / boxed / diamond-ruled section label.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, this.style, {super.key});

  final String title;
  final TemplateStyle style;

  @override
  Widget build(BuildContext context) {
    final label = style.uppercaseSectionTitles ? title.toUpperCase() : title;
    final text = Text(
      style.mono ? '// $label' : label,
      style: style
          .heading(size: 13.5, weight: FontWeight.w800, color: style.accent)
          .copyWith(letterSpacing: style.uppercaseSectionTitles ? 1.4 : 0.2),
    );

    Widget child;
    if (style.sectionTitleBoxed) {
      child = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: style.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: style.accent.withValues(alpha: 0.4)),
        ),
        child: text,
      );
    } else if (style.diamondRule) {
      child = Row(
        children: [
          Flexible(child: text),
          const SizedBox(width: 10),
          Icon(Icons.diamond_rounded, size: 8, color: style.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 1,
              color: style.accent.withValues(alpha: 0.35),
            ),
          ),
        ],
      );
    } else if (style.sectionRuleFull) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text,
          const SizedBox(height: 5),
          Container(height: 1.4, color: style.accent.withValues(alpha: 0.45)),
        ],
      );
    } else {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text,
          const SizedBox(height: 5),
          Container(width: 36, height: 2.4, color: style.accent),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: child,
    );
  }
}

/// Wraps a section so it disappears entirely when empty (PR-07).
class ResumeSection extends StatelessWidget {
  const ResumeSection({
    super.key,
    required this.visible,
    required this.title,
    required this.style,
    required this.child,
  });

  final bool visible;
  final String title;
  final TemplateStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [SectionTitle(title, style), child],
    );
  }
}

/// One work-experience entry.
class ExpBlock extends StatelessWidget {
  const ExpBlock(this.exp, this.style, {super.key});

  final Experience exp;
  final TemplateStyle style;

  @override
  Widget build(BuildContext context) {
    final dates = [exp.startDate, exp.endDate]
        .where((s) => s.trim().isNotEmpty)
        .join(' – ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exp.role,
                  style: style.body(size: 13.5, weight: FontWeight.w700),
                ),
              ),
              if (dates.isNotEmpty)
                Text(
                  dates,
                  style: style.body(
                    size: 11,
                    weight: FontWeight.w600,
                    color: style.accent,
                  ),
                ),
            ],
          ),
          Text(
            [exp.company, exp.location]
                .where((s) => s.trim().isNotEmpty)
                .join(' · '),
            style: style.body(
              size: 12,
              weight: FontWeight.w600,
              color: style.inkSoft,
            ),
          ),
          const SizedBox(height: 5),
          for (final b in exp.bullets.where((b) => b.trim().isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.5, right: 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: style.accent,
                        shape: style.mono
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(child: Text(b, style: style.body())),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One project entry.
class ProjBlock extends StatelessWidget {
  const ProjBlock(this.proj, this.style, {super.key});

  final Project proj;
  final TemplateStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                proj.name,
                style: style.body(size: 13, weight: FontWeight.w700),
              ),
              if (proj.role.trim().isNotEmpty)
                Text(
                  proj.role,
                  style: style.body(
                    size: 11,
                    weight: FontWeight.w600,
                    color: style.accent,
                  ),
                ),
            ],
          ),
          if (proj.tech.trim().isNotEmpty)
            Text(
              proj.tech,
              style: style.body(
                size: 11,
                color: style.inkSoft,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (proj.description.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(proj.description, style: style.body()),
            ),
          if (proj.link.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link_rounded, size: 12, color: style.accent),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      proj.link,
                      style: style.body(size: 11, color: style.accent),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One education entry.
class EduBlock extends StatelessWidget {
  const EduBlock(this.edu, this.style, {super.key});

  final Education edu;
  final TemplateStyle style;

  @override
  Widget build(BuildContext context) {
    final years = [edu.startYear, edu.endYear]
        .where((s) => s.trim().isNotEmpty)
        .join(' – ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  edu.degree,
                  style: style.body(size: 13, weight: FontWeight.w700),
                ),
              ),
              if (years.isNotEmpty)
                Text(
                  years,
                  style: style.body(
                    size: 11,
                    weight: FontWeight.w600,
                    color: style.accent,
                  ),
                ),
            ],
          ),
          Text(
            [edu.institution, if (edu.grade.trim().isNotEmpty) edu.grade]
                .where((s) => s.trim().isNotEmpty)
                .join(' · '),
            style: style.body(size: 12, color: style.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// Tech-skills table (category → comma separated values).
class SkillsTable extends StatelessWidget {
  const SkillsTable(this.groups, this.style, {super.key});

  final List<TechSkillGroup> groups;
  final TemplateStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final g in groups)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    g.category,
                    style: style.body(
                      size: 11.5,
                      weight: FontWeight.w700,
                      color: style.accent,
                    ),
                  ),
                ),
                Expanded(child: Text(g.skills, style: style.body(size: 12))),
              ],
            ),
          ),
      ],
    );
  }
}

/// Pills used for expertise items.
class ChipsWrap extends StatelessWidget {
  const ChipsWrap(this.items, this.style, {super.key, this.filled = true});

  final List<String> items;
  final TemplateStyle style;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: filled
                  ? style.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.accent.withValues(alpha: 0.45)),
            ),
            child: Text(
              item,
              style: style.body(size: 11, weight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

/// Contact line: wraps icon+value pairs.
class ContactWrap extends StatelessWidget {
  const ContactWrap(
    this.data,
    this.style, {
    super.key,
    this.color,
    this.vertical = false,
  });

  final ResumeData data;
  final TemplateStyle style;
  final Color? color;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final c = color ?? style.inkSoft;
    final items = [
      for (final (kind, value) in data.contactItems)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(contactIcon(kind), size: 12, color: style.accent),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                value,
                style: style.body(size: 11, color: c),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
    ];
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 7), child: item),
        ],
      );
    }
    return Wrap(spacing: 14, runSpacing: 7, children: items);
  }
}

/// Personal info, certificates & patents — the "More Info" tail sections.
class TailSections extends StatelessWidget {
  const TailSections(this.data, this.style, {super.key});

  final ResumeData data;
  final TemplateStyle style;

  @override
  Widget build(BuildContext context) {
    final p = data.personal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResumeSection(
          visible: !p.isEmpty,
          title: 'Personal Information',
          style: style,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.address.trim().isNotEmpty)
                _kv('Address', p.address),
              if (p.dob.trim().isNotEmpty) _kv('Date of Birth', p.dob),
              if (p.languages.trim().isNotEmpty) _kv('Languages', p.languages),
              if (p.hobbies.trim().isNotEmpty) _kv('Hobbies', p.hobbies),
            ],
          ),
        ),
        ResumeSection(
          visible: data.filledCertificates.isNotEmpty,
          title: 'Certificates & Recognition',
          style: style,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in data.filledCertificates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text.rich(
                    TextSpan(
                      text: c.title,
                      style: style.body(size: 12, weight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: [
                            if (c.issuer.trim().isNotEmpty) c.issuer,
                            if (c.year.trim().isNotEmpty) c.year,
                          ].isEmpty
                              ? ''
                              : '  —  ${[
                                  if (c.issuer.trim().isNotEmpty) c.issuer,
                                  if (c.year.trim().isNotEmpty) c.year,
                                ].join(', ')}',
                          style: style.body(size: 11.5, color: style.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        ResumeSection(
          visible: data.filledPatents.isNotEmpty,
          title: 'Patents',
          style: style,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final pt in data.filledPatents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text.rich(
                    TextSpan(
                      text: pt.title,
                      style: style.body(size: 12, weight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: [
                            if (pt.number.trim().isNotEmpty) pt.number,
                            if (pt.year.trim().isNotEmpty) pt.year,
                          ].isEmpty
                              ? ''
                              : '  —  ${[
                                  if (pt.number.trim().isNotEmpty) pt.number,
                                  if (pt.year.trim().isNotEmpty) pt.year,
                                ].join(', ')}',
                          style: style.body(size: 11.5, color: style.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(
                k,
                style: style.body(
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: style.accent,
                ),
              ),
            ),
            Expanded(child: Text(v, style: style.body(size: 12))),
          ],
        ),
      );
}

/// The standard single-column body shared by most templates:
/// Summary → Expertise → Experience → Skills → Projects → Education → Tail.
class StandardBody extends StatelessWidget {
  const StandardBody(this.data, this.style, {super.key});

  final ResumeData data;
  final TemplateStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResumeSection(
          visible: data.summary.trim().isNotEmpty,
          title: 'Summary',
          style: style,
          child: Text(data.summary, style: style.body(size: 12.5)),
        ),
        ResumeSection(
          visible: data.filledExpertise.isNotEmpty,
          title: 'Expertise',
          style: style,
          child: ChipsWrap(data.filledExpertise, style),
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
          visible: data.filledTechSkills.isNotEmpty,
          title: 'Technical Skills',
          style: style,
          child: SkillsTable(data.filledTechSkills, style),
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
  }
}
