import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:template/core/ats/ats_analyzer_service.dart';
import 'package:template/core/jd/jd_analyzer_service.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/ats_widgets.dart';
import 'package:template/model/ats_report.dart';
import 'package:template/model/jd_analysis.dart';
import 'package:template/model/resume_data.dart';

/// Step 3 (NEW) — ATS analysis of an uploaded resume.
/// Shows the score, the prioritised issue list, and a CTA to improve with AI.
class AtsAnalysisPage extends StatefulWidget {
  const AtsAnalysisPage({super.key, required this.data});

  final ResumeData data;

  @override
  State<AtsAnalysisPage> createState() => _AtsAnalysisPageState();
}

class _AtsAnalysisPageState extends State<AtsAnalysisPage> {
  static const _ats = AtsAnalyzerService();
  static const _jdEngine = JdAnalyzerService();

  late AtsReport _report = _analyze();
  JdAnalysis? _jd;
  String _jdText = '';

  ResumeData get d => widget.data;

  AtsReport _analyze() =>
      _ats.analyze(d, rawText: d.sourceText, jd: _jd);

  void _reanalyzeWithJd(String jdText) {
    setState(() {
      _jdText = jdText;
      _jd = jdText.trim().isEmpty ? null : _jdEngine.analyze(jdText, d);
      _report = _analyze();
    });
  }

  void _openOptimizer() {
    Get.toNamed(
      RoutersConst.resumeJdOptimizer,
      arguments: {'data': d, 'jdText': _jdText},
    );
  }

  void _improveWithAi() {
    // Carry the resume (and any JD) forward into template selection → the
    // AI-assisted form.
    Get.toNamed(RoutersConst.resumeTemplatePicker, arguments: d);
  }

  @override
  Widget build(BuildContext context) {
    final issues = _report.sortedIssues;
    return Scaffold(
      appBar: AppBar(title: const Text('ATS Resume Analysis')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                AtsScoreCard(report: _report),
                const SizedBox(height: 18),
                AtsCategoryBars(report: _report),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Issues Found',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${issues.length}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (issues.isEmpty)
                  const _EmptyIssues()
                else
                  for (final issue in issues)
                    AtsIssueTile(issue: issue),
                const SizedBox(height: 18),
                _JdSection(
                  onAnalyze: _reanalyzeWithJd,
                  onOptimize: _openOptimizer,
                  jd: _jd,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: _improveWithAi,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Improve Resume with AI'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(
                      RoutersConst.resumeTemplatePicker,
                      arguments: d,
                    ),
                    child: const Text('Skip — continue to templates'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyIssues extends StatelessWidget {
  const _EmptyIssues();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.success),
          SizedBox(width: 10),
          Expanded(
            child: Text('No major ATS issues found. Great job!'),
          ),
        ],
      ),
    );
  }
}

/// Optional "paste a job description" panel that re-scores keyword coverage.
class _JdSection extends StatefulWidget {
  const _JdSection({
    required this.onAnalyze,
    required this.onOptimize,
    required this.jd,
  });

  final ValueChanged<String> onAnalyze;
  final VoidCallback onOptimize;
  final JdAnalysis? jd;

  @override
  State<_JdSection> createState() => _JdSectionState();
}

class _JdSectionState extends State<_JdSection> {
  final _controller = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.work_outline_rounded,
                color: AppTheme.accent),
            title: const Text(
              'Target a Job Description',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Optional — score keyword match for a role'),
            trailing: Icon(
              _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Paste the job description here…',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onAnalyze(_controller.text),
                          icon: const Icon(Icons.analytics_outlined, size: 18),
                          label: const Text('Analyze Match'),
                        ),
                      ),
                      if (widget.jd != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onOptimize,
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: const Text('Optimize'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.jd != null) ...[
                    const SizedBox(height: 12),
                    JdMatchSummary(jd: widget.jd!),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
