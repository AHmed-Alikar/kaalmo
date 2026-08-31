import 'package:flutter/foundation.dart';

import '../../../campaigns/data/models/campaign.dart';

/// Dashboard numbers derived **client-side from the real `/campaigns/mine`
/// list** — the backend exposes no organizer-aggregate endpoint, so nothing
/// here is invented; it is a straight tally of the campaigns the API returned.
@immutable
class OrganizerStats {
  const OrganizerStats({
    required this.total,
    required this.drafts,
    required this.inReview,
    required this.live,
    required this.completed,
    required this.rejected,
    required this.totalRaised,
    required this.currency,
  });

  final int total;
  final int drafts;
  final int inReview;
  final int live;
  final int completed;
  final int rejected;
  final num totalRaised;
  final String currency;

  static const _inReview = {'submitted', 'under_review', 'approved'};
  static const _live = {'published', 'active', 'goal_reached', 'withdrawal'};

  factory OrganizerStats.from(List<Campaign> campaigns) {
    var drafts = 0, inReview = 0, live = 0, completed = 0, rejected = 0;
    num raised = 0;
    String currency = 'USD';
    for (final c in campaigns) {
      raised += c.raisedAmount;
      if (c.currency.isNotEmpty) currency = c.currency;
      switch (c.status) {
        case 'draft':
          drafts++;
        case 'completed':
          completed++;
        case 'rejected':
          rejected++;
        default:
          if (_inReview.contains(c.status)) {
            inReview++;
          } else if (_live.contains(c.status)) {
            live++;
          }
      }
    }
    return OrganizerStats(
      total: campaigns.length,
      drafts: drafts,
      inReview: inReview,
      live: live,
      completed: completed,
      rejected: rejected,
      totalRaised: raised,
      currency: currency,
    );
  }
}
