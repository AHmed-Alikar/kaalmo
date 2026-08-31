import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/idempotency.dart';
import '../data/donation_repository.dart';
import 'donate_state.dart';

/// Drives the donation flow for one campaign: amount/message/anonymous →
/// review + payment method → charge → success / pending / failed.
///
/// Guarantees:
/// - The submit call is single-flight (a second call while [DonatePhase.processing]
///   is ignored) and re-uses one `Idempotency-Key` for every retry of the same
///   attempt, so a double tap / network retry / timeout retry never charges twice.
/// - "Successful" is decided by the backend's reported payment status, never by
///   the request being accepted.
class DonateController extends StateNotifier<DonateState> {
  DonateController(this._repo, this._campaignId, this._isAuthenticated)
      : super(const DonateState()) {
    _loadConfig();
  }

  final DonationRepository _repo;
  final String _campaignId;
  final bool _isAuthenticated;

  /// One key per attempt. Kept across retries; cleared when the donor edits the
  /// donation (that is a new attempt).
  String? _idempotencyKey;

  String? get debugIdempotencyKey => _idempotencyKey;

  Future<void> _loadConfig() async {
    state = state.copyWith(configLoading: true, configError: null);
    try {
      final config = await _repo.getPaymentConfig();
      state = state.copyWith(
        config: config,
        configLoading: false,
        minAmount: config.minAmount,
        // Default to the first real payment method (e.g. evc_plus) so the donor
        // flow always drives the actual payment, exactly like the web app.
        // `manual` (offline recording) is never a donor choice — see
        // PaymentConfig.donorProviders.
        providerId: state.providerId ??
            (config.donorProviders.isNotEmpty ? config.donorProviders.first : null),
      );
    } catch (e) {
      state = state.copyWith(configLoading: false, configError: e);
    }
  }

  Future<void> retryLoadConfig() => _loadConfig();

  void setAmount(String value) => state = state.copyWith(amountText: value, clearSubmitError: true);

  void selectPreset(int amount) =>
      state = state.copyWith(amountText: amount.toString(), clearSubmitError: true);

  void setMessage(String value) => state = state.copyWith(message: value);

  void setAnonymous(bool value) => state = state.copyWith(isAnonymous: value);

  void selectProvider(String id) => state = state.copyWith(providerId: id, clearSubmitError: true);

  void setPhone(String value) => state = state.copyWith(phone: value, clearSubmitError: true);

  /// Amount step → review step.
  void goToReview() {
    if (!state.canContinue) return;
    state = state.copyWith(phase: DonatePhase.review);
  }

  /// Review / failed / pending → back to the editable amount step. A fresh
  /// attempt: the next submit gets a new idempotency key.
  void editDonation() {
    _idempotencyKey = null;
    state = state.copyWith(phase: DonatePhase.editing, clearSubmitError: true);
  }

  /// Retry the *same* attempt after a failure — re-uses the idempotency key so
  /// the backend can return the original result if the first request actually
  /// landed.
  void retry() {
    state = state.copyWith(phase: DonatePhase.review, clearSubmitError: true);
  }

  Future<void> submit() async {
    if (!_isAuthenticated) return;
    if (state.phase == DonatePhase.processing) return;
    if (!state.canSubmit) return;

    final amount = state.amountValue;
    final provider = state.providerId;
    if (amount == null || provider == null) return;

    _idempotencyKey ??= newIdempotencyKey();

    state = state.copyWith(phase: DonatePhase.processing, clearSubmitError: true);
    try {
      final result = await _repo.donate(
        campaignId: _campaignId,
        amount: amount,
        provider: provider,
        phone: state.providerRequiresPhone ? state.phone : null,
        message: state.message,
        isAnonymous: state.isAnonymous,
        idempotencyKey: _idempotencyKey!,
      );

      if (result.isConfirmed) {
        state = state.copyWith(phase: DonatePhase.success, result: result);
      } else if (result.isPending) {
        state = state.copyWith(phase: DonatePhase.pending, result: result);
      } else {
        // Accepted request, but the backend did not confirm the payment.
        state = state.copyWith(phase: DonatePhase.failed, result: result);
      }
    } catch (e) {
      state = state.copyWith(phase: DonatePhase.failed, submitError: e);
    }
  }
}
