import 'package:flutter/foundation.dart';

/// A recent confirmed donation from `GET /api/v1/campaigns/:id/donations`.
///
/// The backend deliberately returns `donorName: null` for anonymous donors
/// (and when no account is attached). No private donor data is exposed.
@immutable
class Supporter {
  const Supporter({
    required this.id,
    required this.amount,
    required this.currency,
    this.donorName,
    this.message,
    this.createdAt,
  });

  final String id;
  final num amount;
  final String currency;

  /// null → anonymous / no linked account.
  final String? donorName;
  final String? message;
  final DateTime? createdAt;

  bool get isAnonymous => donorName == null || donorName!.trim().isEmpty;

  factory Supporter.fromJson(Map<String, dynamic> json) => Supporter(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        amount: (json['amount'] as num?) ?? 0,
        currency: '${json['currency'] ?? 'USD'}',
        donorName: json['donorName'] is String && (json['donorName'] as String).trim().isNotEmpty
            ? (json['donorName'] as String).trim()
            : null,
        message: json['message'] is String && (json['message'] as String).trim().isNotEmpty
            ? (json['message'] as String).trim()
            : null,
        createdAt:
            json['createdAt'] is String ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}

/// `{ items, supporterCount }` — a *recent* list, not a full paginated one.
@immutable
class SupporterList {
  const SupporterList({required this.items, required this.supporterCount});

  final List<Supporter> items;
  final int supporterCount;

  factory SupporterList.fromJson(Map<String, dynamic> json) => SupporterList(
        items: json['items'] is List
            ? (json['items'] as List)
                .whereType<Map>()
                .map((e) => Supporter.fromJson(e.cast<String, dynamic>()))
                .toList()
            : const [],
        supporterCount: (json['supporterCount'] as num?)?.toInt() ?? 0,
      );
}
