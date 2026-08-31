import '../../../core/errors/app_exception.dart';
import 'beneficiary_api.dart';
import 'models/beneficiary_profile.dart';
import 'models/payout_account.dart';

/// Maps the beneficiary + payout API onto typed models. Backend authorization
/// is the source of truth for verification and payout state — nothing here is
/// derived or faked.
class BeneficiaryRepository {
  BeneficiaryRepository(this._api);

  final BeneficiaryApi _api;

  /// Returns `null` when the caller has never submitted a beneficiary profile
  /// (backend responds 404) — that is a valid "not started" state, not an error.
  Future<BeneficiaryProfile?> getMyProfile() async {
    try {
      return BeneficiaryProfile.fromJson(await _api.myProfile());
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<BeneficiaryProfile> submitProfile({required String fullName, String? idDocumentUrl}) async =>
      BeneficiaryProfile.fromJson(
        await _api.submitProfile(fullName: fullName, idDocumentUrl: idDocumentUrl),
      );

  Future<List<PayoutAccount>> myPayoutAccounts() async {
    final list = await _api.myPayoutAccounts();
    return list
        .whereType<Map>()
        .map((e) => PayoutAccount.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<PayoutAccount> createPayoutAccount({
    required String type,
    required String accountNumber,
    required String providerName,
  }) async =>
      PayoutAccount.fromJson(await _api.createPayoutAccount(
        type: type,
        accountNumber: accountNumber,
        providerName: providerName,
      ));
}
