import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:template/model/biodata_data.dart';
import 'package:template/model/resume_data.dart';

/// A picked import file (PDF or DOCX) with its raw bytes.
class ImportedFile {
  const ImportedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  bool get isPdf => name.toLowerCase().endsWith('.pdf');
  bool get isDocx => name.toLowerCase().endsWith('.docx');
}

/// Best-effort auto-fill from an existing PDF / DOCX document.
/// Everything runs on-device; the file never leaves the phone/browser.
class FileImport {
  FileImport._();

  /// Opens the platform file picker (PDF / DOCX only). Returns null when
  /// the user cancels. `withData: true` so it works on web too.
  static Future<ImportedFile?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );
    final file = result?.files.firstOrNull;
    if (file == null || file.bytes == null) return null;
    return ImportedFile(name: file.name, bytes: file.bytes!);
  }

  /// Plain-text content of the file ('' when unreadable).
  static String extractText(ImportedFile file) {
    try {
      if (file.isPdf) return _extractPdfText(file.bytes);
      if (file.isDocx) return _extractDocxText(file.bytes);
    } catch (_) {
      // Corrupt / password-protected files: fall through to empty.
    }
    return '';
  }

  static String _extractPdfText(Uint8List bytes) {
    final doc = PdfDocument(inputBytes: bytes);
    try {
      // extractTextLines keeps word spacing reliable across embedded fonts
      // (extractText drops spaces for some of them).
      return PdfTextExtractor(doc)
          .extractTextLines()
          .map((l) => l.text)
          .join('\n');
    } finally {
      doc.dispose();
    }
  }

  /// DOCX is a zip; visible text lives in word/document.xml as
  /// `<w:t>` runs grouped into `</w:p>` paragraphs.
  static String _extractDocxText(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final entry = archive.findFile('word/document.xml');
    if (entry == null) return '';
    final xml = utf8.decode(entry.content as List<int>, allowMalformed: true);
    final buffer = StringBuffer();
    for (final paragraph in xml.split('</w:p>')) {
      final runs = RegExp(r'<w:t[^>]*>([^<]*)</w:t>')
          .allMatches(paragraph)
          .map((m) => _unescapeXml(m.group(1)!))
          .join();
      if (runs.trim().isNotEmpty) buffer.writeln(runs);
    }
    return buffer.toString();
  }

  static String _unescapeXml(String s) => s
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');

  // ---- Heuristic field extraction ----------------------------------------

  static final _emailRe =
      RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+', caseSensitive: false);
  static final _phoneRe = RegExp(r'\+?\d[\d\s\-()]{8,14}\d');
  static final _linkedinRe =
      RegExp(r'(?:www\.)?linkedin\.com/[^\s,;|]+', caseSensitive: false);
  static final _githubRe =
      RegExp(r'(?:www\.)?github\.com/[^\s,;|]+', caseSensitive: false);

  static List<String> _lines(String text) => text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  /// A plausible person-name line: short, mostly letters, no digits/@.
  static bool _looksLikeName(String line) =>
      line.length <= 40 &&
      !line.contains('@') &&
      !line.contains(RegExp(r'\d')) &&
      RegExp(r'^[A-Za-z .]+$').hasMatch(line) &&
      line.split(' ').length <= 5;

  /// Best-effort resume auto-fill: contact details are extracted reliably
  /// (regex); name/title/summary/skills use positional heuristics.
  static ResumeData parseResume(String text) {
    final data = ResumeData();
    if (text.trim().isEmpty) return data;
    final lines = _lines(text);

    data.email = _emailRe.firstMatch(text)?.group(0) ?? '';
    data.phone = _phoneRe.firstMatch(text)?.group(0)?.trim() ?? '';
    data.linkedin = _linkedinRe.firstMatch(text)?.group(0) ?? '';
    data.github = _githubRe.firstMatch(text)?.group(0) ?? '';

    // Name: first name-looking line near the top.
    for (final line in lines.take(6)) {
      if (_looksLikeName(line)) {
        data.name = line;
        // Job title: the next short line that isn't contact info.
        final idx = lines.indexOf(line);
        if (idx + 1 < lines.length) {
          final next = lines[idx + 1];
          if (next.length <= 60 &&
              !next.contains('@') &&
              !_phoneRe.hasMatch(next)) {
            data.jobTitle = next;
          }
        }
        break;
      }
    }

    // Summary: lines following a "summary" / "about" heading.
    data.summary = _sectionParagraph(
      lines,
      ['summary', 'professional summary', 'about', 'about me', 'profile'],
    );

    // Skills: comma-separated content after a "skills" heading.
    final skills = _sectionParagraph(
      lines,
      ['skills', 'technical skills', 'expertise', 'key skills'],
    );
    if (skills.isNotEmpty) {
      data.techSkills = [TechSkillGroup(category: 'Skills', skills: skills)];
    }
    return data;
  }

  /// Paragraph under the first matching heading, up to the next
  /// heading-looking line (max 4 lines).
  static String _sectionParagraph(List<String> lines, List<String> headings) {
    for (var i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase().replaceAll(':', '').trim();
      if (!headings.contains(lower)) continue;
      final collected = <String>[];
      for (var j = i + 1; j < lines.length && collected.length < 4; j++) {
        final line = lines[j];
        final isHeading = line.length < 32 &&
            (line == line.toUpperCase() ||
                RegExp(r'^[A-Z][a-z]+( [A-Z][a-z]+)?:?$').hasMatch(line));
        if (isHeading) break;
        collected.add(line);
      }
      return collected.join(' ').trim();
    }
    return '';
  }

  /// Biodata documents are usually label/value lines ("Height : 5'4\"") —
  /// far more structured than resumes, so this maps known labels directly.
  static BiodataData parseBiodata(String text) {
    final data = BiodataData();
    if (text.trim().isEmpty) return data;

    data.email = _emailRe.firstMatch(text)?.group(0) ?? '';
    data.phone = _phoneRe.firstMatch(text)?.group(0)?.trim() ?? '';

    final setters = <String, void Function(String)>{
      'name': (v) => data.name = v,
      'full name': (v) => data.name = v,
      'date of birth': (v) => data.dob = v,
      'dob': (v) => data.dob = v,
      'birth date': (v) => data.dob = v,
      'time of birth': (v) => data.timeOfBirth = v,
      'birth time': (v) => data.timeOfBirth = v,
      'place of birth': (v) => data.placeOfBirth = v,
      'birth place': (v) => data.placeOfBirth = v,
      'height': (v) => data.height = v,
      'complexion': (v) => data.complexion = v,
      'blood group': (v) => data.bloodGroup = v,
      'religion': (v) => data.religion = v,
      'caste': (v) => data.caste = v,
      'sub caste': (v) => data.caste = v,
      'gotra': (v) => data.gotra = v,
      'rashi': (v) => data.rashi = v,
      'nakshatra': (v) => data.nakshatra = v,
      'manglik': (v) => data.manglik = v,
      'marital status': (v) => data.maritalStatus = v,
      'diet': (v) => data.diet = v,
      'hobbies': (v) => data.hobbies = v,
      'education': (v) => data.education = v,
      'qualification': (v) => data.education = v,
      'occupation': (v) => data.occupation = v,
      'profession': (v) => data.occupation = v,
      'company': (v) => data.company = v,
      'organisation': (v) => data.company = v,
      'income': (v) => data.income = v,
      'annual income': (v) => data.income = v,
      'work location': (v) => data.workLocation = v,
      'father': (v) => data.fatherName = v,
      "father's name": (v) => data.fatherName = v,
      'father name': (v) => data.fatherName = v,
      "father's occupation": (v) => data.fatherOccupation = v,
      'father occupation': (v) => data.fatherOccupation = v,
      'mother': (v) => data.motherName = v,
      "mother's name": (v) => data.motherName = v,
      'mother name': (v) => data.motherName = v,
      "mother's occupation": (v) => data.motherOccupation = v,
      'mother occupation': (v) => data.motherOccupation = v,
      'brothers': (v) => data.brothers = v,
      'brother': (v) => data.brothers = v,
      'sisters': (v) => data.sisters = v,
      'sister': (v) => data.sisters = v,
      'family type': (v) => data.familyType = v,
      'family values': (v) => data.familyValues = v,
      'native place': (v) => data.nativePlace = v,
      'native': (v) => data.nativePlace = v,
      'expectations': (v) => data.expectations = v,
      'partner expectations': (v) => data.expectations = v,
      'phone': (v) => data.phone = v,
      'mobile': (v) => data.phone = v,
      'contact': (v) => data.phone = v,
      'email': (v) => data.email = v,
      'address': (v) => data.address = v,
    };

    for (final line in _lines(text)) {
      final sep = line.indexOf(':');
      if (sep <= 0) continue;
      final label = line
          .substring(0, sep)
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z\x27 ]'), '')
          .trim();
      final value = line.substring(sep + 1).trim();
      if (value.isEmpty) continue;
      setters[label]?.call(value);
    }

    // Name fallback: first name-looking line (skipping invocation lines).
    if (data.name.trim().isEmpty) {
      for (final line in _lines(text).take(6)) {
        if (line.contains('||') || line.contains(':')) continue;
        if (_looksLikeName(line)) {
          data.name = line;
          break;
        }
      }
    }
    return data;
  }

  /// How many fields the resume parse filled (for the "auto-filled N
  /// fields" toast).
  static int resumeFilledCount(ResumeData d) => [
        d.name,
        d.jobTitle,
        d.email,
        d.phone,
        d.linkedin,
        d.github,
        d.summary,
        if (d.techSkills.isNotEmpty) 'skills',
      ].where((s) => s.trim().isNotEmpty).length;

  static int biodataFilledCount(BiodataData d) =>
      d.personalRows.length +
      d.horoscopeRows.length +
      d.careerRows.length +
      d.familyRows.length +
      d.contactRows.length +
      (d.name.trim().isEmpty ? 0 : 1) +
      (d.expectations.trim().isEmpty ? 0 : 1);
}
