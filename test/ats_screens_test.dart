import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:template/features/ats_analysis/presentation/ats_analysis_page.dart';
import 'package:template/features/final_validation/presentation/final_ats_validation_page.dart';
import 'package:template/features/jd_optimizer/presentation/jd_optimizer_page.dart';
import 'package:template/model/resume_data.dart';

Widget _host(Widget child) => GetMaterialApp(home: child);

void main() {
  testWidgets('ATS analysis page shows score and issues for a weak resume',
      (tester) async {
    await tester.pumpWidget(_host(AtsAnalysisPage(data: ResumeData(name: 'Test'))));
    await tester.pumpAndSettle();

    expect(find.text('ATS Resume Analysis'), findsOneWidget);
    expect(find.text('ATS Score'), findsOneWidget);
    expect(find.text('Issues Found'), findsOneWidget);
    expect(find.text('Improve Resume with AI'), findsOneWidget);
    // The score dial renders a percentage.
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('JD optimizer analyzes pasted text and lists the gap',
      (tester) async {
    await tester.pumpWidget(_host(JdOptimizerPage(data: ResumeData.sample())));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Flutter developer with GraphQL, CI/CD and Kubernetes experience.',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Analyze'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Job match:'), findsOneWidget);
    expect(find.text('Suggested additions'), findsOneWidget);
  });

  testWidgets('final validation gates download below 90', (tester) async {
    await tester
        .pumpWidget(_host(FinalAtsValidationPage(data: ResumeData(name: 'Test'))));
    await tester.pumpAndSettle();

    expect(find.text('Final ATS Validation'), findsOneWidget);
    // Weak resume → locked → "Improve More", no "Download Resume".
    expect(find.text('Improve More'), findsOneWidget);
    expect(find.text('Download Resume'), findsNothing);
  });

  testWidgets('final validation unlocks download for a strong resume',
      (tester) async {
    // Build a resume engineered to clear the 90 threshold.
    final data = ResumeData(
      name: 'Deepak Sharma',
      jobTitle: 'Senior Flutter Engineer',
      email: 'a@b.com',
      phone: '+91 99999 88888',
      summary:
          'Senior Flutter engineer with 9+ years building scalable mobile apps. '
          'Delivered measurable impact across teams.',
      expertise: ['Flutter', 'Dart', 'Firebase', 'CI/CD', 'GraphQL'],
      techSkills: [
        TechSkillGroup(
            category: 'Languages', skills: 'Dart, Kotlin, Swift, Java'),
        TechSkillGroup(
            category: 'Frameworks', skills: 'Flutter, React Native'),
        TechSkillGroup(
            category: 'Tools', skills: 'Firebase, Docker, GitHub Actions'),
      ],
      experience: [
        Experience(
          role: 'Lead',
          company: 'Acme',
          bullets: [
            'Developed Flutter apps serving 100K+ users, improving performance by 35%.',
            'Reduced crash rate by 80% and cut build time by 40%.',
            'Led a team of 8 engineers across 3 product squads.',
          ],
        ),
        Experience(
          role: 'Senior Engineer',
          company: 'ShopVerse',
          bullets: [
            'Shipped Flutter rewrite with 5M+ installs and a 4.6 rating.',
            'Improved API latency by 30% using GraphQL and caching.',
          ],
        ),
      ],
      education: [Education(degree: 'B.Tech CSE', institution: 'NIT')],
      certificates: [Certificate(title: 'Flutter Complete Guide')],
    );

    await tester.pumpWidget(_host(FinalAtsValidationPage(data: data)));
    await tester.pumpAndSettle();

    expect(find.text('Download Resume'), findsOneWidget);
    expect(find.text('Improve More'), findsNothing);
  });
}
