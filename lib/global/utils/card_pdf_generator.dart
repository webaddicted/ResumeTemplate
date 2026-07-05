import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constant/card_categories.dart';
import '../widgets/templates/card_template_specs.dart';
import 'package:template/features/cards/domain/card_data_model.dart';
import 'pdf_generator.dart' show decodablePhoto, pdfTheme;

/// On-device PDF for any card (invitation / event pass / business / profile).
/// A clean, centered A4 layout tinted with the chosen template's accent —
/// consistent with the resume/biodata exporters.
class CardPdfGenerator {
  CardPdfGenerator._();

  static String fileName(CardData data) {
    final cat = CardCategories.byId(data.categoryId);
    final who = data.get('name1').isNotEmpty
        ? data.get('name1')
        : (data.get('event').isNotEmpty ? data.get('event') : cat.label);
    final base = who.trim().replaceAll(RegExp(r'\s+'), '_');
    return '${base}_${cat.id}.pdf';
  }

  static Future<Uint8List> generate(CardData data) async {
    final cat = CardCategories.byId(data.categoryId);
    final spec = CardCatalogue.byId(data.templateId);
    final accent = PdfColor.fromInt(spec.accent.toARGB32());
    final photo = decodablePhoto(data.photo);
    const ink = PdfColors.grey900;
    const inkSoft = PdfColors.grey700;

    final doc = pw.Document(title: cat.label);

    pw.Widget center(String text,
            {double size = 12,
            PdfColor color = ink,
            pw.FontWeight weight = pw.FontWeight.normal,
            pw.FontStyle? style}) =>
        pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
                fontSize: size, color: color, fontWeight: weight, fontStyle: style));

    final names = [data.get('name1'), data.get('name2')]
        .where((s) => s.isNotEmpty)
        .join('  &  ');

    // Which keys are shown in the structured "details" block.
    const layoutKeys = {
      'headline', 'name1', 'name2', 'host', 'subtitle', 'message',
      'program', 'interests', 'about', 'event',
    };

    final details = <pw.Widget>[];
    for (final f in cat.fields) {
      if (layoutKeys.contains(f.key)) continue;
      if (!data.has(f.key)) continue;
      details.add(pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 110,
              child: pw.Text(f.label,
                  style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: accent)),
            ),
            pw.Expanded(
                child: pw.Text(data.get(f.key),
                    style: const pw.TextStyle(fontSize: 10, color: ink))),
          ],
        ),
      ));
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: await pdfTheme(),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: accent, width: 1.5),
          ),
          margin: const pw.EdgeInsets.all(8),
          padding: const pw.EdgeInsets.all(28),
          child: pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (data.has('headline'))
                  center(data.get('headline').toUpperCase(),
                      size: 13, color: accent, weight: pw.FontWeight.bold),
                pw.SizedBox(height: 12),
                if (photo != null) ...[
                  pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      image: pw.DecorationImage(
                          image: pw.MemoryImage(photo), fit: pw.BoxFit.cover),
                      border: pw.Border.all(color: accent, width: 1.5),
                    ),
                  ),
                  pw.SizedBox(height: 12),
                ],
                if (data.has('event'))
                  center(data.get('event'),
                      size: 20, weight: pw.FontWeight.bold),
                if (data.has('host')) center(data.get('host'), color: inkSoft),
                if (names.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  center(names, size: 24, weight: pw.FontWeight.bold),
                ],
                if (data.has('subtitle'))
                  center(data.get('subtitle'),
                      size: 12, color: inkSoft, style: pw.FontStyle.italic),
                pw.SizedBox(height: 12),
                pw.Container(width: 90, height: 1.5, color: accent),
                pw.SizedBox(height: 12),
                if (data.has('about'))
                  center(data.get('about'), size: 11, color: ink),
                if (data.has('message'))
                  center(data.get('message'), size: 11, color: ink),
                if (data.has('program')) ...[
                  pw.SizedBox(height: 10),
                  for (final l in data.get('program').split('\n'))
                    if (l.trim().isNotEmpty)
                      center(l.trim(), size: 11, color: ink),
                ],
                pw.SizedBox(height: 14),
                if (details.isNotEmpty)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: details,
                  ),
                if (data.has('interests')) ...[
                  pw.SizedBox(height: 10),
                  pw.Wrap(
                    alignment: pw.WrapAlignment.center,
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      for (final tag in data
                          .get('interests')
                          .split(RegExp(r'[,\n]'))
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty))
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2.5),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: accent, width: 0.6),
                            borderRadius:
                                const pw.BorderRadius.all(pw.Radius.circular(8)),
                          ),
                          child: pw.Text(tag,
                              style:
                                  const pw.TextStyle(fontSize: 8.5, color: ink)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return doc.save();
  }
}
