import 'package:flutter/foundation.dart';

/// A public campaign as returned by `GET /api/v1/campaigns`.
///
/// Only fields the backend actually sends are modelled. `organizerId` is a
/// bare id (the list endpoint does not populate the organizer), so no
/// organizer name is available on a card.
@immutable
class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.story,
    required this.category,
    required this.goalAmount,
    required this.raisedAmount,
    required this.currency,
    required this.status,
    required this.verificationBadges,
    required this.tags,
    required this.mediaUrls,
    this.subcategory,
    this.coverImageUrl,
    this.region,
    this.organizerId,
    this.beneficiaryId,
    this.endDate,
    this.createdAt,
    this.access,
  });

  final String id;
  final Map<String, String> title;
  final Map<String, String> story;
  final String category;
  final String? subcategory;
  final List<String> tags;
  final num goalAmount;
  final num raisedAmount;
  final String currency;
  final String? coverImageUrl;
  final List<String> mediaUrls;
  final String status;
  final List<String> verificationBadges;
  final String? region;
  final String? organizerId;

  /// Only present on `GET /campaigns/mine` rows that carry a linked beneficiary.
  final String? beneficiaryId;
  final DateTime? endDate;
  final DateTime? createdAt;

  /// `'owner'` / `'co-organizer'` — only set by `GET /campaigns/mine`.
  final String? access;

  bool get isCoOrganizer => access == 'co-organizer';

  /// 0..1, safe against a zero / missing goal.
  double get progress {
    if (goalAmount <= 0) return 0;
    final ratio = raisedAmount / goalAmount;
    if (ratio.isNaN || ratio.isInfinite || ratio < 0) return 0;
    return ratio > 1 ? 1 : ratio.toDouble();
  }

  int get progressPercent => (progress * 100).round();

  bool get isVerified => verificationBadges.isNotEmpty;
  bool get isCompleted => status == 'completed' || status == 'goal_reached';

  /// Preferred-language title with graceful fallback.
  String titleFor(String languageCode) => _pick(title, languageCode);
  String storyFor(String languageCode) => _pick(story, languageCode);

  static String _pick(Map<String, String> loc, String lang) {
    final preferred = loc[lang];
    if (preferred != null && preferred.trim().isNotEmpty) return preferred;
    for (final v in loc.values) {
      if (v.trim().isNotEmpty) return v;
    }
    return '';
  }

  static Map<String, String> _localized(dynamic raw) {
    if (raw is Map) {
      return {
        for (final e in raw.entries)
          if (e.value != null) '${e.key}': '${e.value}',
      };
    }
    if (raw is String) return {'so': raw};
    return const {};
  }

  static List<String> _stringList(dynamic raw) =>
      raw is List ? raw.map((e) => '$e').where((e) => e.isNotEmpty).toList() : const [];

  static num _num(dynamic raw) {
    if (raw is num) return raw;
    return num.tryParse('$raw') ?? 0;
  }

  static DateTime? _date(dynamic raw) => raw is String ? DateTime.tryParse(raw) : null;

  /// [mediaUrlResolver] rewrites dev `localhost` upload URLs to a host the
  /// device can actually reach (the backend embeds its own hostname at upload
  /// time — see the repository).
  factory Campaign.fromJson(
    Map<String, dynamic> json, {
    String Function(String url)? mediaUrlResolver,
  }) {
    String? resolve(dynamic v) {
      final s = v is String && v.trim().isNotEmpty ? v.trim() : null;
      if (s == null) return null;
      return mediaUrlResolver == null ? s : mediaUrlResolver(s);
    }

    return Campaign(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      title: _localized(json['title']),
      story: _localized(json['story']),
      category: '${json['category'] ?? 'Other'}',
      subcategory: json['subcategory'] is String ? json['subcategory'] as String : null,
      tags: _stringList(json['tags']),
      goalAmount: _num(json['goalAmount']),
      raisedAmount: _num(json['raisedAmount']),
      currency: '${json['currency'] ?? 'USD'}',
      coverImageUrl: resolve(json['coverImageUrl']),
      mediaUrls: _stringList(json['mediaUrls']).map((u) => resolve(u) ?? u).toList(),
      status: '${json['status'] ?? ''}',
      verificationBadges: _stringList(json['verificationBadges']),
      region: json['region'] is String && (json['region'] as String).isNotEmpty
          ? json['region'] as String
          : null,
      organizerId: json['organizerId'] is String ? json['organizerId'] as String : null,
      beneficiaryId: json['beneficiaryId'] is String ? json['beneficiaryId'] as String : null,
      endDate: _date(json['endDate']),
      createdAt: _date(json['createdAt']),
      access: json['access'] is String ? json['access'] as String : null,
    );
  }
}

/// One page of `GET /api/v1/campaigns` (`{ items, total, page, limit }`).
@immutable
class CampaignPage {
  const CampaignPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<Campaign> items;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => page * limit < total;

  factory CampaignPage.fromJson(
    Map<String, dynamic> json, {
    String Function(String url)? mediaUrlResolver,
  }) {
    final rawItems = json['items'];
    return CampaignPage(
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => Campaign.fromJson(e.cast<String, dynamic>(), mediaUrlResolver: mediaUrlResolver))
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );
  }
}
