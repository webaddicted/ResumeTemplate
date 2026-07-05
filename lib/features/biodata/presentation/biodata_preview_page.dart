import 'package:flutter/material.dart';
import 'package:template/global/base/base_stateful_widget.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/utils/biodata_pdf_generator.dart';
import 'package:template/global/widgets/templates/biodata_templates.dart';
import 'package:template/features/biodata/domain/biodata_data_model.dart';

/// Live biodata preview + template switcher + export.
class BiodataPreviewPage extends BaseStatefulWidget {
  const BiodataPreviewPage({super.key, required this.data});

  final BiodataData data;

  @override
  State<BiodataPreviewPage> createState() => _BiodataPreviewPageState();
}

class _BiodataPreviewPageState extends BaseState<BiodataPreviewPage> {
  bool _switcherVisible = false;
  bool _exporting = false;

  BiodataData get d => widget.data;

  Future<void> _exportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Export Biodata',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _printPdf();
                },
                icon: const Icon(Icons.print_rounded),
                label: const Text('Print / Save as PDF'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _sharePdf();
                },
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Share PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printPdf() async {
    setState(() => _exporting = true);
    try {
      await Printing.layoutPdf(
        name: BiodataPdfGenerator.fileName(d),
        onLayout: (_) => BiodataPdfGenerator.generate(d),
      );
    } catch (e) {
      _showError('Could not open print dialog: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _sharePdf() async {
    setState(() => _exporting = true);
    try {
      final bytes = await BiodataPdfGenerator.generate(d);
      await Printing.sharePdf(
        bytes: bytes,
        filename: BiodataPdfGenerator.fileName(d),
      );
    } catch (e) {
      _showError('Could not share PDF: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _edit() {
    Get.toNamed(RoutersConst.biodataForm, arguments: d);
  }

  @override
  Widget initBuild(BuildContext context) {
    final templateName = AppTheme.biodataTemplateById(d.templateId).name;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preview'),
            Text(
              templateName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Switch template',
            onPressed: () =>
                setState(() => _switcherVisible = !_switcherVisible),
            icon: Icon(
              Icons.brush_rounded,
              color: _switcherVisible ? AppTheme.accent : null,
            ),
          ),
          IconButton(
            tooltip: 'Edit details',
            onPressed: _edit,
            icon: const Icon(Icons.edit_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: _switcherVisible
                  ? SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        itemCount: AppTheme.biodataTemplates.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final t = AppTheme.biodataTemplates[i];
                          final selected = t.id == d.templateId;
                          return Semantics(
                            button: true,
                            selected: selected,
                            label: 'Switch to ${t.name} template',
                            child: InkWell(
                              onTap: () =>
                                  setState(() => d.templateId = t.id),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.accent
                                        : AppTheme.outline,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: t.background,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppTheme.outline),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: t.accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (selected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 15,
                                            color: AppTheme.accent,
                                          ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      t.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppTheme.resumeMaxWidth,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: buildBiodataTemplate(d.templateId, d),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exporting ? null : _exportSheet,
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        icon: _exporting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.picture_as_pdf_rounded),
        label: Text(_exporting ? 'Generating…' : 'Export PDF'),
      ),
    );
  }
}
