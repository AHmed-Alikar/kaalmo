import 'package:flutter/foundation.dart';

import '../../campaigns/data/models/campaign.dart';
import '../../campaigns/data/models/platform_stats.dart';

/// A single fetch backing the Home screen: the newest public campaigns plus
/// the platform trust stats. "Featured" and "Recent" are derived from this
/// one page — the backend has no featured/trending endpoint.
@immutable
class HomeFeed {
  const HomeFeed({required this.campaigns, this.stats});

  final List<Campaign> campaigns;
  final PlatformStats? stats;

  /// Verified campaigns first (real trust signal), newest-first otherwise.
  List<Campaign> get featured {
    final verified = campaigns.where((c) => c.isVerified).toList();
    final pool = verified.isNotEmpty ? verified : campaigns;
    return pool.take(5).toList();
  }

  List<Campaign> get recent => campaigns.take(6).toList();

  bool get isEmpty => campaigns.isEmpty;
}
