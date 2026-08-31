import '../../../core/config/app_config.dart';
import '../../../core/utils/media_url.dart';
import 'donation_api.dart';
import 'models/donation_result.dart';
import 'models/my_donation.dart';
import 'models/payment_config.dart';

/// Maps the donation API onto typed models. The backend stays the source of
/// truth for amount, fees, payment status and campaign balance — this layer
/// never computes or fakes any of those.
class DonationRepository {
  DonationRepository(this._api, this._config);

  final DonationApi _api;
  final AppConfig _config;

  String _resolveMedia(String url) => resolveMediaUrl(url, _config.apiBaseUrl);

  Future<PaymentConfig> getPaymentConfig() async =>
      PaymentConfig.fromJson(await _api.paymentConfig());

  Future<DonationResult> donate({
    required String campaignId,
    required num amount,
    required String provider,
    String? phone,
    String? message,
    required bool isAnonymous,
    required String idempotencyKey,
  }) async {
    final json = await _api.donate(
      campaignId,
      amount: amount,
      provider: provider,
      phone: phone,
      message: message,
      isAnonymous: isAnonymous,
      idempotencyKey: idempotencyKey,
    );
    return DonationResult.fromJson(json);
  }

  /// `GET /api/v1/donations/mine` — the caller's donations, newest-first, no
  /// pagination. A malformed / non-object entry is skipped rather than throwing.
  Future<List<MyDonation>> getMyDonations() async {
    final list = await _api.myDonations();
    return list
        .whereType<Map>()
        .map((e) => MyDonation.fromJson(e.cast<String, dynamic>(), mediaUrlResolver: _resolveMedia))
        .toList();
  }
}
