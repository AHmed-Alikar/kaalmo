import 'package:flutter/foundation.dart';

/// `GET /api/v1/campaigns/stats` — real, derivable platform numbers only.
@immutable
class PlatformStats {
  const PlatformStats({
    required this.totalRaised,
    required this.campaignCount,
    required this.donorCount,
  });

  final num totalRaised;
  final int campaignCount;
  final int donorCount;

  factory PlatformStats.fromJson(Map<String, dynamic> json) => PlatformStats(
        totalRaised: (json['totalRaised'] as num?) ?? 0,
        campaignCount: (json['campaignCount'] as num?)?.toInt() ?? 0,
        donorCount: (json['donorCount'] as num?)?.toInt() ?? 0,
      );
}
