import 'package:flutter_test/flutter_test.dart';
import 'package:template/features/resume/data/ai_enhancement_service.dart';
import 'package:template/features/ats_analysis/data/ats_analyzer_service.dart';
import 'package:template/features/jd_optimizer/data/jd_analyzer_service.dart';
import 'package:template/features/ats_analysis/domain/ats_report_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';

void main() {
  const ats = AtsAnalyzerService();
  const jdEngine = JdAnalyzerService();
  const ai = LocalAiEnhancementService();

  group('ATS analyzer', () {
    test('weights sum to 100', () {
      final r = ats.analyze(ResumeData.sample());
      expect(
        r.categories.fold<int>(0, (s, c) => s + c.weight),
        100,
      );
    });

    test('blank resume scores low and flags critical issues', () {
      final r = ats.analyze(ResumeData(name: 'Test'));
      expect(r.score, lessThan(50));
      expect(
        r.issues.any((i) => i.severity == AtsSeverity.critical),
        isTrue,
      );
      expect(r.isDownloadable, isFalse);
    });

    test('rich sample resume scores well', () {
      final r = ats.analyze(ResumeData.sample());
      expect(r.score, greaterThan(60));
    });

    test('missing summary is reported', () {
      final data = ResumeData.sample()..summary = '';
      final r = ats.analyze(data);
      expect(
        r.issues.any((i) => i.title.toLowerCase().contains('summary')),
        isTrue,
      );
    });

    test('experience without numbers flags "no measurable achievements"', () {
      final data = ResumeData(
        name: 'A',
        summary: 'Engineer.',
        experience: [
          Experience(
            role: 'Dev',
            company: 'X',
            bullets: ['Worked on apps', 'Helped with features'],
          ),
        ],
      );
      final r = ats.analyze(data);
      expect(
        r.issues.any((i) => i.title.contains('measurable')),
        isTrue,
      );
    });

    test('score is deterministic', () {
      final a = ats.analyze(ResumeData.sample()).score;
      final b = ats.analyze(ResumeData.sample()).score;
      expect(a, b);
    });

    test('JD coverage drives the keyword category', () {
      final resume = ResumeData.sample();
      const jdText =
          'Looking for Flutter, GraphQL, CI/CD, Kubernetes and unit testing.';
      final jd = jdEngine.analyze(jdText, resume);
      final r = ats.analyze(resume, jd: jd);
      expect(r.missingKeywords, isNotEmpty); // sample lacks graphql/k8s
      expect(
        r.issues.any((i) => i.title.toLowerCase().contains('keyword')),
        isTrue,
      );
    });
  });

  group('JD analyzer', () {
    const jdText = '''
We need a Flutter developer with strong Dart skills.
Must have GraphQL, REST API, CI/CD and unit testing experience.
Leadership and communication are a plus.
''';

    test('extracts required + soft skills', () {
      final jd = jdEngine.analyze(jdText, ResumeData());
      expect(jd.requiredSkills, contains('flutter'));
      expect(jd.requiredSkills, contains('graphql'));
      expect(jd.softSkills, contains('leadership'));
    });

    test('gap analysis finds missing keywords vs resume', () {
      final resume = ResumeData(
        name: 'A',
        techSkills: [TechSkillGroup(category: 'Skills', skills: 'Flutter, Dart')],
      );
      final jd = jdEngine.analyze(jdText, resume);
      expect(jd.matchedKeywords, contains('flutter'));
      expect(jd.missingKeywords, contains('graphql'));
      expect(jd.suggestions, isNotEmpty);
      expect(jd.matchScore, inInclusiveRange(0, 100));
    });

    test('empty JD yields empty analysis', () {
      final jd = jdEngine.analyze('', ResumeData.sample());
      expect(jd.requiredSkills, isEmpty);
      expect(jd.hasGap, isFalse);
    });
  });

  group('AI enhancement (local)', () {
    test('generates a non-empty professional summary', () {
      final s = ai.generateSummary(ResumeData.sample());
      expect(s.suggested.trim(), isNotEmpty);
      expect(s.section, 'Summary');
    });

    test('enhances a weak bullet with an action verb', () {
      final s = ai.enhanceExperienceBullet(
        role: 'Engineer',
        company: 'Acme',
        original: 'worked on flutter apps',
      );
      expect(s.suggested.toLowerCase(), isNot(startsWith('worked on')));
      expect(s.suggested.trim(), isNotEmpty);
    });

    test('suggests skills and certifications', () {
      final resume = ResumeData.sample();
      expect(ai.suggestSkills(resume).suggested, isNotEmpty);
      expect(ai.recommendCertifications(resume).suggested, isNotEmpty);
    });

    test('output is deterministic', () {
      final a = ai.generateSummary(ResumeData.sample()).suggested;
      final b = ai.generateSummary(ResumeData.sample()).suggested;
      expect(a, b);
    });

    test('default seam points at the local engine', () {
      expect(AiEnhancement.instance, isA<LocalAiEnhancementService>());
    });
  });
}
