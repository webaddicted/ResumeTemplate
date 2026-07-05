/// Result of analysing a pasted Job Description against the current resume.
///
/// Deterministic, on-device. Surfaces the JD's required skills / keywords /
/// soft-skills, plus the gap (what the resume is missing) and concrete
/// suggested additions the user can Accept / Edit / Reject.
class JdSuggestion {
  JdSuggestion({
    required this.section,
    required this.text,
    this.keyword = '',
  });

  /// Target section, e.g. "Experience" or "Skills".
  final String section;

  /// Suggested line to add.
  String text;

  /// The missing keyword that prompted this suggestion.
  final String keyword;
}

class JdAnalysis {
  JdAnalysis({
    required this.requiredSkills,
    required this.keywords,
    required this.responsibilities,
    required this.softSkills,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.suggestions,
  });

  final List<String> requiredSkills;
  final List<String> keywords;
  final List<String> responsibilities;
  final List<String> softSkills;

  /// Keywords from the JD that already appear in the resume.
  final List<String> matchedKeywords;

  /// Keywords from the JD missing from the resume (the gap).
  final List<String> missingKeywords;

  /// Concrete additions to close the gap.
  final List<JdSuggestion> suggestions;

  /// 0–100 match between resume and JD keywords.
  int get matchScore {
    final total = matchedKeywords.length + missingKeywords.length;
    if (total == 0) return 0;
    return (matchedKeywords.length / total * 100).round();
  }

  bool get hasGap => missingKeywords.isNotEmpty;

  static JdAnalysis empty() => JdAnalysis(
        requiredSkills: const [],
        keywords: const [],
        responsibilities: const [],
        softSkills: const [],
        matchedKeywords: const [],
        missingKeywords: const [],
        suggestions: const [],
      );
}
