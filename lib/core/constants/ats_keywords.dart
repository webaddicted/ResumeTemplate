/// Curated word lists used by the ATS and JD engines. Kept small and
/// general-purpose; matching is case-insensitive and substring-aware.
class AtsKeywords {
  AtsKeywords._();

  /// In-demand technical skills used for coverage scoring and JD extraction.
  static const List<String> techSkills = [
    'flutter', 'dart', 'kotlin', 'swift', 'java', 'python', 'javascript',
    'typescript', 'react', 'react native', 'node.js', 'firebase', 'rest api',
    'graphql', 'sql', 'nosql', 'mongodb', 'postgresql', 'docker', 'kubernetes',
    'aws', 'gcp', 'azure', 'ci/cd', 'git', 'github actions', 'jenkins',
    'bloc', 'mvvm', 'mvc', 'clean architecture', 'unit testing',
    'integration testing', 'agile', 'scrum', 'jira', 'figma', 'fastlane',
    'redux', 'state management', 'microservices', 'websocket', 'oauth',
    'jetpack compose', 'swiftui', 'core data', 'sqlite', 'retrofit',
    'dependency injection', 'tdd', 'machine learning', 'data structures',
  ];

  /// Soft skills extracted from job descriptions.
  static const List<String> softSkills = [
    'leadership', 'communication', 'problem solving', 'teamwork',
    'collaboration', 'mentoring', 'ownership', 'adaptability',
    'time management', 'analytical', 'attention to detail', 'creativity',
  ];

  /// Strong resume action verbs (start of an achievement bullet).
  static const List<String> actionVerbs = [
    'developed', 'built', 'designed', 'led', 'implemented', 'architected',
    'improved', 'optimized', 'reduced', 'increased', 'launched', 'shipped',
    'delivered', 'created', 'managed', 'mentored', 'automated', 'scaled',
    'migrated', 'integrated', 'spearheaded', 'drove', 'established',
    'streamlined', 'engineered', 'refactored', 'deployed', 'orchestrated',
  ];

  /// Weak / casual phrasing that hurts professional tone.
  static const List<String> weakPhrases = [
    'worked on', 'helped with', 'responsible for', 'involved in',
    'participated in', 'assisted with', 'did', 'handled', 'stuff', 'things',
  ];

  /// Filler words that reduce readability when overused.
  static const List<String> fillerWords = [
    'really', 'very', 'basically', 'actually', 'just', 'a lot of', 'various',
    'etc', 'and so on',
  ];

  /// Generic JD stop-words to ignore during keyword extraction.
  static const Set<String> stopWords = {
    'the', 'and', 'for', 'with', 'you', 'our', 'are', 'will', 'have', 'this',
    'that', 'who', 'all', 'your', 'work', 'team', 'role', 'job', 'should',
    'must', 'able', 'years', 'year', 'experience', 'including', 'such', 'from',
    'into', 'across', 'using', 'strong', 'good', 'plus', 'etc', 'other',
    'knowledge', 'skills', 'ability', 'requirements', 'responsibilities',
  };
}
