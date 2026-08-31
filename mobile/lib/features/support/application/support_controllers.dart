import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/support_ticket.dart';
import '../data/support_repository.dart';

/// Backend limits (`supportTicketValidators.js`).
const kTicketSubjectMin = 3;
const kTicketSubjectMax = 200;
const kTicketMessageMin = 5;
const kTicketMessageMax = 2000;
const kTicketReplyMax = 2000;

enum SubmitPhase { editing, submitting, done, error }

// --- New ticket -------------------------------------------------------------

@immutable
class NewTicketState {
  const NewTicketState({
    this.subject = '',
    this.message = '',
    this.phase = SubmitPhase.editing,
    this.error,
    this.created,
  });

  final String subject;
  final String message;
  final SubmitPhase phase;
  final Object? error;
  final SupportTicket? created;

  bool get subjectValid {
    final s = subject.trim().length;
    return s >= kTicketSubjectMin && s <= kTicketSubjectMax;
  }

  bool get messageValid {
    final m = message.trim().length;
    return m >= kTicketMessageMin && m <= kTicketMessageMax;
  }

  bool get submitting => phase == SubmitPhase.submitting;
  bool get canSubmit => subjectValid && messageValid && !submitting;

  NewTicketState copyWith({
    String? subject,
    String? message,
    SubmitPhase? phase,
    Object? error,
    SupportTicket? created,
    bool clearError = false,
  }) =>
      NewTicketState(
        subject: subject ?? this.subject,
        message: message ?? this.message,
        phase: phase ?? this.phase,
        error: clearError ? null : (error ?? this.error),
        created: created ?? this.created,
      );
}

class NewTicketController extends StateNotifier<NewTicketState> {
  NewTicketController(this._repo) : super(const NewTicketState());

  final SupportRepository _repo;

  void setSubject(String v) => state = state.copyWith(subject: v, clearError: true);
  void setMessage(String v) => state = state.copyWith(message: v, clearError: true);

  Future<SupportTicket?> submit() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(phase: SubmitPhase.submitting, clearError: true);
    try {
      final ticket = await _repo.createTicket(
        subject: state.subject.trim(),
        message: state.message.trim(),
      );
      state = state.copyWith(phase: SubmitPhase.done, created: ticket);
      return ticket;
    } catch (e) {
      state = state.copyWith(phase: SubmitPhase.error, error: e);
      return null;
    }
  }
}

// --- Reply to a ticket -----------------------------------------------------

@immutable
class TicketReplyState {
  const TicketReplyState({this.text = '', this.phase = SubmitPhase.editing, this.error});

  final String text;
  final SubmitPhase phase;
  final Object? error;

  bool get valid {
    final t = text.trim().length;
    return t >= 1 && t <= kTicketReplyMax;
  }

  bool get submitting => phase == SubmitPhase.submitting;
  bool get canSubmit => valid && !submitting;

  TicketReplyState copyWith({String? text, SubmitPhase? phase, Object? error, bool clearError = false}) =>
      TicketReplyState(
        text: text ?? this.text,
        phase: phase ?? this.phase,
        error: clearError ? null : (error ?? this.error),
      );
}

class TicketReplyController extends StateNotifier<TicketReplyState> {
  TicketReplyController(this._repo, this._ticketId) : super(const TicketReplyState());

  final SupportRepository _repo;
  final String _ticketId;

  void setText(String v) => state = state.copyWith(text: v, clearError: true);

  /// Returns the refreshed ticket on success.
  Future<SupportTicket?> submit() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(phase: SubmitPhase.submitting, clearError: true);
    try {
      final updated = await _repo.reply(_ticketId, state.text.trim());
      state = const TicketReplyState(phase: SubmitPhase.done);
      return updated;
    } catch (e) {
      state = state.copyWith(phase: SubmitPhase.error, error: e);
      return null;
    }
  }
}
