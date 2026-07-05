import 'package:flutter/material.dart';
import 'package:template/global/base/base_stateful_widget.dart';
import 'package:get/get.dart';
import 'package:template/features/resume/presentation/template_picker_page.dart'
    show templateGridColumns;
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/theme/text_style.dart';
import 'package:template/global/widgets/template_card.dart';
import 'package:template/features/biodata/domain/biodata_data_model.dart';

/// Grid of 50 marriage biodata templates + sample loader.
/// [initial] carries data auto-filled from an imported PDF/DOCX.
class BiodataPickerPage extends BaseStatefulWidget {
  const BiodataPickerPage({super.key, this.initial});

  final BiodataData? initial;

  @override
  State<BiodataPickerPage> createState() => _BiodataPickerPageState();
}

class _BiodataPickerPageState extends BaseState<BiodataPickerPage> {
  late final BiodataData _data = widget.initial ?? BiodataData();

  void _loadSample() {
    final sample = BiodataData.sample()..templateId = _data.templateId;
    Get.toNamed(RoutersConst.biodataPreview, arguments: sample);
  }

  void _startForm() {
    Get.toNamed(RoutersConst.biodataForm, arguments: _data);
  }

  @override
  Widget initBuild(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = templateGridColumns(width);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biodata Templates'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _loadSample,
              icon: const Icon(Icons.bolt_rounded, size: 20),
              label: const Text('Load Sample'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    'Choose a biodata style',
                    style: AppTextStyle.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    '${AppTheme.biodataTemplates.length} designs — switch any '
                    'time without losing your data.',
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: AppTheme.biodataTemplates.length,
                    itemBuilder: (context, i) {
                      final t = AppTheme.biodataTemplates[i];
                      return TemplateCard(
                        info: t,
                        selected: t.id == _data.templateId,
                        onTap: () => setState(() => _data.templateId = t.id),
                      );
                    },
                  ),
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
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.formMaxWidth),
              child: ElevatedButton.icon(
                onPressed: _startForm,
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Fill In The Details'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
