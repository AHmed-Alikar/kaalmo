import 'package:flutter/foundation.dart';

import '../../domain/donation_status.dart';

/// The campaign a donation was made to, as populated by
/// `GET /api/v1/donations/mine` (`title coverImageUrl category` only). Null when
/// the campaign has since been deleted.
@immutable
class MyDonationCampaign {
  const MyDonationCampaign({
    required this.id,
    required this.title,
    required this.category,
    this.coverImageUrl,
  });

  final String id;
  final Map<String, String> title;
  final String category;
  final String? coverImageUrl;

  String titleFor(String lang) {
    final preferred = title[lang];
    if (preferred != null && preferred.trim().isNotEmpty) return preferred;
    for (final v in title.values) {
      if (v.trim().isNotEmpty) return v;
    }
    return '';
  }

  static Map<String, String> _title(dynamic raw) {
    if (raw is Map) {
      return {
        for (final e in raw.entries)
          if (e.value != null) '${e.key}': '${e.value}',
      };
    }
    if (raw is String) return {'so': raw};
    return const {};
  }

  static MyDonationCampaign? fromJson(dynamic raw, {String Function(String)? mediaUrlResolver}) {
    if (raw is! Map) return null;
    final json = raw.cast<String, dynamic>();
    final id = '${json['_id'] ?? json['id'] ?? ''}';
    if (id.isEmpty) return null;
    final cover = json['coverImageUrl'] as String?;
    return MyDonationCampaign(
      id: id,
      title: _title(json['title']),
      category: '${json['category'] ?? ''}',
      coverImageUrl: cover == null || cover.isEmpty
          ? null
          : (mediaUrlResolver?.call(cover) ?? cover),
    );
  }
}

/// One row of the signed-in donor's history. Only fields the backend actually
/// returns are modelled — `Donation.find({donorId}).populate('campaignId', ...)`,
/// newest-first, no pagination. Payment method / provider is **not** returned by
/// this endpoint (it lives on the un-populated Payment record).
@immutable
class MyDonation {
  const MyDonation({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.isAnonymous,
    this.message,
    this.createdAt,
    this.paymentId,
    this.campaign,
  });

  final String id;
  final num amount;
  final String currency;

  /// Raw backend status; use [statusView] for display.
  final String status;
  final bool isAnonymous;
  final String? message;
  final DateTime? createdAt;

  /// Reference shown on the receipt when there is no better identifier.
  final String? paymentId;

  /// Null when the campaign has been deleted.
  final MyDonationCampaign? campaign;

  DonationStatusView get statusView => DonationStatusView.from(status);

  /// A stable human reference for the receipt.
  String get reference => id;

  factory MyDonation.fromJson(
    Map<String, dynamic> json, {
    String Function(String)? mediaUrlResolver,
  }) {
    final rawAmount = json['amount'];
    return MyDonation(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      amount: rawAmount is num ? rawAmount : num.tryParse('$rawAmount') ?? 0,
      currency: '${json['currency'] ?? 'USD'}',
      status: '${json['status'] ?? ''}',
      isAnonymous: json['isAnonymous'] == true,
      message: (json['message'] as String?)?.trim().isNotEmpty == true
          ? json['message'] as String
          : null,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      paymentId: '${json['paymentId'] ?? ''}'.isEmpty ? null : '${json['paymentId']}',
      campaign: MyDonationCampaign.fromJson(json['campaignId'], mediaUrlResolver: mediaUrlResolver),
    );
  }
}
