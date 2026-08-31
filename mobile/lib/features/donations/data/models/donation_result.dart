import 'package:flutter/foundation.dart';

/// The confirmed-payment status the backend reports back on the donate call.
/// The backend is the source of truth — a donation is only "successful" when
/// this says so, never because the HTTP request was accepted.
enum DonationPaymentStatus {
  confirmed,
  pending,
  failed,
  unknown;

  static DonationPaymentStatus from(String? raw) => switch (raw) {
        'confirmed' => confirmed,
        'pending' => pending,
        'failed' => failed,
        _ => unknown,
      };
}

/// `POST /api/v1/campaigns/:id/donate` success body:
/// `{ donation, payment: { paymentId, status }, raisedAmount, note }`.
@immutable
class DonationResult {
  const DonationResult({
    required this.donationId,
    required this.amount,
    required this.currency,
    required this.isAnonymous,
    required this.donationStatus,
    required this.paymentStatus,
    required this.raisedAmount,
    this.message,
    this.paymentId,
    this.createdAt,
  });

  final String donationId;
  final num amount;
  final String currency;
  final bool isAnonymous;

  /// `donation.status` — 'confirmed' | 'pending' | 'failed' | 'refunded'.
  final String donationStatus;

  /// `payment.status` — the authoritative payment outcome.
  final DonationPaymentStatus paymentStatus;

  final num raisedAmount;
  final String? message;
  final String? paymentId;
  final DateTime? createdAt;

  /// Both the donation record and the payment must confirm.
  bool get isConfirmed =>
      paymentStatus == DonationPaymentStatus.confirmed && donationStatus == 'confirmed';

  bool get isPending => paymentStatus == DonationPaymentStatus.pending || donationStatus == 'pending';

  factory DonationResult.fromJson(Map<String, dynamic> json) {
    final donation = (json['donation'] as Map?)?.cast<String, dynamic>() ?? const {};
    final payment = (json['payment'] as Map?)?.cast<String, dynamic>() ?? const {};
    final rawAmount = donation['amount'];
    final rawRaised = json['raisedAmount'];
    return DonationResult(
      donationId: '${donation['_id'] ?? donation['id'] ?? ''}',
      amount: rawAmount is num ? rawAmount : num.tryParse('$rawAmount') ?? 0,
      currency: '${donation['currency'] ?? 'USD'}',
      isAnonymous: donation['isAnonymous'] == true,
      donationStatus: '${donation['status'] ?? ''}',
      paymentStatus: DonationPaymentStatus.from(payment['status'] as String?),
      raisedAmount: rawRaised is num ? rawRaised : num.tryParse('$rawRaised') ?? 0,
      message: (donation['message'] as String?)?.trim().isNotEmpty == true
          ? donation['message'] as String
          : null,
      paymentId: '${payment['paymentId'] ?? donation['paymentId'] ?? ''}'.isEmpty
          ? null
          : '${payment['paymentId'] ?? donation['paymentId']}',
      createdAt: DateTime.tryParse('${donation['createdAt'] ?? ''}'),
    );
  }
}
