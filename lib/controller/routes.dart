import 'package:get/get.dart';
import 'package:template/features/ats_analysis/presentation/ats_analysis_page.dart';
import 'package:template/features/biodata/presentation/biodata_form_page.dart';
import 'package:template/features/biodata/presentation/biodata_picker_page.dart';
import 'package:template/features/biodata/presentation/biodata_preview_page.dart';
import 'package:template/features/cards/presentation/card_form_page.dart';
import 'package:template/features/cards/presentation/card_picker_page.dart';
import 'package:template/features/cards/presentation/card_preview_page.dart';
import 'package:template/features/cards/presentation/categories_page.dart';
import 'package:template/features/final_validation/presentation/final_ats_validation_page.dart';
import 'package:template/features/home/presentation/home_page.dart';
import 'package:template/features/jd_optimizer/presentation/jd_optimizer_page.dart';
import 'package:template/features/resume/presentation/form_steps_page.dart';
import 'package:template/features/resume/presentation/resume_preview_page.dart';
import 'package:template/features/resume/presentation/template_picker_page.dart';
import 'package:template/global/constant/card_categories.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/widgets/templates/card_template_specs.dart';
import 'package:template/model/biodata_data.dart';
import 'package:template/model/card_data.dart';
import 'package:template/model/resume_data.dart';

List<GetPage> routes() => [
      GetPage(name: RoutersConst.home, page: () => const HomePage()),
      GetPage(
        name: RoutersConst.resumeAtsAnalysis,
        page: () => AtsAnalysisPage(
          data: Get.arguments is ResumeData
              ? Get.arguments as ResumeData
              : ResumeData(),
        ),
      ),
      GetPage(
        name: RoutersConst.resumeJdOptimizer,
        page: () {
          final args = Get.arguments;
          final data = (args is Map && args['data'] is ResumeData)
              ? args['data'] as ResumeData
              : (args is ResumeData ? args : ResumeData());
          final jdText =
              (args is Map && args['jdText'] is String) ? args['jdText'] as String : '';
          return JdOptimizerPage(data: data, initialJd: jdText);
        },
      ),
      GetPage(
        name: RoutersConst.resumeFinalAts,
        page: () => FinalAtsValidationPage(
          data: Get.arguments is ResumeData
              ? Get.arguments as ResumeData
              : ResumeData(),
        ),
      ),
      GetPage(
        name: RoutersConst.resumeTemplatePicker,
        page: () => TemplatePickerPage(
          initial: Get.arguments is ResumeData ? Get.arguments as ResumeData : null,
        ),
      ),
      GetPage(
        name: RoutersConst.resumeForm,
        page: () {
          final args = Get.arguments;
          if (args is ResumeData) {
            return FormStepsPage(data: args);
          }
          return FormStepsPage(data: ResumeData());
        },
      ),
      GetPage(
        name: RoutersConst.resumePreview,
        page: () {
          final args = Get.arguments;
          if (args is ResumeData) {
            return ResumePreviewPage(data: args);
          }
          return ResumePreviewPage(data: ResumeData());
        },
      ),
      GetPage(
        name: RoutersConst.biodataTemplatePicker,
        page: () => BiodataPickerPage(
          initial: Get.arguments is BiodataData ? Get.arguments as BiodataData : null,
        ),
      ),
      GetPage(
        name: RoutersConst.biodataForm,
        page: () {
          final args = Get.arguments;
          if (args is BiodataData) {
            return BiodataFormPage(data: args);
          }
          return BiodataFormPage(data: BiodataData());
        },
      ),
      GetPage(
        name: RoutersConst.biodataPreview,
        page: () {
          final args = Get.arguments;
          if (args is BiodataData) {
            return BiodataPreviewPage(data: args);
          }
          return BiodataPreviewPage(data: BiodataData());
        },
      ),
      // ---- Generic card categories ----
      GetPage(
        name: RoutersConst.categories,
        page: () => const CategoriesPage(),
      ),
      GetPage(
        name: RoutersConst.cardPicker,
        page: () {
          final id = Get.arguments is String
              ? Get.arguments as String
              : CardCategories.all.first.id;
          return CardPickerPage(categoryId: id);
        },
      ),
      GetPage(
        name: RoutersConst.cardForm,
        page: () => CardFormPage(data: _cardArg()),
      ),
      GetPage(
        name: RoutersConst.cardPreview,
        page: () => CardPreviewPage(data: _cardArg()),
      ),
    ];

/// Resolves a [CardData] argument, falling back to a fresh first-category card.
CardData _cardArg() {
  final args = Get.arguments;
  if (args is CardData) return args;
  final cat = CardCategories.all.first;
  return cat.newData(CardCatalogue.defaultTemplateId(cat.id));
}
