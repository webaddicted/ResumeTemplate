import 'package:flutter/material.dart';
import 'package:template/global/base/base_stateful_widget.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:template/features/ats_analysis/data/ats_analyzer_service.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/utils/pdf_generator.dart';
import 'package:template/global/widgets/ats_widgets.dart';
import 'package:template/features/ats_analysis/domain/ats_report_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';

/// Step 7 — Final ATS validation before download.
///
/// Recalculates the score, lists the improvements achieved, and gates the
/// download behind the 90+ target.
class FinalAtsValidationPage extends BaseStatefulWidget {
  const FinalAtsValidationPage({super.key, required this.data});

  final ResumeData data;

  @override
  State<FinalAtsValidationPage> createState() => _FinalAtsValidationPageState();
}

class _FinalAtsValidationPageState extends BaseState<FinalAtsValidationPage> {
  static const _ats = AtsAnalyzerService();

  late AtsReport _report = _ats.analyze(widget.data);
  bool _exporting = false;

  ResumeData get d => widget.data;

  /// Positive checks that currently pass — shown as "improvements applied".
  List<String> get _applied {
    final r = d;
    return [
      if (r.summary.trim().isNotEmpty) 'Professional summary present',
      if (r.filledTechSkills.isNotEmpty || r.filledExpertise.isNotEmpty)
        'Relevant skills & keywords added',
      if (_hasQuantified(r)) 'Measurable achievements included',
      if (r.filledEducation.isNotEmpty) 'Education section complete',
      if (r.filledCertificates.isNotEmpty) 'Certifications listed',
      if (r.email.trim().isNotEmpty && r.phone.trim().isNotEmpty)
        'Complete contact details',
    ];
  }

  bool _hasQuantified(ResumeData r) => r.filledExperience
      .any((e) => e.bullets.any((b) => RegExp(r'\d').hasMatch(b)));

  void _recalculate() => setState(() => _report = _ats.analyze(d));

  Future<void> _download() async {
    setState(() => _exporting = true);
    try {
      await Printing.layoutPdf(
        name: PdfGenerator.fileName(d),
        onLayout: (_) => PdfGenerator.generate(d),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open print dialog: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _share() async {
    setState(() => _exporting = true);
    try {
      final bytes = await PdfGenerator.generate(d);
      await Printing.sharePdf(bytes: bytes, filename: PdfGenerator.fileName(d));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget initBuild(BuildContext context) {
    final passed = _report.isDownloadable;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final ATS Validation'),
        actions: [
          IconButton(
            tooltip: 'Recalculate',
            onPressed: _recalculate,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                AtsScoreCard(
                  report: _report,
                  caption: passed
                      ? 'Target met — your resume is ready to download.'
                      : 'Below the 90+ target. Improve a few more items.',
                ),
                const SizedBox(height: 18),
                AtsCategoryBars(report: _report),
                const SizedBox(height: 22),
                const Text(
                  'Improvements Applied',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (final item in _applied)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: AppTheme.success),
                        const SizedBox(width: 10),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                if (!passed) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Still to fix',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  for (final issue in _report.sortedIssues.take(4))
                    AtsIssueTile(issue: issue),
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: passed
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _exporting ? null : _share,
                            icon: const Icon(Icons.ios_share_rounded),
                            label: const Text('Share'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _exporting ? null : _download,
                            icon: _exporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.download_rounded),
                            label: Text(
                                _exporting ? 'Generating…' : 'Download Resume'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_rounded,
                                  size: 18, color: AppTheme.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Download unlocks at ATS ≥ '
                                  '${AtsReport.passThreshold}. '
                                  'You are at ${_report.score}%.',
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed(
                            RoutersConst.resumeForm,
                            arguments: d,
                          ),
                          icon: const Icon(Icons.auto_fix_high_rounded),
                          label: const Text('Improve More'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                          ),
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
