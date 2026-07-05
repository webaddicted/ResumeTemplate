import 'package:template/features/ats_analysis/domain/ats_report_model.dart';
import 'package:template/features/jd_optimizer/domain/jd_analysis_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';
import 'package:template/global/constant/ats_keywords.dart';

/// Deterministic, on-device ATS analyzer.
///
/// Scores a [ResumeData] across five weighted categories (Formatting 20,
/// Skills 25, Experience 20, Keywords 20, Readability 15) and produces a
/// prioritised list of fixable issues. Optionally takes the raw text of an
/// uploaded file (for formatting checks) and a [JdAnalysis] (for keyword
/// coverage against a specific job).
class AtsAnalyzerService {
  const AtsAnalyzerService();

  AtsReport analyze(
    ResumeData resume, {
    String rawText = '',
    JdAnalysis? jd,
  }) {
    final issues = <AtsIssue>[];

    final formatting = _formatting(rawText, issues);
    final skills = _skills(resume, issues);
    final experience = _experience(resume, issues);
    final keywords = _keywords(resume, jd, issues);
    final readability = _readability(resume, issues);

    _sectionValidation(resume, issues);

    return AtsReport(
      categories: [
        AtsCategoryScore(
            name: 'Formatting', score: formatting, weight: AtsWeights.formatting),
        AtsCategoryScore(
            name: 'Skills', score: skills, weight: AtsWeights.skills),
        AtsCategoryScore(
            name: 'Experience',
            score: experience,
            weight: AtsWeights.experience),
        AtsCategoryScore(
            name: 'Keywords', score: keywords, weight: AtsWeights.keywords),
        AtsCategoryScore(
            name: 'Readability',
            score: readability,
            weight: AtsWeights.readability),
      ],
      issues: issues,
      matchedKeywords: jd?.matchedKeywords ?? const [],
      missingKeywords: jd?.missingKeywords ?? const [],
    );
  }

  // ---- Formatting (20) ----------------------------------------------------
  // ATS parsers struggle with tables, columns, images, and headers/footers.
  // Structured data we generate is always clean; uploaded files are checked.
  double _formatting(String rawText, List<AtsIssue> issues) {
    if (rawText.trim().isEmpty) return 96; // generated from clean structure
    var score = 100.0;
    final lower = rawText.toLowerCase();

    // Tab-separated runs suggest table/column layout.
    final tabbyLines =
        rawText.split('\n').where((l) => l.contains('\t')).length;
    if (tabbyLines > 3) {
      score -= 20;
      issues.add(const AtsIssue(
        title: 'Complex tables or columns detected',
        severity: AtsSeverity.warning,
        fix: 'Use a single-column layout — ATS parsers often scramble tables.',
        category: 'Formatting',
      ));
    }
    if (lower.contains('\u{fffd}') || RegExp(r'image\d').hasMatch(lower)) {
      score -= 15;
      issues.add(const AtsIssue(
        title: 'Images / non-text elements detected',
        severity: AtsSeverity.warning,
        fix: 'Remove logos and graphics — ATS systems cannot read images.',
        category: 'Formatting',
      ));
    }
    // Very long lines hint at multi-column text merged together.
    final longLines =
        rawText.split('\n').where((l) => l.length > 180).length;
    if (longLines > 2) score -= 10;
    return score.clamp(0, 100);
  }

  // ---- Skills (25) --------------------------------------------------------
  double _skills(ResumeData resume, List<AtsIssue> issues) {
    final skills = _resumeSkills(resume);
    if (skills.isEmpty) {
      issues.add(const AtsIssue(
        title: 'No skills section found',
        severity: AtsSeverity.critical,
        fix: 'Add a Skills section listing your core tools and technologies.',
        category: 'Skills',
      ));
      return 0;
    }

    // Count distinct skills; reward in-demand coverage.
    final distinct = skills.toSet();
    final inDemand = distinct
        .where((s) => AtsKeywords.techSkills.any((k) => s.contains(k)))
        .length;

    // ~12 well-chosen skills ≈ full marks.
    var score = (distinct.length / 12 * 70).clamp(0, 70).toDouble();
    score += (inDemand / 8 * 30).clamp(0, 30);

    if (distinct.length < 5) {
      issues.add(AtsIssue(
        title: 'Only ${distinct.length} skills listed',
        severity: AtsSeverity.warning,
        fix: 'List at least 8–12 relevant skills to improve keyword coverage.',
        category: 'Skills',
      ));
    }
    return score.clamp(0, 100).toDouble();
  }

  // ---- Experience (20) ----------------------------------------------------
  double _experience(ResumeData resume, List<AtsIssue> issues) {
    final exp = resume.filledExperience;
    if (exp.isEmpty) {
      issues.add(const AtsIssue(
        title: 'No work experience found',
        severity: AtsSeverity.critical,
        fix: 'Add at least one role with achievement-focused bullet points.',
        category: 'Experience',
      ));
      return 0;
    }

    var bulletCount = 0;
    var quantified = 0;
    var strongVerbs = 0;
    var weak = 0;
    for (final e in exp) {
      for (final b in e.bullets.where((b) => b.trim().isNotEmpty)) {
        bulletCount++;
        final lower = b.toLowerCase();
        if (RegExp(r'\d').hasMatch(b)) quantified++;
        if (AtsKeywords.actionVerbs.any((v) => lower.trimLeft().startsWith(v))) {
          strongVerbs++;
        }
        if (AtsKeywords.weakPhrases.any((w) => lower.contains(w))) weak++;
      }
    }

    if (bulletCount == 0) {
      issues.add(const AtsIssue(
        title: 'Experience has no bullet points',
        severity: AtsSeverity.critical,
        fix: 'Describe each role with 2–4 achievement bullets.',
        category: 'Experience',
      ));
      return 25;
    }

    var score = 40.0; // baseline for having described experience
    score += (strongVerbs / bulletCount * 30);
    score += (quantified / bulletCount * 30);

    if (quantified == 0) {
      issues.add(const AtsIssue(
        title: 'No measurable achievements',
        severity: AtsSeverity.warning,
        fix: 'Add numbers — e.g. "improved performance by 35%", "10K+ users".',
        category: 'Experience',
      ));
    }
    if (weak > 0) {
      issues.add(AtsIssue(
        title: 'Weak experience descriptions ($weak)',
        severity: AtsSeverity.warning,
        fix: 'Replace "worked on / responsible for" with strong action verbs.',
        category: 'Experience',
      ));
    }
    return score.clamp(0, 100);
  }

  // ---- Keywords (20) ------------------------------------------------------
  double _keywords(ResumeData resume, JdAnalysis? jd, List<AtsIssue> issues) {
    final text = _resumeText(resume).toLowerCase();

    if (jd != null && (jd.matchedKeywords.isNotEmpty ||
        jd.missingKeywords.isNotEmpty)) {
      // Score directly against the job description.
      if (jd.missingKeywords.isNotEmpty) {
        final shown = jd.missingKeywords.take(5).join(', ');
        issues.add(AtsIssue(
          title: 'Missing ${jd.missingKeywords.length} job keywords',
          severity: AtsSeverity.warning,
          fix: 'Add these where genuinely true: $shown.',
          category: 'Keywords',
        ));
      }
      return jd.matchScore.toDouble();
    }

    // No JD: reward presence of the resume's own primary skills, with a
    // bonus for reinforcing them in the summary / experience. Listing a
    // skill earns most of the credit (0.7); using it again earns the rest.
    final skills = _resumeSkills(resume).toSet().toList();
    if (skills.isEmpty) return 30;

    final thinlyUsed = <String>[];
    var coverage = 0.0;
    final sample = skills.take(10).toList();
    for (final s in sample) {
      final count = _count(text, s);
      if (count >= 2) {
        coverage += 1.0;
      } else if (count == 1) {
        coverage += 0.7;
        thinlyUsed.add(s);
      }
    }
    final score = (coverage / sample.length * 100).clamp(0, 100).toDouble();

    if (thinlyUsed.length > sample.length / 2) {
      final kw = thinlyUsed.first;
      issues.add(AtsIssue(
        title: '"$kw" keyword appears only once',
        severity: AtsSeverity.minor,
        fix: 'Reinforce key skills in your summary and experience bullets.',
        category: 'Keywords',
      ));
    }
    return score;
  }

  // ---- Readability (15) ---------------------------------------------------
  double _readability(ResumeData resume, List<AtsIssue> issues) {
    final text = _resumeText(resume);
    if (text.trim().isEmpty) return 50;

    var score = 100.0;
    final lower = text.toLowerCase();

    // Average sentence length.
    final sentences = text
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (sentences.isNotEmpty) {
      final avgWords = sentences
              .map((s) => s.split(RegExp(r'\s+')).length)
              .fold<int>(0, (a, b) => a + b) /
          sentences.length;
      if (avgWords > 28) {
        score -= 20;
        issues.add(const AtsIssue(
          title: 'Long, hard-to-scan sentences',
          severity: AtsSeverity.minor,
          fix: 'Keep sentences under ~20 words; prefer concise bullets.',
          category: 'Readability',
        ));
      }
    }

    // First-person pronouns read as unprofessional in resumes.
    final pronouns = _count(lower, ' i ') + (lower.startsWith('i ') ? 1 : 0) +
        _count(lower, ' my ') + _count(lower, ' me ');
    if (pronouns > 2) {
      score -= 15;
      issues.add(const AtsIssue(
        title: 'First-person pronouns used',
        severity: AtsSeverity.minor,
        fix: 'Drop "I / my / me" — start bullets with action verbs instead.',
        category: 'Readability',
      ));
    }

    final filler =
        AtsKeywords.fillerWords.fold<int>(0, (n, f) => n + _count(lower, f));
    if (filler > 3) score -= 10;

    return score.clamp(0, 100);
  }

  // ---- Section presence ---------------------------------------------------
  void _sectionValidation(ResumeData resume, List<AtsIssue> issues) {
    if (resume.summary.trim().isEmpty) {
      issues.add(const AtsIssue(
        title: 'Missing professional summary',
        severity: AtsSeverity.critical,
        fix: 'Add a 2–3 line summary highlighting your strengths and impact.',
        category: 'Sections',
      ));
    }
    if (resume.filledEducation.isEmpty) {
      issues.add(const AtsIssue(
        title: 'Missing education section',
        severity: AtsSeverity.warning,
        fix: 'Add your highest qualification and institution.',
        category: 'Sections',
      ));
    }
    if (resume.filledCertificates.isEmpty) {
      issues.add(const AtsIssue(
        title: 'No certifications listed',
        severity: AtsSeverity.minor,
        fix: 'Add relevant certifications to strengthen credibility.',
        category: 'Sections',
      ));
    }
    if (resume.email.trim().isEmpty || resume.phone.trim().isEmpty) {
      issues.add(const AtsIssue(
        title: 'Incomplete contact details',
        severity: AtsSeverity.warning,
        fix: 'Include both a professional email and a phone number.',
        category: 'Sections',
      ));
    }
  }

  // ---- helpers ------------------------------------------------------------
  List<String> _resumeSkills(ResumeData resume) {
    final out = <String>[];
    for (final g in resume.filledTechSkills) {
      out.addAll(g.skills
          .split(RegExp(r'[,/|]'))
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty));
    }
    out.addAll(resume.filledExpertise.map((e) => e.trim().toLowerCase()));
    return out;
  }

  String _resumeText(ResumeData r) {
    final b = StringBuffer()
      ..writeln(r.jobTitle)
      ..writeln(r.tagline)
      ..writeln(r.summary);
    for (final e in r.filledExperience) {
      b.writeln('${e.role} ${e.company}');
      b.writeln(e.bullets.join(' '));
    }
    for (final p in r.filledProjects) {
      b.writeln('${p.name} ${p.tech} ${p.description}');
    }
    for (final g in r.filledTechSkills) {
      b.writeln('${g.category} ${g.skills}');
    }
    b.writeln(r.filledExpertise.join(' '));
    return b.toString();
  }

  int _count(String haystack, String needle) {
    if (needle.isEmpty) return 0;
    var count = 0;
    var index = 0;
    while ((index = haystack.indexOf(needle, index)) != -1) {
      count++;
      index += needle.length;
    }
    return count;
  }
}
