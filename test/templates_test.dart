import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template/features/biodata/domain/biodata_data_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/utils/biodata_pdf_generator.dart';
import 'package:template/global/utils/pdf_generator.dart';
import 'package:template/global/widgets/templates/all_templates.dart';
import 'package:template/global/widgets/templates/biodata_templates.dart';

void main() {
  // PDF generators load bundled Nunito fonts via rootBundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host(Widget child, double width) => MaterialApp(
        home: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      );

  for (final t in AppTheme.templates) {
    testWidgets('${t.id} renders with sample data (phone + wide)',
        (tester) async {
      final data = ResumeData.sample()..templateId = t.id;

      // Narrow phone width (360 dp).
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(buildTemplate(t.id, data), 360));
      expect(tester.takeException(), isNull);
      // Name may be uppercased (bold_yellow) or in rich text (tech_mono).
      expect(
        find.textContaining(
          RegExp('Deepak Sharma', caseSensitive: false),
          findRichText: true,
        ),
        findsWidgets,
      );

      // Wide layout (680 dp resume width).
      tester.view.physicalSize = const Size(1280 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      await tester.pumpWidget(host(buildTemplate(t.id, data), 680));
      expect(tester.takeException(), isNull);
    });
  }

  for (final t in AppTheme.biodataTemplates) {
    testWidgets('biodata ${t.id} renders with sample data (phone + wide)',
        (tester) async {
      final data = BiodataData.sample()..templateId = t.id;

      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(buildBiodataTemplate(t.id, data), 360));
      expect(tester.takeException(), isNull);
      expect(find.text('Ananya Sharma'), findsOneWidget);

      tester.view.physicalSize = const Size(1280 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      await tester.pumpWidget(host(buildBiodataTemplate(t.id, data), 680));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('biodata hides empty sections', (tester) async {
    final data = BiodataData(name: 'Only Name');
    await tester
        .pumpWidget(host(buildBiodataTemplate(data.templateId, data), 680));
    expect(find.text('Only Name'), findsOneWidget);
    expect(find.text('FAMILY DETAILS'), findsNothing);
    expect(find.text('HOROSCOPE DETAILS'), findsNothing);
  });

  testWidgets('templates hide empty sections', (tester) async {
    final data = ResumeData(name: 'Only Name');
    await tester.pumpWidget(host(buildTemplate('modern_dark', data), 680));
    expect(find.text('Only Name'), findsOneWidget);
    expect(find.text('WORK EXPERIENCE'), findsNothing);
    expect(find.text('PATENTS'), findsNothing);
  });

  test('PDF generates non-empty bytes for every template', () async {
    for (final t in AppTheme.templates) {
      final data = ResumeData.sample()..templateId = t.id;
      final bytes = await PdfGenerator.generate(data);
      expect(bytes.length, greaterThan(1000), reason: t.id);
    }
  });

  test('Biodata PDF generates non-empty bytes for every template', () async {
    for (final t in AppTheme.biodataTemplates) {
      final data = BiodataData.sample()..templateId = t.id;
      final bytes = await BiodataPdfGenerator.generate(data);
      expect(bytes.length, greaterThan(1000), reason: t.id);
    }
  });

  test('Biodata PDF filename derived from name', () {
    expect(
      BiodataPdfGenerator.fileName(BiodataData.sample()),
      'Ananya_Sharma_biodata.pdf',
    );
  });

  test('PDF filename derived from name', () {
    expect(
      PdfGenerator.fileName(ResumeData.sample()),
      'Deepak_Sharma_resume.pdf',
    );
    expect(PdfGenerator.fileName(ResumeData()), 'resume_resume.pdf');
  });
}
