/// ATS (Applicant Tracking System) analysis result for a resume.
///
/// Scores are 0–100. The overall score is a weighted average of five
/// category scores (weights below sum to 100). All analysis is deterministic
/// and runs on-device.
library;

enum AtsSeverity { critical, warning, minor }

extension AtsSeverityLabel on AtsSeverity {
  String get label => switch (this) {
        AtsSeverity.critical => 'Critical',
        AtsSeverity.warning => 'Warning',
        AtsSeverity.minor => 'Minor',
      };

  /// Used to sort issues — critical first.
  int get order => switch (this) {
        AtsSeverity.critical => 0,
        AtsSeverity.warning => 1,
        AtsSeverity.minor => 2,
      };
}

/// A single problem found in the resume, with a concrete suggested fix.
class AtsIssue {
  const AtsIssue({
    required this.title,
    required this.severity,
    required this.fix,
    this.category = '',
  });

  final String title;
  final AtsSeverity severity;
  final String fix;
  final String category;
}

/// One scoring category (e.g. Skills) with its weighted contribution.
class AtsCategoryScore {
  const AtsCategoryScore({
    required this.name,
    required this.score, // 0–100
    required this.weight, // percentage points of the overall
  });

  final String name;
  final double score;
  final int weight;

  /// Points this category contributes to the overall score.
  double get weighted => score * weight / 100.0;
}

/// Category weights (sum = 100) — from the V2 spec.
class AtsWeights {
  AtsWeights._();
  static const int formatting = 20;
  static const int skills = 25;
  static const int experience = 20;
  static const int keywords = 20;
  static const int readability = 15;
}

class AtsReport {
  AtsReport({
    required this.categories,
    required this.issues,
    this.matchedKeywords = const [],
    this.missingKeywords = const [],
  });

  final List<AtsCategoryScore> categories;
  final List<AtsIssue> issues;

  /// Keyword coverage (populated when a job description is supplied).
  final List<String> matchedKeywords;
  final List<String> missingKeywords;

  /// Weighted overall score, 0–100 (rounded).
  int get score => categories
      .fold<double>(0, (sum, c) => sum + c.weighted)
      .clamp(0, 100)
      .round();

  /// Issues sorted critical → minor.
  List<AtsIssue> get sortedIssues =>
      [...issues]..sort((a, b) => a.severity.order.compareTo(b.severity.order));

  bool get isDownloadable => score >= passThreshold;

  static const int passThreshold = 90;

  String get band => switch (score) {
        >= 80 => 'Excellent',
        >= 60 => 'Needs Work',
        _ => 'Poor',
      };
}
