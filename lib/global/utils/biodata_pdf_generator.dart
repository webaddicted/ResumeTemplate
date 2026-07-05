import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/utils/pdf_generator.dart'
    show decodablePhoto, pdfTheme;
import 'package:template/model/biodata_data.dart';

/// On-device A4 PDF for the marriage biodata, tinted with the selected
/// template's accent colour.
class BiodataPdfGenerator {
  BiodataPdfGenerator._();

  static String fileName(BiodataData data) {
    final base = data.name.trim().isEmpty
        ? 'biodata'
        : data.name.trim().replaceAll(RegExp(r'\s+'), '_');
    return '${base}_biodata.pdf';
  }

  static Future<Uint8List> generate(BiodataData data) async {
    final photo = decodablePhoto(data.photo);
    final info = AppTheme.biodataTemplateById(data.templateId);
    final accent = PdfColor.fromInt(info.accent.toARGB32());
    const ink = PdfColors.grey900;
    const inkSoft = PdfColors.grey600;

    final doc = pw.Document(title: '${data.name} — Biodata');

    pw.Widget sectionTitle(String title) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 14, bottom: 6),
          child: pw.Row(
            children: [
              pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  height: 0.8,
                  color: PdfColor.fromInt(info.accent.toARGB32()),
                ),
              ),
            ],
          ),
        );

    pw.Widget kv(String k, String v) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2.5),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 120,
                child: pw.Text(
                  k,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: inkSoft,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  v,
                  style: const pw.TextStyle(fontSize: 9.5, color: ink),
                ),
              ),
            ],
          ),
        );

    List<pw.Widget> section(String title, List<(String, String)> rows) => [
          if (rows.isNotEmpty) ...[
            sectionTitle(title),
            for (final (k, v) in rows) kv(k, v),
          ],
        ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 40),
        theme: await pdfTheme(),
        build: (context) => [
          // ---- Header ----
          if (data.invocation.trim().isNotEmpty)
            pw.Center(
              child: pw.Text(
                data.invocation,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: accent,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          pw.SizedBox(height: 6),
          if (photo != null)
            pw.Center(
              child: pw.Container(
                width: 72,
                height: 72,
                margin: const pw.EdgeInsets.only(bottom: 8),
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: accent, width: 1.2),
                  image: pw.DecorationImage(
                    image: pw.MemoryImage(photo),
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),
            ),
          pw.Center(
            child: pw.Text(
              data.name,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: ink,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Container(width: 110, height: 1.2, color: accent),
          ),
          ...section('Personal Details', data.personalRows),
          ...section('Horoscope Details', data.horoscopeRows),
          ...section('Education & Career', data.careerRows),
          ...section('Family Details', data.familyRows),
          if (data.expectations.trim().isNotEmpty) ...[
            sectionTitle('Partner Expectations'),
            pw.Text(
              data.expectations,
              style: const pw.TextStyle(
                fontSize: 9.5,
                color: ink,
                lineSpacing: 1.6,
              ),
            ),
          ],
          ...section('Contact Details', data.contactRows),
        ],
      ),
    );

    return doc.save();
  }
}
