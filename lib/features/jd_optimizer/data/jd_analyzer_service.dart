import 'package:template/features/jd_optimizer/domain/jd_analysis_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';
import 'package:template/global/constant/ats_keywords.dart';

/// Deterministic, on-device Job-Description analyzer.
///
/// Extracts required skills, keywords, responsibilities, and soft skills from
/// a pasted JD, compares them against the resume, and produces a gap analysis
/// with concrete suggested additions.
class JdAnalyzerService {
  const JdAnalyzerService();

  JdAnalysis analyze(String jdText, ResumeData resume) {
    if (jdText.trim().isEmpty) return JdAnalysis.empty();

    final lowerJd = jdText.toLowerCase();
    final resumeText = _resumeText(resume).toLowerCase();

    // Known tech skills present in the JD.
    final requiredSkills = AtsKeywords.techSkills
        .where((k) => lowerJd.contains(k))
        .toList();

    // Soft skills present in the JD.
    final softSkills =
        AtsKeywords.softSkills.where((k) => lowerJd.contains(k)).toList();

    // Additional salient keywords (capitalised terms / frequent nouns) that
    // aren't already covered by the skill list or stop-words.
    final extra = _salientTerms(jdText)
        .where((t) =>
            !requiredSkills.contains(t) &&
            !softSkills.contains(t) &&
            !AtsKeywords.stopWords.contains(t))
        .toList();

    final keywords = <String>[
      ...requiredSkills,
      ...extra.take(10),
    ];

    // Bullet-like lines that read as responsibilities.
    final responsibilities = jdText
        .split(RegExp(r'[\n•·\-–]+'))
        .map((l) => l.trim())
        .where((l) => l.length > 25 && l.split(' ').length >= 4)
        .take(8)
        .toList();

    // Gap: which required skills / keywords are missing from the resume.
    final allWanted = <String>{...requiredSkills, ...softSkills, ...extra.take(8)};
    final matched = <String>[];
    final missing = <String>[];
    for (final k in allWanted) {
      (resumeText.contains(k) ? matched : missing).add(k);
    }

    final suggestions = _suggestions(missing, requiredSkills);

    return JdAnalysis(
      requiredSkills: requiredSkills,
      keywords: keywords,
      responsibilities: responsibilities,
      softSkills: softSkills,
      matchedKeywords: matched,
      missingKeywords: missing,
      suggestions: suggestions,
    );
  }

  List<JdSuggestion> _suggestions(
      List<String> missing, List<String> requiredSkills) {
    final out = <JdSuggestion>[];
    for (final kw in missing) {
      final isSoft = AtsKeywords.softSkills.contains(kw);
      final pretty = _title(kw);
      if (isSoft) {
        out.add(JdSuggestion(
          section: 'Summary',
          keyword: kw,
          text: 'Demonstrated $kw across cross-functional teams.',
        ));
      } else {
        out.add(JdSuggestion(
          section: 'Experience',
          keyword: kw,
          text: _experienceLine(pretty),
        ));
      }
    }
    // Also recommend adding missing hard skills to the Skills section.
    final missingHard = missing
        .where((k) => requiredSkills.contains(k))
        .map(_title)
        .toList();
    if (missingHard.isNotEmpty) {
      out.add(JdSuggestion(
        section: 'Skills',
        keyword: missingHard.join(', '),
        text: missingHard.join(', '),
      ));
    }
    return out;
  }

  String _experienceLine(String skill) {
    final templates = <String>[
      'Integrated $skill into production systems, improving reliability.',
      'Built and shipped features using $skill in an agile environment.',
      'Implemented $skill, reducing manual effort and improving delivery speed.',
    ];
    // Deterministic pick based on skill name length (no Random — keeps tests
    // and resume-replays stable).
    return templates[skill.length % templates.length];
  }

  /// Capitalised multi-word terms and frequent lowercase nouns from the JD.
  List<String> _salientTerms(String jd) {
    final freq = <String, int>{};
    for (final raw in jd.split(RegExp(r'[^A-Za-z0-9+.#]+'))) {
      final w = raw.toLowerCase();
      if (w.length < 3) continue;
      if (AtsKeywords.stopWords.contains(w)) continue;
      if (RegExp(r'^\d+$').hasMatch(w)) continue;
      freq[w] = (freq[w] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  String _title(String s) =>
      s.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  String _resumeText(ResumeData r) {
    final b = StringBuffer()
      ..writeln(r.jobTitle)
      ..writeln(r.summary);
    for (final e in r.filledExperience) {
      b.writeln('${e.role} ${e.bullets.join(' ')}');
    }
    for (final p in r.filledProjects) {
      b.writeln('${p.name} ${p.tech} ${p.description}');
    }
    for (final g in r.filledTechSkills) {
      b.writeln(g.skills);
    }
    b.writeln(r.filledExpertise.join(' '));
    return b.toString();
  }
}
