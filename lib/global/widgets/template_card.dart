import 'package:flutter/material.dart';

import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/theme/text_style.dart';

/// One template card with a miniature layout preview — shared by the
/// resume and biodata template pickers.
class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.info,
    required this.selected,
    required this.onTap,
  });

  final TemplateInfo info;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Template ${info.name}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.accent : AppTheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: MiniPreview(info: info),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        info.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.titleMedium,
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppTheme.accent,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Abstract miniature of a template's layout, driven by [TemplateInfo.hint]:
/// header shape, accent placement, and a few "text" bars.
class MiniPreview extends StatelessWidget {
  const MiniPreview({super.key, required this.info});

  final TemplateInfo info;

  @override
  Widget build(BuildContext context) {
    final soft = info.isDark
        ? Colors.white.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.22);
    final softer = info.isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.10);

    Widget bar(double w, {Color? color, double h = 5}) => Container(
          width: w,
          height: h,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: color ?? softer,
            borderRadius: BorderRadius.circular(2),
          ),
        );

    final hasBand =
        info.hint == TemplateHint.band || info.hint == TemplateHint.gradient;
    final centered = info.hint == TemplateHint.centered ||
        info.hint == TemplateHint.frame;

    Widget inner = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (info.hint == TemplateHint.leftBorder)
          Container(width: 4, color: info.accent),
        if (info.hint == TemplateHint.sidebar)
          Container(
            width: 34,
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: info.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                bar(20, color: Colors.white.withValues(alpha: 0.3), h: 3),
                bar(16, color: Colors.white.withValues(alpha: 0.18), h: 3),
              ],
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBand)
                Container(
                  height: 26,
                  decoration: BoxDecoration(
                    color: info.secondaryAccent == null ? info.accent : null,
                    gradient: info.secondaryAccent != null
                        ? LinearGradient(
                            colors: [info.accent, info.secondaryAccent!],
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(7),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: bar(34,
                        color: Colors.white.withValues(alpha: 0.8), h: 5),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: centered
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    if (!hasBand) ...[
                      if (info.hint == TemplateHint.code)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: info.accent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: bar(38, color: info.accent, h: 4),
                        )
                      else
                        bar(42, color: soft, h: 7),
                      bar(28, color: info.accent, h: 4),
                      const SizedBox(height: 4),
                    ],
                    bar(double.infinity),
                    bar(double.infinity),
                    bar(52),
                    const SizedBox(height: 5),
                    bar(30, color: info.accent, h: 4),
                    bar(double.infinity),
                    bar(44),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (info.hint == TemplateHint.frame) {
      inner = Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: info.accent, width: 1.6),
          ),
          child: inner,
        ),
      );
    }

    return Container(color: info.background, child: inner);
  }
}
