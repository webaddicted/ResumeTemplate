import 'package:template/features/resume/domain/ai_suggestion_model.dart';
import 'package:template/features/resume/domain/resume_data_model.dart';
import 'package:template/global/constant/ats_keywords.dart';

/// Contract for AI-assisted resume enhancement.
///
/// The app ships with [LocalAiEnhancementService] — a deterministic,
/// on-device engine that needs no network or API key, in keeping with the
/// app's offline-first design. To use a hosted LLM instead (Claude API,
/// OpenAI, etc.), implement this interface and assign it to
/// [AiEnhancement.instance] at startup; every screen reads through that seam.
abstract class AiEnhancementService {
  /// A professional summary synthesised from skills / experience / projects.
  AiSuggestion generateSummary(ResumeData resume);

  /// An ATS-optimised rewrite of one experience bullet (or a fresh one when
  /// [original] is blank), given the role context.
  AiSuggestion enhanceExperienceBullet({
    required String role,
    required String company,
    required String original,
  });

  /// Recommended skills to add, based on the role and what's already listed.
  AiSuggestion suggestSkills(ResumeData resume);

  /// A polished description for a project.
  AiSuggestion enhanceProject({
    required String name,
    required String tech,
    required String original,
  });

  /// Industry-relevant certification recommendations.
  AiSuggestion recommendCertifications(ResumeData resume);
}

/// Global seam — swap this for a hosted-LLM implementation if desired.
class AiEnhancement {
  AiEnhancement._();
  static AiEnhancementService instance = const LocalAiEnhancementService();
}

/// Deterministic, on-device implementation. Produces professional,
/// ATS-friendly phrasing using templates seeded by the user's own data — no
/// randomness, so results are stable across rebuilds and resume replays.
class LocalAiEnhancementService implements AiEnhancementService {
  const LocalAiEnhancementService();

  @override
  AiSuggestion generateSummary(ResumeData resume) {
    final role = resume.jobTitle.trim().isEmpty
        ? 'Professional'
        : resume.jobTitle.trim();
    final years = _yearsHint(resume);
    final topSkills = _topSkills(resume, 3);
    final skillsPhrase =
        topSkills.isEmpty ? 'modern technologies' : topSkills.join(', ');
    final impact = _firstQuantifiedAchievement(resume);

    final summary = StringBuffer()
      ..write(role)
      ..write(years.isEmpty ? '' : ' with $years')
      ..write(' specialising in $skillsPhrase.')
      ..write(impact.isEmpty
          ? ' Focused on building reliable, high-quality products and '
              'mentoring teams.'
          : ' $impact');

    return AiSuggestion(
      section: 'Summary',
      original: resume.summary,
      suggested: summary.toString(),
      rationale: 'Adds a recruiter-ready summary with role, strengths, '
          'and measurable impact.',
    );
  }

  @override
  AiSuggestion enhanceExperienceBullet({
    required String role,
    required String company,
    required String original,
  }) {
    final base = original.trim();
    final cleaned = _stripWeakOpeners(base);
    final hasNumber = RegExp(r'\d').hasMatch(base);

    String suggested;
    if (cleaned.isEmpty) {
      suggested =
          'Delivered key features as $role at $company, improving product '
          'quality and delivery speed by 30%.';
    } else {
      final verb = _leadVerb(cleaned);
      final core = _decapitalize(_stripLeadVerb(cleaned));
      suggested = '$verb $core';
      if (!hasNumber) {
        suggested = '$suggested, improving performance by 30%.';
      } else if (!suggested.endsWith('.')) {
        suggested = '$suggested.';
      }
    }

    return AiSuggestion(
      section: 'Experience',
      original: original,
      suggested: suggested,
      rationale: 'Starts with a strong action verb and quantifies impact.',
    );
  }

  @override
  AiSuggestion suggestSkills(ResumeData resume) {
    final have = <String>{};
    for (final g in resume.filledTechSkills) {
      have.addAll(g.skills.toLowerCase().split(RegExp(r'[,/|]')).map((s) => s.trim()));
    }
    for (final e in resume.filledExpertise) {
      have.add(e.toLowerCase());
    }

    // Recommend in-demand skills adjacent to what the user already lists.
    final text = _resumeText(resume).toLowerCase();
    final recommended = AtsKeywords.techSkills
        .where((k) => !have.any((h) => h.contains(k)))
        .where((k) => _affinity(k, text, have) > 0)
        .take(6)
        .map(_title)
        .toList();

    final fallback = ['REST API', 'Unit Testing', 'CI/CD', 'Git', 'Agile'];
    final list = recommended.isEmpty ? fallback : recommended;

    return AiSuggestion(
      section: 'Skills',
      original: '',
      suggested: list.join(', '),
      rationale: 'Common, in-demand skills that complement your profile.',
    );
  }

  @override
  AiSuggestion enhanceProject({
    required String name,
    required String tech,
    required String original,
  }) {
    final techPhrase = tech.trim().isEmpty ? '' : ' using $tech';
    final suggested = original.trim().isEmpty
        ? 'Built $name$techPhrase, delivering a polished experience to '
            'thousands of users.'
        : '${_capitalize(_stripWeakOpeners(original).trim())}'
            '${original.trim().endsWith('.') ? '' : '.'}';
    return AiSuggestion(
      section: 'Projects',
      original: original,
      suggested: suggested,
      rationale: 'Clarifies scope, tech, and outcome of the project.',
    );
  }

  @override
  AiSuggestion recommendCertifications(ResumeData resume) {
    final text = _resumeText(resume).toLowerCase();
    final recs = <String>[];
    if (text.contains('flutter') || text.contains('dart')) {
      recs.add('Flutter & Dart – The Complete Guide (Udemy)');
    }
    if (text.contains('aws') || text.contains('cloud')) {
      recs.add('AWS Certified Developer – Associate');
    }
    if (text.contains('agile') || text.contains('scrum')) {
      recs.add('Professional Scrum Master I (PSM I)');
    }
    if (recs.isEmpty) {
      recs.add('Google Associate Android Developer');
    }
    return AiSuggestion(
      section: 'Certifications',
      original: '',
      suggested: recs.join('\n'),
      rationale: 'Industry-relevant certifications that strengthen your profile.',
    );
  }

  // ---- helpers ------------------------------------------------------------
  List<String> _topSkills(ResumeData r, int n) {
    final out = <String>[];
    for (final g in r.filledTechSkills) {
      out.addAll(g.skills.split(RegExp(r'[,/|]')).map((s) => s.trim()));
    }
    out.addAll(r.filledExpertise);
    return out.where((s) => s.isNotEmpty).take(n).toList();
  }

  String _yearsHint(ResumeData r) {
    final m = RegExp(r'(\d+)\+?\s*years', caseSensitive: false)
        .firstMatch('${r.tagline} ${r.summary}');
    if (m != null) return '${m.group(1)}+ years of experience';
    if (r.filledExperience.length >= 2) return 'several years of experience';
    return '';
  }

  String _firstQuantifiedAchievement(ResumeData r) {
    for (final e in r.filledExperience) {
      for (final b in e.bullets) {
        if (RegExp(r'\d').hasMatch(b)) {
          return b.trim().endsWith('.') ? b.trim() : '${b.trim()}.';
        }
      }
    }
    return '';
  }

  double _affinity(String skill, String text, Set<String> have) {
    // Crude relatedness: same ecosystem keywords co-occur.
    const clusters = [
      ['flutter', 'dart', 'bloc', 'mvvm', 'firebase'],
      ['react', 'javascript', 'typescript', 'node.js', 'redux'],
      ['aws', 'docker', 'kubernetes', 'ci/cd', 'github actions'],
      ['rest api', 'graphql', 'microservices', 'websocket', 'oauth'],
    ];
    for (final c in clusters) {
      if (c.contains(skill) && c.any((k) => text.contains(k))) return 1;
    }
    return 0;
  }

  String _leadVerb(String s) {
    final first = s.trim().split(RegExp(r'\s+')).first.toLowerCase();
    if (AtsKeywords.actionVerbs.contains(first)) return _capitalize(first);
    return 'Delivered';
  }

  String _stripLeadVerb(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty &&
        AtsKeywords.actionVerbs.contains(parts.first.toLowerCase())) {
      return parts.skip(1).join(' ');
    }
    return s.trim();
  }

  String _stripWeakOpeners(String s) {
    var out = s.trim();
    for (final w in AtsKeywords.weakPhrases) {
      if (out.toLowerCase().startsWith(w)) {
        out = out.substring(w.length).trim();
        break;
      }
    }
    return out;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
  String _decapitalize(String s) =>
      s.isEmpty ? s : '${s[0].toLowerCase()}${s.substring(1)}';
  String _title(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String _resumeText(ResumeData r) {
    final b = StringBuffer()
      ..writeln(r.jobTitle)
      ..writeln(r.summary)
      ..writeln(r.filledExpertise.join(' '));
    for (final e in r.filledExperience) {
      b.writeln('${e.role} ${e.bullets.join(' ')}');
    }
    for (final g in r.filledTechSkills) {
      b.writeln(g.skills);
    }
    return b.toString();
  }
}
