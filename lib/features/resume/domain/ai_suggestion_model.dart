/// A single AI-generated suggestion the user can Accept, Edit, or Dismiss.
///
/// The form must not advance past a section until every suggestion in it has
/// been resolved (accepted / edited / dismissed) — see [SuggestionStatus].
enum SuggestionStatus { pending, accepted, edited, dismissed }

extension SuggestionStatusLabel on SuggestionStatus {
  String get label => switch (this) {
        SuggestionStatus.pending => 'Pending',
        SuggestionStatus.accepted => 'Accepted',
        SuggestionStatus.edited => 'Edited',
        SuggestionStatus.dismissed => 'Dismissed',
      };

  bool get isResolved => this != SuggestionStatus.pending;
}

class AiSuggestion {
  AiSuggestion({
    required this.section,
    required this.suggested,
    this.original = '',
    this.rationale = '',
    this.status = SuggestionStatus.pending,
  });

  /// Human-readable section name this suggestion targets (e.g. "Summary").
  final String section;

  /// The original content (may be empty when generating fresh content).
  final String original;

  /// AI-proposed replacement / addition.
  String suggested;

  /// Short "why this helps" note.
  final String rationale;

  SuggestionStatus status;

  /// The text to apply if accepted/edited; empty when dismissed.
  String get applied =>
      status == SuggestionStatus.dismissed ? '' : suggested;
}
