import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template/model/resume_data.dart';
import 'package:template/global/utils/file_import.dart';
import 'package:template/global/utils/pdf_generator.dart';

/// Minimal in-memory DOCX (zip with word/document.xml).
ImportedFile makeDocx(List<String> paragraphs) {
  final body = paragraphs
      .map((p) => '<w:p><w:r><w:t>${const HtmlEscape().convert(p)}</w:t>'
          '</w:r></w:p>')
      .join();
  final xml = '<?xml version="1.0"?><w:document><w:body>$body</w:body>'
      '</w:document>';
  final archive = Archive()
    ..addFile(ArchiveFile('word/document.xml', xml.length, utf8.encode(xml)));
  final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
  return ImportedFile(name: 'test.docx', bytes: bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DOCX text extraction reads paragraphs in order', () {
    final file = makeDocx([
      'Deepak Sharma',
      'Technical Lead',
      'Email: deepak@example.com',
    ]);
    final text = FileImport.extractText(file);
    expect(text, contains('Deepak Sharma'));
    expect(text, contains('Technical Lead'));
    expect(
      text.indexOf('Deepak Sharma'),
      lessThan(text.indexOf('Technical Lead')),
    );
  });

  test('parseResume extracts contact details and name heuristics', () {
    const text = '''
Deepak Sharma
Technical Lead — Mobile
deepak.sharma@example.com | +91 98765 43210
linkedin.com/in/deepaksharma
github.com/deepaksharma

Summary
Mobile technical lead with 9+ years of experience.

Skills
Dart, Kotlin, Swift, Flutter
''';
    final d = FileImport.parseResume(text);
    expect(d.name, 'Deepak Sharma');
    expect(d.jobTitle, 'Technical Lead — Mobile');
    expect(d.email, 'deepak.sharma@example.com');
    expect(d.phone, contains('98765'));
    expect(d.linkedin, contains('linkedin.com/in/deepaksharma'));
    expect(d.github, contains('github.com/deepaksharma'));
    expect(d.summary, contains('9+ years'));
    expect(d.techSkills.single.skills, contains('Kotlin'));
    expect(FileImport.resumeFilledCount(d), greaterThanOrEqualTo(7));
  });

  test('parseBiodata maps label:value lines', () {
    const text = '''
|| Shree Ganeshaya Namah ||
Ananya Sharma
Date of Birth : 14 February 1997
Height : 5' 4"
Religion : Hindu
Caste : Brahmin
Manglik : No
Education : M.Sc. Computer Science
Occupation : Software Engineer
Father's Name : Shri Rajesh Sharma
Family Type : Nuclear
Phone : +91 98290 12345
Email : sharma.family@example.com
''';
    final b = FileImport.parseBiodata(text);
    expect(b.name, 'Ananya Sharma');
    expect(b.dob, '14 February 1997');
    expect(b.height, "5' 4\"");
    expect(b.religion, 'Hindu');
    expect(b.manglik, 'No');
    expect(b.education, contains('M.Sc.'));
    expect(b.fatherName, contains('Rajesh'));
    expect(b.familyType, 'Nuclear');
    expect(b.phone, contains('98290'));
    expect(b.email, 'sharma.family@example.com');
    expect(FileImport.biodataFilledCount(b), greaterThanOrEqualTo(10));
  });

  test('PDF round-trip: generated resume PDF parses back', () async {
    final bytes = await PdfGenerator.generate(ResumeData.sample());
    final file = ImportedFile(name: 'resume.pdf', bytes: bytes);
    final text = FileImport.extractText(file);
    expect(text, contains('Deepak Sharma'));

    final parsed = FileImport.parseResume(text);
    expect(parsed.email, 'deepak.sharma@example.com');
    expect(parsed.phone, contains('98765'));
  });

  test('empty / unreadable input yields blank data, not errors', () {
    final junk = ImportedFile(
      name: 'broken.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    expect(FileImport.extractText(junk), '');
    expect(FileImport.parseResume('').name, '');
    expect(FileImport.parseBiodata('').name, '');
    expect(FileImport.resumeFilledCount(FileImport.parseResume('')), 0);
  });
}
