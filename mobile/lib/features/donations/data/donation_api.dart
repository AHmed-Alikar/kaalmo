import 'package:dio/dio.dart';

import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';

/// Raw HTTP for the donation + payment flow. All contracts are the existing
/// backend's — no mobile-specific endpoints.
class DonationApi {
  DonationApi(this._client);

  final ApiClient _client;

  /// `GET /api/v1/payments/config` — public.
  Future<Map<String, dynamic>> paymentConfig() =>
      _client.get<Map<String, dynamic>>(ApiRoutes.paymentConfig);

  /// `POST /api/v1/campaigns/:id/donate`.
  ///
  /// [idempotencyKey] is sent as the `Idempotency-Key` header so a retried
  /// attempt returns the original result instead of charging twice.
  Future<Map<String, dynamic>> donate(
    String campaignId, {
    required num amount,
    required String provider,
    String? phone,
    String? message,
    required bool isAnonymous,
    required String idempotencyKey,
  }) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.campaignDonate(campaignId),
        body: {
          'amount': amount,
          'provider': provider,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
          'isAnonymous': isAnonymous,
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );

  /// `GET /api/v1/donations/mine` — the signed-in donor's history (used for the
  /// receipt fallback / "my donations").
  Future<List<dynamic>> myDonations() =>
      _client.get<List<dynamic>>(ApiRoutes.donationsMine);
}
