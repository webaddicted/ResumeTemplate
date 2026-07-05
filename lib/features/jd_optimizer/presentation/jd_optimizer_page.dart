import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:template/core/jd/jd_analyzer_service.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/ats_widgets.dart';
import 'package:template/model/jd_analysis.dart';
import 'package:template/model/resume_data.dart';

/// Feature 3 — Job Description based optimization.
///
/// Paste a JD → see required skills / keywords / gap → Accept / Edit / Reject
/// concrete additions that get applied to the resume.
class JdOptimizerPage extends StatefulWidget {
  const JdOptimizerPage({super.key, required this.data, this.initialJd = ''});

  final ResumeData data;
  final String initialJd;

  @override
  State<JdOptimizerPage> createState() => _JdOptimizerPageState();
}

class _JdOptimizerPageState extends State<JdOptimizerPage> {
  static const _engine = JdAnalyzerService();

  late final TextEditingController _jdController =
      TextEditingController(text: widget.initialJd);
  JdAnalysis? _jd;

  /// Per-suggestion resolution: index → 'accepted' | 'rejected' (pending if absent).
  final Map<int, String> _decisions = {};

  ResumeData get d => widget.data;

  @override
  void initState() {
    super.initState();
    if (widget.initialJd.trim().isNotEmpty) _analyze();
  }

  @override
  void dispose() {
    _jdController.dispose();
    super.dispose();
  }

  void _analyze() {
    setState(() {
      _jd = _engine.analyze(_jdController.text, d);
      _decisions.clear();
    });
  }

  void _accept(int i, JdSuggestion s) {
    _applyToResume(s);
    setState(() => _decisions[i] = 'accepted');
  }

  Future<void> _edit(int i, JdSuggestion s) async {
    final controller = TextEditingController(text: s.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Edit suggestion'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Edit the addition…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      s.text = result.trim();
      _applyToResume(s);
      setState(() => _decisions[i] = 'accepted');
    }
  }

  void _reject(int i) => setState(() => _decisions[i] = 'rejected');

  void _applyToResume(JdSuggestion s) {
    switch (s.section) {
      case 'Skills':
        // Merge into the first skills group (or create one).
        if (d.techSkills.isEmpty) {
          d.techSkills.add(TechSkillGroup(category: 'Skills', skills: s.text));
        } else {
          final g = d.techSkills.first;
          g.skills = g.skills.trim().isEmpty ? s.text : '${g.skills}, ${s.text}';
        }
      case 'Summary':
        d.summary = d.summary.trim().isEmpty
            ? s.text
            : '${d.summary.trim()} ${s.text}';
      case 'Experience':
      default:
        if (d.experience.isEmpty) {
          d.experience.add(Experience(bullets: [s.text]));
        } else {
          d.experience.first.bullets.add(s.text);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jd = _jd;
    return Scaffold(
      appBar: AppBar(title: const Text('Job Description Optimizer')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                const Text(
                  'Paste the job description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'We extract the required skills and keywords, then show what '
                  'your resume is missing.',
                  style:
                      TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jdController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'e.g. We are looking for a Flutter developer '
                        'with GraphQL, CI/CD, and unit testing experience…',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _analyze,
                  icon: const Icon(Icons.analytics_rounded),
                  label: const Text('Analyze'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                if (jd != null) ...[
                  const SizedBox(height: 20),
                  JdMatchSummary(jd: jd),
                  if (jd.suggestions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Suggested additions',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Accept only what is genuinely true for you.',
                      style: TextStyle(
                          fontSize: 12.5, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < jd.suggestions.length; i++)
                      _SuggestionCard(
                        suggestion: jd.suggestions[i],
                        decision: _decisions[i],
                        onAccept: () => _accept(i, jd.suggestions[i]),
                        onEdit: () => _edit(i, jd.suggestions[i]),
                        onReject: () => _reject(i),
                      ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'No gaps found — your resume already covers this job\'s '
                        'keywords. 🎉',
                      ),
                    ),
                  ],
                ],
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
            child: ElevatedButton(
              onPressed: () => Get.back(result: d),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Done — apply changes'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.decision,
    required this.onAccept,
    required this.onEdit,
    required this.onReject,
  });

  final JdSuggestion suggestion;
  final String? decision;
  final VoidCallback onAccept;
  final VoidCallback onEdit;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final accepted = decision == 'accepted';
    final rejected = decision == 'rejected';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accepted
              ? AppTheme.success
              : rejected
                  ? AppTheme.outline
                  : AppTheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  suggestion.section,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
              ),
              const Spacer(),
              if (accepted)
                const Icon(Icons.check_circle_rounded,
                    size: 18, color: AppTheme.success),
              if (rejected)
                const Icon(Icons.cancel_rounded,
                    size: 18, color: AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              decoration: rejected ? TextDecoration.lineThrough : null,
              color: rejected ? AppTheme.textSecondary : AppTheme.textPrimary,
            ),
          ),
          if (decision == null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      backgroundColor: AppTheme.success,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style:
                        OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
