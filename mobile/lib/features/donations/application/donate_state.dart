import 'package:flutter/foundation.dart';

import '../data/models/donation_result.dart';
import '../data/models/payment_config.dart';
import '../../../core/utils/money_input.dart';

/// Where the donor is in the flow. The backend confirms the payment
/// synchronously today, but [pending] is modelled so a future provider that
/// returns an unresolved payment is handled honestly.
enum DonatePhase { editing, review, processing, pending, success, failed }

/// Why an entered amount is not acceptable. The screen localises this.
enum AmountIssue { none, empty, notANumber, belowMinimum, aboveMaximum }

/// Backend cap: `amount: z.number().positive().max(1_000_000)`.
const kDonationMaxAmount = 1000000;

/// UI convenience only — not a backend-defined limit.
const kDonationPresets = <int>[5, 10, 25, 50, 100];

/// Max message length mirrors the backend (`message: z.string().max(500)`).
const kDonationMessageMax = 500;

@immutable
class DonateState {
  const DonateState({
    this.phase = DonatePhase.editing,
    this.amountText = '',
    this.message = '',
    this.isAnonymous = false,
    this.providerId,
    this.phone = '',
    this.config,
    this.configLoading = true,
    this.configError,
    this.result,
    this.submitError,
    this.minAmount = 0.01,
  });

  final DonatePhase phase;
  final String amountText;
  final String message;
  final bool isAnonymous;
  final String? providerId;
  final String phone;

  final PaymentConfig? config;
  final bool configLoading;
  final Object? configError;

  final DonationResult? result;
  final Object? submitError;

  final num minAmount;

  double? get amountValue => parseAmount(amountText);

  AmountIssue get amountIssue {
    final raw = amountText.trim();
    if (raw.isEmpty) return AmountIssue.empty;
    final v = parseAmount(raw);
    if (v == null) return AmountIssue.notANumber;
    if (v < minAmount) return AmountIssue.belowMinimum;
    if (v > kDonationMaxAmount) return AmountIssue.aboveMaximum;
    return AmountIssue.none;
  }

  bool get messageTooLong => message.trim().length > kDonationMessageMax;

  bool get amountValid => amountIssue == AmountIssue.none;

  bool get canContinue => amountValid && !messageTooLong && !configLoading && configError == null;

  /// Real payment methods the donor can pay with (`manual` excluded).
  List<String> get donorProviders => config?.donorProviders ?? const <String>[];

  /// The config loaded but exposes no donor payment method (e.g. the WaafiPay /
  /// EVC Plus gateway is not configured on the backend). Submit is blocked
  /// rather than silently falling back to the offline `manual` path.
  bool get paymentUnavailable => config != null && !configLoading && donorProviders.isEmpty;

  bool get providerRequiresPhone => providerId == 'evc_plus';

  bool get phoneValid {
    if (!providerRequiresPhone) return true;
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  bool get canSubmit =>
      amountValid &&
      !messageTooLong &&
      providerId != null &&
      donorProviders.contains(providerId) &&
      phoneValid &&
      phase != DonatePhase.processing;

  bool get isProcessing => phase == DonatePhase.processing;

  DonateState copyWith({
    DonatePhase? phase,
    String? amountText,
    String? message,
    bool? isAnonymous,
    String? providerId,
    String? phone,
    PaymentConfig? config,
    bool? configLoading,
    Object? configError,
    DonationResult? result,
    Object? submitError,
    num? minAmount,
    bool clearSubmitError = false,
    bool clearResult = false,
  }) =>
      DonateState(
        phase: phase ?? this.phase,
        amountText: amountText ?? this.amountText,
        message: message ?? this.message,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        providerId: providerId ?? this.providerId,
        phone: phone ?? this.phone,
        config: config ?? this.config,
        configLoading: configLoading ?? this.configLoading,
        configError: configError ?? this.configError,
        result: clearResult ? null : (result ?? this.result),
        submitError: clearSubmitError ? null : (submitError ?? this.submitError),
        minAmount: minAmount ?? this.minAmount,
      );
}
