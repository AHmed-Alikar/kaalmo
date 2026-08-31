import 'package:flutter/foundation.dart';

/// `GET /api/v1/payments/config` — lets the client render the payment-method
/// picker from the server instead of hard-coding providers. `manual` is always
/// present; `evc_plus` only when the WaafiPay gateway is configured.
@immutable
class PaymentConfig {
  const PaymentConfig({
    required this.providers,
    required this.currency,
    required this.minAmount,
  });

  final List<String> providers;
  final String currency;
  final num minAmount;

  bool get hasAnyProvider => providers.isNotEmpty;

  /// Providers a donor can actually pay through. `manual` is the admin / offline
  /// recording method — the backend auto-confirms it with no charge and no
  /// EVC Plus / WaafiPay prompt — so it is never offered in the donor flow.
  /// (The web donation page likewise only ever uses `evc_plus`.)
  List<String> get donorProviders =>
      providers.where((p) => p != 'manual').toList(growable: false);

  /// True when the donor has at least one real payment method to pay with.
  bool get hasDonorProvider => donorProviders.isNotEmpty;

  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['providers'];
    final providers = raw is List
        ? raw.map((e) => '$e').where((e) => e.isNotEmpty).toList()
        : const <String>[];
    final min = json['minAmount'];
    return PaymentConfig(
      providers: providers,
      currency: '${json['currency'] ?? 'USD'}',
      minAmount: min is num ? min : num.tryParse('$min') ?? 0.01,
    );
  }
}
