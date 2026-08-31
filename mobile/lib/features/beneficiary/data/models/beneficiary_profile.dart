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
    this.verifiedAt,
    this.payoutAccountId,
  });

  final String id;
  final String fullName;

  /// `'pending'` | `'verified'` | `'rejected'`.
  final String verificationStatus;
  final String? idDocumentUrl;
  final DateTime? verifiedAt;

  /// Set by an admin when a payout account is linked to the verified profile —
  /// there is no self-service API for this yet.
  final String? payoutAccountId;

  bool get isVerified => verificationStatus == 'verified';
  bool get isRejected => verificationStatus == 'rejected';
  bool get isPending => verificationStatus == 'pending';
  bool get hasLinkedPayoutAccount => (payoutAccountId ?? '').isNotEmpty;

  /// Fully ready for a withdrawal request (mirrors the backend precondition in
  /// withdrawalController: verified identity **and** a linked payout account).
  bool get payoutReady => isVerified && hasLinkedPayoutAccount;

  BeneficiaryStatusView get statusView => BeneficiaryStatusView.from(verificationStatus);

  factory BeneficiaryProfile.fromJson(Map<String, dynamic> json) => BeneficiaryProfile(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        fullName: '${json['fullName'] ?? ''}',
        verificationStatus: '${json['verificationStatus'] ?? 'pending'}',
        idDocumentUrl: (json['idDocumentUrl'] as String?)?.trim().isNotEmpty == true
            ? json['idDocumentUrl'] as String
            : null,
        verifiedAt: DateTime.tryParse('${json['verifiedAt'] ?? ''}'),
        payoutAccountId: '${json['payoutAccountId'] ?? ''}'.isEmpty ? null : '${json['payoutAccountId']}',
      );
}

enum BeneficiaryStatusView {
  none,
  pending,
  verified,
  rejected;

  static BeneficiaryStatusView from(String? raw) => switch (raw) {
        'verified' => verified,
        'rejected' => rejected,
        'pending' => pending,
        _ => none,
      };

  String label(AppL10n l10n) => switch (this) {
        none => l10n.beneficiaryStatusNone,
        pending => l10n.beneficiaryStatusPending,
        verified => l10n.beneficiaryStatusVerified,
        rejected => l10n.beneficiaryStatusRejected,
      };

  Color get color => switch (this) {
        verified => AppColors.success,
        pending => AppColors.warning,
        rejected => AppColors.error,
        none => AppColors.textSecondary,
      };

  IconData get icon => switch (this) {
        verified => Icons.verified_outlined,
        pending => Icons.hourglass_bottom,
        rejected => Icons.cancel_outlined,
        none => Icons.badge_outlined,
      };
}
