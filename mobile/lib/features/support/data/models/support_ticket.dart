import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// Backend `SupportTicket` — `{ _id, subject, message, status, replies: [
/// { authorRole: 'user'|'admin', message, createdAt } ], createdAt, updatedAt }`.
/// `guestName`/`guestEmail` are only for anonymous submissions and are never
/// shown here (the app always submits as the signed-in user).
@immutable
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.replies,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String subject;
  final String message;

  /// `'open' | 'in_progress' | 'resolved' | 'closed'`.
  final String status;
  final List<TicketReply> replies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TicketStatusView get statusView => TicketStatusView.from(status);

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final raw = json['replies'];
    final replies = raw is List
        ? raw.whereType<Map>().map((e) => TicketReply.fromJson(e.cast<String, dynamic>())).toList()
        : <TicketReply>[];
    return SupportTicket(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      subject: '${json['subject'] ?? ''}',
      message: '${json['message'] ?? ''}',
      status: '${json['status'] ?? 'open'}',
      replies: replies,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
    );
  }
}

@immutable
class TicketReply {
  const TicketReply({required this.authorRole, required this.message, this.createdAt});

  /// `'user'` (you) or `'admin'` (support).
  final String authorRole;
  final String message;
  final DateTime? createdAt;

  bool get isMine => authorRole == 'user';

  factory TicketReply.fromJson(Map<String, dynamic> json) => TicketReply(
        authorRole: '${json['authorRole'] ?? 'user'}',
        message: '${json['message'] ?? ''}',
        createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      );
}

enum TicketStatusView {
  open,
  inProgress,
  resolved,
  closed,
  unknown;

  static TicketStatusView from(String? raw) => switch (raw) {
        'open' => open,
        'in_progress' => inProgress,
        'resolved' => resolved,
        'closed' => closed,
        _ => unknown,
      };

  bool get isActive => this == open || this == inProgress;

  String label(AppL10n l10n) => switch (this) {
        open => l10n.supportStatusOpen,
        inProgress => l10n.supportStatusInProgress,
        resolved => l10n.supportStatusResolved,
        closed => l10n.supportStatusClosed,
        unknown => l10n.supportStatusOpen,
      };

  Color get color => switch (this) {
        open => AppColors.info,
        inProgress => AppColors.warning,
        resolved => AppColors.success,
        closed => AppColors.textSecondary,
        unknown => AppColors.textSecondary,
      };
}
