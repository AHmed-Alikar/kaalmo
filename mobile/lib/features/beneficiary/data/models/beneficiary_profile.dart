import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// `GET /api/v1/beneficiaries/me`. The backend returns 404 when the caller has
/// never submitted a beneficiary profile — the repository maps that to `null`.
@immutable
class BeneficiaryProfile {
  const BeneficiaryProfile({
    required this.id,
    required this.fullName,
    required this.verificationStatus,
    this.idDocumentUrl,
    this.reviewNote,
    this.campaignTitle,
    this.inviteEmail,
    this.verifiedAt,
    this.payoutAccountId,
  });

  final String id;
  final String fullName;

  /// The email the organizer invited (organizer-facing view).
  final String? inviteEmail;

  /// `invited` | `accepted` | `pending` | `verified` | `rejected` | `needs_more_information`.
  final String verificationStatus;
  final String? idDocumentUrl;

  /// Admin's note for a `rejected` / `needs_more_information` decision.
  final String? reviewNote;

  /// Title of the campaign this beneficiary was invited to (populated).
  final Map<String, dynamic>? campaignTitle;
  final DateTime? verifiedAt;

  /// Set by an admin when a payout account is linked to the verified profile —
  /// there is no self-service API for this yet.
  final String? payoutAccountId;

  bool get isVerified => verificationStatus == 'verified';
  bool get isRejected => verificationStatus == 'rejected';
  bool get isPending => verificationStatus == 'pending';
  bool get needsMoreInfo => verificationStatus == 'needs_more_information';

  /// The beneficiary may (re)submit their details. `invited` is excluded — the
  /// invitation must be explicitly accepted first (mirrors the backend's
  /// SUBMITTABLE list in beneficiaryController).
  bool get canSubmit =>
      verificationStatus == 'accepted' ||
      verificationStatus == 'pending' ||
      verificationStatus == 'rejected' ||
      verificationStatus == 'needs_more_information';

  bool get hasLinkedPayoutAccount => (payoutAccountId ?? '').isNotEmpty;

  /// Fully ready for a withdrawal request (mirrors the backend precondition in
  /// withdrawalController: verified identity **and** a linked payout account).
  bool get payoutReady => isVerified && hasLinkedPayoutAccount;

  BeneficiaryStatusView get statusView => BeneficiaryStatusView.from(verificationStatus);

  factory BeneficiaryProfile.fromJson(Map<String, dynamic> json) {
    final camp = json['campaignId'];
    return BeneficiaryProfile(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      fullName: '${json['fullName'] ?? ''}',
      verificationStatus: '${json['verificationStatus'] ?? 'pending'}',
      idDocumentUrl: (json['idDocumentUrl'] as String?)?.trim().isNotEmpty == true
          ? json['idDocumentUrl'] as String
          : null,
      reviewNote: (json['reviewNote'] as String?)?.trim().isNotEmpty == true
          ? json['reviewNote'] as String
          : null,
      campaignTitle: camp is Map && camp['title'] is Map
          ? (camp['title'] as Map).cast<String, dynamic>()
          : null,
      inviteEmail: (json['inviteEmail'] as String?)?.trim().isNotEmpty == true
          ? json['inviteEmail'] as String
          : (json['userId'] is Map ? (json['userId'] as Map)['email'] as String? : null),
      verifiedAt: DateTime.tryParse('${json['verifiedAt'] ?? ''}'),
      payoutAccountId: '${json['payoutAccountId'] ?? ''}'.isEmpty ? null : '${json['payoutAccountId']}',
    );
  }
}

enum BeneficiaryStatusView {
  none,
  invited,
  accepted,
  pending,
  verified,
  rejected,
  needsMoreInfo;

  static BeneficiaryStatusView from(String? raw) => switch (raw) {
        'verified' => verified,
        'rejected' => rejected,
        'pending' => pending,
        'invited' => invited,
        'accepted' => accepted,
        'needs_more_information' => needsMoreInfo,
        _ => none,
      };

  String label(AppL10n l10n) => switch (this) {
        none => l10n.beneficiaryStatusNone,
        invited => l10n.beneficiaryStatusInvited,
        accepted => l10n.beneficiaryStatusAccepted,
        pending => l10n.beneficiaryStatusPending,
        verified => l10n.beneficiaryStatusVerified,
        rejected => l10n.beneficiaryStatusRejected,
        needsMoreInfo => l10n.beneficiaryStatusNeedsInfo,
      };

  Color get color => switch (this) {
        verified => AppColors.success,
        pending || accepted => AppColors.warning,
        rejected => AppColors.error,
        needsMoreInfo => AppColors.warning,
        invited => AppColors.info,
        none => AppColors.textSecondary,
      };

  IconData get icon => switch (this) {
        verified => Icons.verified_outlined,
        pending => Icons.hourglass_bottom,
        rejected => Icons.cancel_outlined,
        needsMoreInfo => Icons.info_outline,
        invited => Icons.mail_outline,
        accepted => Icons.how_to_reg_outlined,
        none => Icons.badge_outlined,
      };
}
