import 'package:flutter_test/flutter_test.dart';
import 'package:template/main.dart';
import 'package:template/features/biodata/domain/biodata_data_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';
import 'package:template/global/theme/app_theme.dart';

void main() {
  testWidgets('Home screen: type selection + optional file + continue',
      (tester) async {
    await tester.pumpWidget(const ResumeKitApp());
    await tester.pumpAndSettle();

    expect(find.text('ResumeKit Pro'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Marriage Biodata'), findsOneWidget);
    expect(find.text('Choose PDF or DOCX'), findsOneWidget);

    // Resume is preselected — continue straight to the resume picker.
    await tester.tap(find.text('Continue — Pick a Resume Template'));
    await tester.pumpAndSettle();
    expect(find.text('Load Sample'), findsOneWidget);
    expect(find.text('Fill In My Details'), findsOneWidget);
    expect(find.text('Modern Dark'), findsOneWidget);
  });

  testWidgets('Biodata flow reachable from home', (tester) async {
    await tester.pumpWidget(const ResumeKitApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Marriage Biodata'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue — Pick a Biodata Style'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a biodata style'), findsOneWidget);
    expect(find.text('Maroon Heritage'), findsOneWidget);
  });

  test('Catalogues hold 50 resume + 50 biodata templates with unique ids', () {
    expect(AppTheme.templates.length, 50);
    expect(AppTheme.biodataTemplates.length, 50);
    expect(
      AppTheme.templates.map((t) => t.id).toSet().length,
      AppTheme.templates.length,
    );
    expect(
      AppTheme.biodataTemplates.map((t) => t.id).toSet().length,
      AppTheme.biodataTemplates.length,
    );
  });

  test('Empty sections are hidden via filled* helpers', () {
    final data = ResumeData(
      experience: [Experience()],
      projects: [Project()],
      education: [Education()],
      expertise: [''],
    );
    expect(data.filledExperience, isEmpty);
    expect(data.filledProjects, isEmpty);
    expect(data.filledEducation, isEmpty);
    expect(data.filledExpertise, isEmpty);
  });

  test('Sample resume fills all 11 sections', () {
    final s = ResumeData.sample();
    expect(s.name, isNotEmpty);
    expect(s.summary, isNotEmpty);
    expect(s.filledExpertise, isNotEmpty);
    expect(s.filledExperience, isNotEmpty);
    expect(s.filledTechSkills, isNotEmpty);
    expect(s.filledProjects, isNotEmpty);
    expect(s.filledEducation, isNotEmpty);
    expect(s.personal.isEmpty, isFalse);
    expect(s.filledCertificates, isNotEmpty);
    expect(s.filledPatents, isNotEmpty);
    expect(s.hasContact, isTrue);
  });

  test('Sample biodata fills every section', () {
    final b = BiodataData.sample();
    expect(b.name, isNotEmpty);
    expect(b.personalRows, isNotEmpty);
    expect(b.horoscopeRows, isNotEmpty);
    expect(b.careerRows, isNotEmpty);
    expect(b.familyRows, isNotEmpty);
    expect(b.contactRows, isNotEmpty);
    expect(b.expectations, isNotEmpty);
  });

  test('Biodata empty rows are skipped', () {
    final b = BiodataData(name: 'Test', dob: '1 Jan 1995');
    expect(b.personalRows, [('Date of Birth', '1 Jan 1995')]);
    expect(b.horoscopeRows, isEmpty);
    expect(b.familyRows, isEmpty);
  });

  test('initials derived from name', () {
    expect(ResumeData(name: 'Deepak Sharma').initials, 'DS');
    expect(ResumeData(name: 'Priya').initials, 'P');
    expect(ResumeData().initials, '?');
    expect(BiodataData(name: 'Ananya Sharma').initials, 'AS');
  });
}
