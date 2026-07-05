import 'package:flutter/material.dart';
import 'package:template/global/base/base_stateful_widget.dart';
import 'package:get/get.dart';
import 'package:template/global/constant/card_categories.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/widgets/form_widgets.dart';
import 'package:template/features/cards/domain/card_data_model.dart';

/// Generic single-page form that renders the fields declared by the card's
/// category (plus an optional photo picker).
class CardFormPage extends BaseStatefulWidget {
  const CardFormPage({super.key, required this.data});

  final CardData data;

  @override
  State<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends BaseState<CardFormPage> {
  late final DocCategory _cat = CardCategories.byId(widget.data.categoryId);

  CardData get d => widget.data;

  @override
  Widget initBuild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cat.label),
        actions: [
          TextButton(
            onPressed: () =>
                Get.toNamed(RoutersConst.cardPreview, arguments: d),
            child: const Text('Preview'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.formMaxWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                const SectionHeader(
                  title: 'Details',
                  subtitle: 'Empty fields are hidden on the card.',
                ),
                if (_cat.usesPhoto)
                  PhotoPickerField(
                    photo: d.photo,
                    onChanged: (bytes) => setState(() => d.photo = bytes),
                  ),
                for (final f in _cat.fields)
                  FormField2(
                    label: f.label,
                    value: d.get(f.key),
                    hint: f.hint,
                    maxLines: f.multiline ? 4 : 1,
                    onChanged: (v) => d.set(f.key, v),
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
            child: ElevatedButton(
              onPressed: () =>
                  Get.toNamed(RoutersConst.cardPreview, arguments: d),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              child: const Text('Preview'),
            ),
          ),
        ),
      ),
    );
  }
}
