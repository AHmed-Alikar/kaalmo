import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/relative_time.dart';
import '../../data/models/campaign_comment.dart';

/// The backend does not populate the comment author, so the best we can do is
/// mark the current user's own comments and otherwise show a neutral label.
class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment, required this.currentUserId});

  final CampaignComment comment;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final mine = comment.isMine(currentUserId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: scheme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.person_outline, size: 18, color: scheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(mine ? l10n.commentAuthorYou : l10n.commentAuthorSupporter,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(formatRelative(comment.createdAt, l10n),
                      style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 3),
              Text(comment.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}
