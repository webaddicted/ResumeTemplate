import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:template/features/biodata/domain/biodata_data_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';
import 'package:template/global/utils/biodata_pdf_generator.dart';
import 'package:template/global/utils/pdf_generator.dart';
import 'package:template/global/widgets/templates/all_templates.dart';
import 'package:template/global/widgets/templates/biodata_templates.dart';

/// Small valid PNG generated with the same decoder family the pdf
/// package uses.
final Uint8List kTinyPng =
    Uint8List.fromList(img.encodePng(img.Image(width: 4, height: 4)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host(Widget child) => MaterialApp(
        home: SingleChildScrollView(
          child: SizedBox(width: 680, child: child),
        ),
      );

  // A representative subset covering every header treatment.
  const resumeIds = [
    'modern_dark', // edge + photo above name
    'corporate', // band
    'creative_side', // sidebar avatar swap
    'teal_elegant', // centered
    'tech_mono', // code header
    'gen_sapphire_band',
    'gen_emerald_classic',
    'gen_violet_flow',
  ];

  for (final id in resumeIds) {
    testWidgets('resume $id renders photo without errors', (tester) async {
      final data = ResumeData.sample()
        ..templateId = id
        ..photo = kTinyPng;
      await tester.pumpWidget(host(buildTemplate(id, data)));
      expect(tester.takeException(), isNull);
      expect(find.byType(SizedBox), findsWidgets);
    });
  }

  testWidgets('biodata medallion shows photo instead of initials',
      (tester) async {
    final data = BiodataData.sample()..photo = kTinyPng;
    await tester
        .pumpWidget(host(buildBiodataTemplate(data.templateId, data)));
    expect(tester.takeException(), isNull);
    // Initials are replaced by the photo.
    expect(find.text(data.initials), findsNothing);
  });

  testWidgets('creative_side falls back to initials without photo',
      (tester) async {
    final data = ResumeData.sample()..templateId = 'creative_side';
    await tester.pumpWidget(host(buildTemplate('creative_side', data)));
    expect(find.text('DS'), findsOneWidget);
  });

  test('resume PDF embeds photo', () async {
    final withPhoto = ResumeData.sample()..photo = kTinyPng;
    final without = ResumeData.sample();
    final a = await PdfGenerator.generate(withPhoto);
    final b = await PdfGenerator.generate(without);
    expect(a.length, greaterThan(b.length));
  });

  test('biodata PDF embeds photo', () async {
    final withPhoto = BiodataData.sample()..photo = kTinyPng;
    final without = BiodataData.sample();
    final a = await BiodataPdfGenerator.generate(withPhoto);
    final b = await BiodataPdfGenerator.generate(without);
    expect(a.length, greaterThan(b.length));
  });

  test('undecodable photo bytes are skipped, export still succeeds', () async {
    final data = ResumeData.sample()
      ..photo = Uint8List.fromList([1, 2, 3, 4]);
    final bytes = await PdfGenerator.generate(data);
    expect(bytes.length, greaterThan(1000));
  });
}
