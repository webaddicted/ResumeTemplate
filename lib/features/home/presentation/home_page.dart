import 'package:flutter/material.dart';
import 'package:template/global/base/base_stateful_widget.dart';
import 'package:get/get.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/utils/file_import.dart';

enum DocumentType { resume, biodata }

/// Entry screen — pick the document type (resume / marriage biodata) and
/// optionally attach an existing PDF or DOCX to auto-fill the form.
class HomePage extends BaseStatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomePage> {
  DocumentType _type = DocumentType.resume;
  ImportedFile? _file;
  bool _picking = false;

  Future<void> _pickFile() async {
    setState(() => _picking = true);
    try {
      final file = await FileImport.pick();
      if (file != null) setState(() => _file = file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file picker: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _continue() {
    var toast = '';
    if (_type == DocumentType.resume) {
      final rawText = _file == null ? '' : FileImport.extractText(_file!);
      var data = FileImport.parseResume(rawText)..sourceText = rawText;
      final filled = FileImport.resumeFilledCount(data);
      if (_file != null) {
        // An uploaded resume goes through ATS analysis first (new V2 flow).
        toast = filled > 0
            ? 'Analysed ${_file!.name} — review your ATS score, then improve with AI.'
            : 'Could not read much from ${_file!.name} — starting a fresh resume.';
        Get.toNamed(RoutersConst.resumeAtsAnalysis, arguments: data);
      } else {
        Get.toNamed(RoutersConst.resumeTemplatePicker, arguments: data);
      }
    } else {
      var data = FileImport.parseBiodata(
          _file == null ? '' : FileImport.extractText(_file!));
      final filled = FileImport.biodataFilledCount(data);
      if (_file != null) {
        toast = filled > 0
            ? 'Auto-filled $filled field${filled == 1 ? '' : 's'} from ${_file!.name} — review them in the form.'
            : 'Could not read details from ${_file!.name} — starting blank.';
      }
      Get.toNamed(RoutersConst.biodataTemplatePicker, arguments: data);
    }

    if (toast.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(toast), duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget initBuild(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final sideBySide = width >= 700;

    final cards = [
      _ModeCard(
        icon: Icons.description_rounded,
        title: 'Resume',
        subtitle: '${AppTheme.templates.length} professional templates',
        accent: AppTheme.accent,
        selected: _type == DocumentType.resume,
        onTap: () => setState(() => _type = DocumentType.resume),
      ),
      _ModeCard(
        icon: Icons.favorite_rounded,
        title: 'Marriage Biodata',
        subtitle: '${AppTheme.biodataTemplates.length} elegant designs',
        accent: const Color(0xFFC2185B),
        selected: _type == DocumentType.biodata,
        onTap: () => setState(() => _type = DocumentType.biodata),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ResumeKit Pro')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What would you like to create?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your data stays on this device — PDFs are generated '
                    'offline.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (sideBySide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: cards[1]),
                      ],
                    )
                  else ...[
                    cards[0],
                    const SizedBox(height: 16),
                    cards[1],
                  ],
                  const SizedBox(height: 28),
                  const Text(
                    'Auto-fill from an existing file',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Optional — attach a PDF or DOCX and we will pre-fill the '
                    'form from it. You can review everything before export.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _filePickerTile(),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _continue,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _type == DocumentType.resume
                          ? 'Continue — Pick a Resume Template'
                          : 'Continue — Pick a Biodata Style',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed(RoutersConst.categories),
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text(
                      'More — Invitations, Cards, Events & Profiles',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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

  Widget _filePickerTile() {
    final file = _file;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: file != null ? AppTheme.accent : AppTheme.outline,
        ),
      ),
      child: file == null
          ? InkWell(
              onTap: _picking ? null : _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _picking
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.upload_file_rounded,
                              color: AppTheme.accent,
                            ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose PDF or DOCX',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'No file? Skip this — you can type everything in.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 8, 12),
              child: Row(
                children: [
                  Icon(
                    file.isPdf
                        ? Icons.picture_as_pdf_rounded
                        : Icons.article_rounded,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'Will be used to auto-fill the form',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Remove attached file',
                    child: IconButton(
                      tooltip: 'Remove file',
                      onPressed: () => setState(() => _file = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? accent : AppTheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? accent : AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
