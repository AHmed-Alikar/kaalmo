import '../../../core/config/app_config.dart';
import '../../../core/utils/media_url.dart';
import '../../beneficiary/data/models/beneficiary_profile.dart';
import '../../campaigns/data/models/campaign.dart';
import '../../campaigns/data/models/campaign_update.dart';
import '../../../core/errors/app_exception.dart';
import 'models/campaign_invite.dart';
import 'models/campaign_member_info.dart';
import 'organizer_api.dart';

/// Maps the organizer API onto typed models. The backend enforces every
/// authorization and lifecycle rule; this layer never second-guesses it.
class OrganizerRepository {
  OrganizerRepository(this._api, this._config);

  final OrganizerApi _api;
  final AppConfig _config;

  String _resolveMedia(String url) => resolveMediaUrl(url, _config.apiBaseUrl);

  Future<List<Campaign>> myCampaigns() async {
    final list = await _api.myCampaigns();
    return list
        .whereType<Map>()
        .map((e) => Campaign.fromJson(e.cast<String, dynamic>(), mediaUrlResolver: _resolveMedia))
        .toList();
  }

  Future<Campaign> createCampaign(Map<String, dynamic> body) async =>
      Campaign.fromJson(await _api.createCampaign(body), mediaUrlResolver: _resolveMedia);

  Future<Campaign> updateCampaign(String id, Map<String, dynamic> body) async =>
      Campaign.fromJson(await _api.updateCampaign(id, body), mediaUrlResolver: _resolveMedia);

  Future<Campaign> submitCampaign(String id) async =>
      Campaign.fromJson(await _api.submitCampaign(id), mediaUrlResolver: _resolveMedia);

  Future<Campaign> cancelCampaign(String id) async =>
      Campaign.fromJson(await _api.cancelCampaign(id), mediaUrlResolver: _resolveMedia);

  Future<void> deleteCampaign(String id) => _api.deleteCampaign(id);

  Future<CampaignUpdate> postUpdate(String id, {required String text, String? imageUrl}) async =>
      CampaignUpdate.fromJson(
        await _api.postUpdate(id, text: text, imageUrl: imageUrl),
        mediaUrlResolver: _resolveMedia,
      );

  Future<List<CampaignMemberInfo>> campaignMembers(String id) async {
    final list = await _api.campaignMembers(id);
    return list
        .whereType<Map>()
        .map((e) => CampaignMemberInfo.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// The beneficiary assigned to a campaign, or `null` when none (404).
  Future<BeneficiaryProfile?> campaignBeneficiary(String id) async {
    try {
      return BeneficiaryProfile.fromJson(await _api.campaignBeneficiary(id));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<BeneficiaryProfile> inviteBeneficiary(String id, String email) async =>
      BeneficiaryProfile.fromJson(await _api.inviteBeneficiary(id, email));

  Future<List<CampaignInvite>> myInvites() async {
    final list = await _api.myInvites();
    return list
        .whereType<Map>()
        .map((e) => CampaignInvite.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> acceptInvite(String memberId) => _api.acceptInvite(memberId);
}
