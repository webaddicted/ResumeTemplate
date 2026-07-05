import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:template/global/theme/app_theme.dart';
import 'package:template/model/resume_data.dart';

/// Embeds the bundled Nunito family so PDFs render the same typography as
/// the app and support glyphs Helvetica lacks (– ₹ …). Loaded once.
Future<pw.ThemeData> pdfTheme() async {
  _pdfTheme ??= pw.ThemeData.withFont(
    base: pw.Font.ttf(
        await rootBundle.load('assets/fonts/Nunito-Regular.ttf')),
    bold: pw.Font.ttf(await rootBundle.load('assets/fonts/Nunito-Bold.ttf')),
    italic: pw.Font.ttf(
        await rootBundle.load('assets/fonts/Nunito-Regular.ttf')),
    boldItalic:
        pw.Font.ttf(await rootBundle.load('assets/fonts/Nunito-Bold.ttf')),
  );
  return _pdfTheme!;
}

pw.ThemeData? _pdfTheme;

/// The pdf package throws while painting if the photo bytes can't be
/// decoded — validate up front and skip the photo instead of failing the
/// whole export.
Uint8List? decodablePhoto(Uint8List? bytes) {
  if (bytes == null) return null;
  try {
    return img.decodeImage(bytes) == null ? null : bytes;
  } catch (_) {
    return null;
  }
}

/// Generates the resume PDF entirely on-device (EX-05).
///
/// Layout mirrors all filled sections in a readable A4 layout (EX-06),
/// tinted with the selected template's accent colour.
class PdfGenerator {
  PdfGenerator._();

  static String fileName(ResumeData data) {
    final base = data.name.trim().isEmpty
        ? 'resume'
        : data.name.trim().replaceAll(RegExp(r'\s+'), '_');
    return '${base}_resume.pdf';
  }

  static Future<Uint8List> generate(ResumeData data) async {
    final photo = decodablePhoto(data.photo);
    final info = AppTheme.templateById(data.templateId);
    final accent = PdfColor.fromInt(info.accent.toARGB32());
    const ink = PdfColors.grey900;
    const inkSoft = PdfColors.grey600;

    final doc = pw.Document(title: '${data.name} — Resume');

    pw.Widget sectionTitle(String title) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 14, bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
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
              pw.SizedBox(height: 3),
              pw.Container(width: 32, height: 1.6, color: accent),
            ],
          ),
        );

    pw.Widget bullet(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 3,
                height: 3,
                margin: const pw.EdgeInsets.only(top: 4.5, right: 6),
                decoration: pw.BoxDecoration(
                  color: accent,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  text,
                  style: const pw.TextStyle(
                    fontSize: 9.5,
                    color: ink,
                    lineSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );

    pw.Widget kv(String k, String v) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 80,
                child: pw.Text(
                  k,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: accent,
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

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 40),
        theme: await pdfTheme(),
        build: (context) => [
          // ---- Header (photo on the right when provided) ----
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      data.name,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    if (data.jobTitle.trim().isNotEmpty)
                      pw.Text(
                        data.jobTitle,
                        style: pw.TextStyle(
                          fontSize: 11.5,
                          fontWeight: pw.FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    if (data.tagline.trim().isNotEmpty)
                      pw.Text(
                        data.tagline,
                        style:
                            const pw.TextStyle(fontSize: 9.5, color: inkSoft),
                      ),
                    if (data.hasContact)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 6),
                        child: pw.Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            for (final (_, value) in data.contactItems)
                              pw.Text(
                                value,
                                style: const pw.TextStyle(
                                    fontSize: 9, color: inkSoft),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (photo != null)
                pw.Container(
                  width: 58,
                  height: 58,
                  margin: const pw.EdgeInsets.only(left: 12),
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: accent, width: 1.2),
                    image: pw.DecorationImage(
                      image: pw.MemoryImage(photo),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            height: 1,
            color: PdfColors.grey300,
          ),

          // ---- Summary ----
          if (data.summary.trim().isNotEmpty) ...[
            sectionTitle('Summary'),
            pw.Text(
              data.summary,
              style: const pw.TextStyle(
                fontSize: 9.5,
                color: ink,
                lineSpacing: 1.6,
              ),
            ),
          ],

          // ---- Expertise ----
          if (data.filledExpertise.isNotEmpty) ...[
            sectionTitle('Expertise'),
            pw.Wrap(
              spacing: 5,
              runSpacing: 4,
              children: [
                for (final e in data.filledExpertise)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2.5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: accent, width: 0.6),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Text(
                      e,
                      style: const pw.TextStyle(fontSize: 8.5, color: ink),
                    ),
                  ),
              ],
            ),
          ],

          // ---- Experience ----
          if (data.filledExperience.isNotEmpty) ...[
            sectionTitle('Work Experience'),
            for (final e in data.filledExperience)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            e.role,
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: ink,
                            ),
                          ),
                        ),
                        pw.Text(
                          [e.startDate, e.endDate]
                              .where((s) => s.trim().isNotEmpty)
                              .join(' – '),
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      [e.company, e.location]
                          .where((s) => s.trim().isNotEmpty)
                          .join(' · '),
                      style: const pw.TextStyle(fontSize: 9, color: inkSoft),
                    ),
                    pw.SizedBox(height: 3),
                    for (final b in e.bullets.where((b) => b.trim().isNotEmpty))
                      bullet(b),
                  ],
                ),
              ),
          ],

          // ---- Technical skills ----
          if (data.filledTechSkills.isNotEmpty) ...[
            sectionTitle('Technical Skills'),
            for (final g in data.filledTechSkills) kv(g.category, g.skills),
          ],

          // ---- Projects ----
          if (data.filledProjects.isNotEmpty) ...[
            sectionTitle('Projects'),
            for (final p in data.filledProjects)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          p.name,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: ink,
                          ),
                        ),
                        if (p.role.trim().isNotEmpty) ...[
                          pw.SizedBox(width: 6),
                          pw.Text(
                            p.role,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (p.tech.trim().isNotEmpty)
                      pw.Text(
                        p.tech,
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          color: inkSoft,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    if (p.description.trim().isNotEmpty)
                      pw.Text(
                        p.description,
                        style: const pw.TextStyle(
                          fontSize: 9.5,
                          color: ink,
                          lineSpacing: 1.5,
                        ),
                      ),
                    if (p.link.trim().isNotEmpty)
                      pw.Text(
                        p.link,
                        style: pw.TextStyle(fontSize: 8.5, color: accent),
                      ),
                  ],
                ),
              ),
          ],

          // ---- Education ----
          if (data.filledEducation.isNotEmpty) ...[
            sectionTitle('Education'),
            for (final ed in data.filledEducation)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            ed.degree,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: ink,
                            ),
                          ),
                        ),
                        pw.Text(
                          [ed.startYear, ed.endYear]
                              .where((s) => s.trim().isNotEmpty)
                              .join(' – '),
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      [
                        ed.institution,
                        if (ed.grade.trim().isNotEmpty) ed.grade,
                      ].where((s) => s.trim().isNotEmpty).join(' · '),
                      style: const pw.TextStyle(fontSize: 9, color: inkSoft),
                    ),
                  ],
                ),
              ),
          ],

          // ---- Personal info ----
          if (!data.personal.isEmpty) ...[
            sectionTitle('Personal Information'),
            if (data.personal.address.trim().isNotEmpty)
              kv('Address', data.personal.address),
            if (data.personal.dob.trim().isNotEmpty)
              kv('Date of Birth', data.personal.dob),
            if (data.personal.languages.trim().isNotEmpty)
              kv('Languages', data.personal.languages),
            if (data.personal.hobbies.trim().isNotEmpty)
              kv('Hobbies', data.personal.hobbies),
          ],

          // ---- Certificates ----
          if (data.filledCertificates.isNotEmpty) ...[
            sectionTitle('Certificates & Recognition'),
            for (final c in data.filledCertificates)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(
                  [
                    c.title,
                    [
                      if (c.issuer.trim().isNotEmpty) c.issuer,
                      if (c.year.trim().isNotEmpty) c.year,
                    ].join(', '),
                  ].where((s) => s.trim().isNotEmpty).join('  —  '),
                  style: const pw.TextStyle(fontSize: 9.5, color: ink),
                ),
              ),
          ],

          // ---- Patents ----
          if (data.filledPatents.isNotEmpty) ...[
            sectionTitle('Patents'),
            for (final p in data.filledPatents)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(
                  [
                    p.title,
                    [
                      if (p.number.trim().isNotEmpty) p.number,
                      if (p.year.trim().isNotEmpty) p.year,
                    ].join(', '),
                  ].where((s) => s.trim().isNotEmpty).join('  —  '),
                  style: const pw.TextStyle(fontSize: 9.5, color: ink),
                ),
              ),
          ],
        ],
      ),
    );

    return doc.save();
  }
}
