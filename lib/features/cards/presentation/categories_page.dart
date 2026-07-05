import 'package:flutter/material.dart';
import 'package:template/global/base/base_stateless_widget.dart';
import 'package:get/get.dart';
import 'package:template/global/constant/card_categories.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';

/// Browse all card document types, grouped by section (Invitations,
/// Business, Events, Profiles). Tapping one opens its template picker.
class CategoriesPage extends BaseStatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget initBuild(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1000
        ? 4
        : width >= 680
            ? 3
            : 2;
    final grouped = CardCategories.grouped;

    return Scaffold(
      appBar: AppBar(title: const Text('More Document Types')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, i) {
                      final cat = entry.value[i];
                      return _CategoryTile(category: cat);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final DocCategory category;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.label,
      child: InkWell(
        onTap: () =>
            Get.toNamed(RoutersConst.cardPicker, arguments: category.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.accent, size: 22),
              ),
              Text(
                category.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
