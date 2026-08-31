import 'package:flutter/foundation.dart';

/// `GET /api/v1/payout-accounts/mine` — the caller's payout accounts. The
/// backend only ever stores a masked account number (`***1234`); the full
/// number is never returned.
@immutable
class PayoutAccount {
  const PayoutAccount({
    required this.id,
    required this.type,
    required this.accountNumberMasked,
    required this.providerName,
    required this.verified,
  });

  final String id;

  /// `'mobile_money'` | `'bank'`.
  final String type;
  final String accountNumberMasked;
  final String providerName;
  final bool verified;

  factory PayoutAccount.fromJson(Map<String, dynamic> json) => PayoutAccount(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        type: '${json['type'] ?? ''}',
        accountNumberMasked: '${json['accountNumberMasked'] ?? ''}',
        providerName: '${json['providerName'] ?? ''}',
        verified: json['verified'] == true,
      );
}
