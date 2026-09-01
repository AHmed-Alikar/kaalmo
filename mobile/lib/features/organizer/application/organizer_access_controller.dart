import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';

/// Where the donor is in the "become an organizer" flow. Mirrors the web
/// `OrganizerOnboard` page: request a code by email, then confirm it. The
/// backend grants the `organizer` role only when [confirm] succeeds.
enum OrganizerAccessPhase { form, sending, codeSent, confirming, confirmed, error }

@immutable
class OrganizerAccessState {
  const OrganizerAccessState({
    this.phase = OrganizerAccessPhase.form,
    this.fullName = '',
    this.purpose = '',
    this.code = '',
    this.error,
    this.resent = false,
  });

  final OrganizerAccessPhase phase;
  final String fullName;
  final String purpose;
  final String code;
  final Object? error;
  final bool resent;

  bool get canSend => fullName.trim().length >= 2 && phase != OrganizerAccessPhase.sending;
  bool get canConfirm =>
      code.trim().length == 6 && phase != OrganizerAccessPhase.confirming;
  bool get isBusy =>
      phase == OrganizerAccessPhase.sending || phase == OrganizerAccessPhase.confirming;

  OrganizerAccessState copyWith({
    OrganizerAccessPhase? phase,
    String? fullName,
    String? purpose,
    String? code,
    Object? error,
    bool? resent,
    bool clearError = false,
  }) =>
      OrganizerAccessState(
        phase: phase ?? this.phase,
        fullName: fullName ?? this.fullName,
        purpose: purpose ?? this.purpose,
        code: code ?? this.code,
        error: clearError ? null : (error ?? this.error),
        resent: resent ?? this.resent,
      );
}

class OrganizerAccessController extends StateNotifier<OrganizerAccessState> {
  OrganizerAccessController(this._auth, {String initialFullName = ''})
      : super(OrganizerAccessState(fullName: initialFullName));

  final AuthController _auth;

  void setFullName(String v) => state = state.copyWith(fullName: v, clearError: true);
  void setPurpose(String v) => state = state.copyWith(purpose: v);
  void setCode(String v) =>
      state = state.copyWith(code: v.replaceAll(RegExp(r'[^0-9]'), ''), clearError: true, resent: false);

  Future<void> sendCode() async {
    if (!state.canSend) return;
    state = state.copyWith(phase: OrganizerAccessPhase.sending, clearError: true, resent: false);
    try {
      await _auth.requestOrganizerAccess(
        fullName: state.fullName.trim(),
        purpose: state.purpose.trim().isEmpty ? null : state.purpose.trim(),
      );
      if (mounted) state = state.copyWith(phase: OrganizerAccessPhase.codeSent);
    } catch (e) {
      if (mounted) state = state.copyWith(phase: OrganizerAccessPhase.error, error: e);
    }
  }

  Future<void> resendCode() async {
    if (state.isBusy) return;
    state = state.copyWith(phase: OrganizerAccessPhase.sending, clearError: true, resent: false);
    try {
      await _auth.requestOrganizerAccess(
        fullName: state.fullName.trim(),
        purpose: state.purpose.trim().isEmpty ? null : state.purpose.trim(),
      );
      if (mounted) state = state.copyWith(phase: OrganizerAccessPhase.codeSent, resent: true);
    } catch (e) {
      if (mounted) state = state.copyWith(phase: OrganizerAccessPhase.codeSent, error: e);
    }
  }

  /// Returns true when the account is now an organizer. The confirm call flips
  /// the auth user to organizer, which can rebuild the hosting screen — guard
  /// the post-await state write.
  Future<bool> confirm() async {
    if (!state.canConfirm) return false;
    state = state.copyWith(phase: OrganizerAccessPhase.confirming, clearError: true);
    try {
      await _auth.confirmOrganizerAccess(state.code.trim());
      if (mounted) state = state.copyWith(phase: OrganizerAccessPhase.confirmed);
      return true;
    } catch (e) {
      if (mounted) state = state.copyWith(phase: OrganizerAccessPhase.codeSent, error: e);
      return false;
    }
  }

  /// Back to the request form (e.g. wrong email details).
  void editRequest() =>
      state = state.copyWith(phase: OrganizerAccessPhase.form, code: '', clearError: true);
}
