import 'package:flutter/material.dart';

import 'package:template/features/resume/domain/ai_suggestion_model.dart';
import '../theme/app_theme.dart';

/// Inline AI suggestion shown above a form section, with the
/// Accept / Edit / Dismiss workflow and status tracking.
class AiSuggestionCard extends StatelessWidget {
  const AiSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
    required this.onEdit,
    required this.onDismiss,
  });

  final AiSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onEdit;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final status = suggestion.status;
    final resolved = status.isResolved;
    final dismissed = status == SuggestionStatus.dismissed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: resolved
            ? null
            : LinearGradient(
                colors: [
                  AppTheme.accent.withValues(alpha: 0.10),
                  AppTheme.surface,
                ],
              ),
        color: resolved ? AppTheme.surface : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: switch (status) {
            SuggestionStatus.accepted ||
            SuggestionStatus.edited =>
              AppTheme.success.withValues(alpha: 0.6),
            SuggestionStatus.dismissed => AppTheme.outline,
            SuggestionStatus.pending => AppTheme.accent.withValues(alpha: 0.5),
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 16, color: AppTheme.accent),
              const SizedBox(width: 6),
              Text(
                'AI Suggestion · ${suggestion.section}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                ),
              ),
              const Spacer(),
              if (resolved)
                _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.suggested,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              decoration: dismissed ? TextDecoration.lineThrough : null,
              color: dismissed ? AppTheme.textSecondary : AppTheme.textPrimary,
            ),
          ),
          if (suggestion.rationale.isNotEmpty && !resolved) ...[
            const SizedBox(height: 6),
            Text(
              suggestion.rationale,
              style: const TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          if (status == SuggestionStatus.pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      backgroundColor: AppTheme.success,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style:
                        OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SuggestionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == SuggestionStatus.dismissed
        ? AppTheme.textSecondary
        : AppTheme.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
