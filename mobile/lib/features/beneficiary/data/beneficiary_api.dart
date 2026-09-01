import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';

/// Raw HTTP for the beneficiary + payout-account experience. Existing backend
/// contracts only — no new endpoints.
class BeneficiaryApi {
  BeneficiaryApi(this._client);

  final ApiClient _client;

  /// `GET /api/v1/beneficiaries/me` — 404 when no profile has been submitted.
  Future<Map<String, dynamic>> myProfile() =>
      _client.get<Map<String, dynamic>>(ApiRoutes.beneficiaryMe);

  /// `POST /api/v1/beneficiaries/me` — `{ fullName (2–100), idDocumentUrl? }`.
  /// Creates / updates a `pending` record; an admin still verifies it.
  Future<Map<String, dynamic>> submitProfile({required String fullName, String? idDocumentUrl}) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.beneficiaryMe,
        body: {
          'fullName': fullName,
          if (idDocumentUrl != null && idDocumentUrl.isNotEmpty) 'idDocumentUrl': idDocumentUrl,
        },
      );

  /// `GET /api/v1/beneficiaries/invites/mine` — pending beneficiary invitations
  /// addressed to the caller's email.
  Future<List<dynamic>> myInvites() =>
      _client.get<List<dynamic>>(ApiRoutes.beneficiaryInvitesMine);

  /// `POST /api/v1/beneficiaries/invites/:id/accept`.
  Future<Map<String, dynamic>> acceptInvite(String id) =>
      _client.post<Map<String, dynamic>>(ApiRoutes.beneficiaryInviteAccept(id));

  /// `GET /api/v1/payout-accounts/mine`.
  Future<List<dynamic>> myPayoutAccounts() =>
      _client.get<List<dynamic>>(ApiRoutes.payoutAccountsMine);

  /// `POST /api/v1/payout-accounts` — `{ type, accountNumber (4–30), providerName (2–60) }`.
  Future<Map<String, dynamic>> createPayoutAccount({
    required String type,
    required String accountNumber,
    required String providerName,
  }) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.payoutAccounts,
        body: {'type': type, 'accountNumber': accountNumber, 'providerName': providerName},
      );
}
