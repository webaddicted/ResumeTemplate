import 'package:flutter/material.dart';

import '../../model/ats_report.dart';
import '../../model/jd_analysis.dart';
import '../theme/app_theme.dart';

/// Big circular ATS score dial, coloured by band (red/orange/green).
class AtsScoreCard extends StatelessWidget {
  const AtsScoreCard({super.key, required this.report, this.caption});

  final AtsReport report;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final score = report.score;
    final color = AppTheme.scoreColor(score);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 9,
                    backgroundColor: AppTheme.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ATS Score',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  report.band,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  caption ??
                      (report.isDownloadable
                          ? 'Ready to download — meets the 90+ ATS target.'
                          : 'Aim for 90+ to maximise interview callbacks.'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
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

/// Per-category weighted score breakdown bars.
class AtsCategoryBars extends StatelessWidget {
  const AtsCategoryBars({super.key, required this.report});

  final AtsReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final c in report.categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.score / 100,
                      minHeight: 8,
                      backgroundColor: AppTheme.surfaceAlt,
                      valueColor: AlwaysStoppedAnimation(
                        AppTheme.scoreColor(c.score.round()),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '${c.score.round()} /${c.weight}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A single ATS issue with severity chip and suggested fix.
class AtsIssueTile extends StatelessWidget {
  const AtsIssueTile({super.key, required this.issue});

  final AtsIssue issue;

  Color get _color => switch (issue.severity) {
        AtsSeverity.critical => AppTheme.danger,
        AtsSeverity.warning => AppTheme.warning,
        AtsSeverity.minor => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 18, color: _color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  issue.severity.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 15, color: AppTheme.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  issue.fix,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact JD keyword-match summary (matched vs missing).
class JdMatchSummary extends StatelessWidget {
  const JdMatchSummary({super.key, required this.jd});

  final JdAnalysis jd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Job match: ${jd.matchScore}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.scoreColor(jd.matchScore),
              ),
            ),
          ],
        ),
        if (jd.missingKeywords.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Missing keywords',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in jd.missingKeywords.take(12))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    k,
                    style: const TextStyle(fontSize: 11, color: AppTheme.danger),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
