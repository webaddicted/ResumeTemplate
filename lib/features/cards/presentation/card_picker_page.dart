import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:template/global/constant/card_categories.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/template_card.dart';
import 'package:template/global/widgets/templates/card_template_specs.dart';

/// Grid of 50 designs for one card category + sample loader.
class CardPickerPage extends StatefulWidget {
  const CardPickerPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CardPickerPage> createState() => _CardPickerPageState();
}

class _CardPickerPageState extends State<CardPickerPage> {
  late final DocCategory _cat = CardCategories.byId(widget.categoryId);
  late String _templateId = CardCatalogue.defaultTemplateId(widget.categoryId);

  void _loadSample() {
    Get.toNamed(RoutersConst.cardPreview,
        arguments: _cat.sampleData(_templateId));
  }

  void _start() {
    Get.toNamed(RoutersConst.cardForm, arguments: _cat.newData(_templateId));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1200
        ? 5
        : width >= 900
            ? 4
            : width >= 600
                ? 3
                : 2;
    final infos = CardCatalogue.infosFor(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_cat.label),
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    '${infos.length} designs — switch any time without losing '
                    'your details.',
                    style: const TextStyle(
                        fontSize: 13.5, color: AppTheme.textSecondary),
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
                    itemCount: infos.length,
                    itemBuilder: (context, i) {
                      final t = infos[i];
                      return TemplateCard(
                        info: t,
                        selected: t.id == _templateId,
                        onTap: () => setState(() => _templateId = t.id),
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
              constraints: const BoxConstraints(maxWidth: AppTheme.formMaxWidth),
              child: ElevatedButton.icon(
                onPressed: _start,
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
