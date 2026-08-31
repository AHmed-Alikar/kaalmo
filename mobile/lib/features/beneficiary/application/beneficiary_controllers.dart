import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/beneficiary_repository.dart';
import '../data/models/beneficiary_profile.dart';
import '../data/models/payout_account.dart';

enum FormPhase { editing, submitting, done, error }

// --- Beneficiary identity (`POST /beneficiaries/me`) ---------------------

/// Backend: `fullName` 2–100 chars.
const kBeneficiaryNameMin = 2;
const kBeneficiaryNameMax = 100;

@immutable
class BeneficiaryIdentityState {
  const BeneficiaryIdentityState({this.fullName = '', this.phase = FormPhase.editing, this.error});

  final String fullName;
  final FormPhase phase;
  final Object? error;

  bool get nameValid {
    final n = fullName.trim();
    return n.length >= kBeneficiaryNameMin && n.length <= kBeneficiaryNameMax;
  }

  bool get submitting => phase == FormPhase.submitting;
  bool get canSubmit => nameValid && !submitting;

  BeneficiaryIdentityState copyWith({String? fullName, FormPhase? phase, Object? error, bool clearError = false}) =>
      BeneficiaryIdentityState(
        fullName: fullName ?? this.fullName,
        phase: phase ?? this.phase,
        error: clearError ? null : (error ?? this.error),
      );
}

class BeneficiaryIdentityController extends StateNotifier<BeneficiaryIdentityState> {
  BeneficiaryIdentityController(this._repo, {String initialName = ''})
      : super(BeneficiaryIdentityState(fullName: initialName));

  final BeneficiaryRepository _repo;

  void setName(String v) => state = state.copyWith(fullName: v, clearError: true);

  Future<BeneficiaryProfile?> submit() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(phase: FormPhase.submitting, clearError: true);
    try {
      final profile = await _repo.submitProfile(fullName: state.fullName.trim());
      state = state.copyWith(phase: FormPhase.done);
      return profile;
    } catch (e) {
      state = state.copyWith(phase: FormPhase.error, error: e);
      return null;
    }
  }
}

// --- Payout account (`POST /payout-accounts`) ---------------------------

/// Backend: `type` mobile_money|bank, `accountNumber` 4–30, `providerName` 2–60.
@immutable
class PayoutAccountFormState {
  const PayoutAccountFormState({
    this.type = 'mobile_money',
    this.accountNumber = '',
    this.providerName = '',
    this.phase = FormPhase.editing,
    this.error,
  });

  final String type;
  final String accountNumber;
  final String providerName;
  final FormPhase phase;
  final Object? error;

  bool get accountValid {
    final a = accountNumber.trim();
    return a.length >= 4 && a.length <= 30;
  }

  bool get providerValid {
    final p = providerName.trim();
    return p.length >= 2 && p.length <= 60;
  }

  bool get submitting => phase == FormPhase.submitting;
  bool get canSubmit => accountValid && providerValid && !submitting;

  PayoutAccountFormState copyWith({
    String? type,
    String? accountNumber,
    String? providerName,
    FormPhase? phase,
    Object? error,
    bool clearError = false,
  }) =>
      PayoutAccountFormState(
        type: type ?? this.type,
        accountNumber: accountNumber ?? this.accountNumber,
        providerName: providerName ?? this.providerName,
        phase: phase ?? this.phase,
        error: clearError ? null : (error ?? this.error),
      );
}

class PayoutAccountFormController extends StateNotifier<PayoutAccountFormState> {
  PayoutAccountFormController(this._repo) : super(const PayoutAccountFormState());

  final BeneficiaryRepository _repo;

  void setType(String v) => state = state.copyWith(type: v, clearError: true);
  void setAccountNumber(String v) => state = state.copyWith(accountNumber: v, clearError: true);
  void setProviderName(String v) => state = state.copyWith(providerName: v, clearError: true);

  Future<PayoutAccount?> submit() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(phase: FormPhase.submitting, clearError: true);
    try {
      final account = await _repo.createPayoutAccount(
        type: state.type,
        accountNumber: state.accountNumber.trim(),
        providerName: state.providerName.trim(),
      );
      state = state.copyWith(phase: FormPhase.done);
      return account;
    } catch (e) {
      state = state.copyWith(phase: FormPhase.error, error: e);
      return null;
    }
  }
}
