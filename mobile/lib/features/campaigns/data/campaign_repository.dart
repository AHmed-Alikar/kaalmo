import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/media_url.dart';
import 'campaign_api.dart';
import 'models/campaign.dart';
import 'models/campaign_comment.dart';
import 'models/campaign_interactions.dart';
import 'models/campaign_update.dart';
import 'models/platform_stats.dart';
import 'models/supporter.dart';

/// Maps the campaign API onto typed models. Resolves dev image hostnames so
/// the device can load images. No caching here — controllers keep their own
/// state; Riverpod caches read-only providers.
class CampaignRepository {
  CampaignRepository(this._api, this._config);

  final CampaignApi _api;
  final AppConfig _config;

  String _resolveMedia(String url) => resolveMediaUrl(url, _config.apiBaseUrl);

  // --- Discovery ---

  Future<CampaignPage> list({
    String? category,
    String? region,
    String? query,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final json = await _api.listCampaigns(
      category: category,
      region: region,
      query: query,
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
    return CampaignPage.fromJson(json, mediaUrlResolver: _resolveMedia);
  }

  Future<PlatformStats> stats() async => PlatformStats.fromJson(await _api.stats());

  // --- Detail ---

  Future<Campaign> getCampaign(String id) async =>
      Campaign.fromJson(await _api.getCampaign(id), mediaUrlResolver: _resolveMedia);

  Future<List<CampaignUpdate>> getUpdates(String id) async {
    final list = await _api.getUpdates(id);
    return list
        .whereType<Map>()
        .map((e) => CampaignUpdate.fromJson(e.cast<String, dynamic>(), mediaUrlResolver: _resolveMedia))
        .toList();
  }

  Future<List<CampaignComment>> getComments(String id) async {
    final list = await _api.getComments(id);
    return list
        .whereType<Map>()
        .map((e) => CampaignComment.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<CampaignComment> postComment(String id, String text) async =>
      CampaignComment.fromJson(await _api.postComment(id, text));

  Future<SupporterList> getSupporters(String id, {int limit = 30}) async =>
      SupporterList.fromJson(await _api.getSupporters(id, limit: limit));

  // --- Interactions ---

  Future<CampaignInteractions> getInteractions(String id) async =>
      CampaignInteractions.fromJson(await _api.getInteractions(id));

  Future<bool> setFollowing(String id, bool value) async {
    final json = value ? await _api.follow(id) : await _api.unfollow(id);
    return json['following'] == true;
  }

  Future<bool> setSaved(String id, bool value) async {
    final json = value ? await _api.save(id) : await _api.unsave(id);
    return json['saved'] == true;
  }

  // --- Trust & safety ---

  Future<void> reportCampaign(String id, String reason) =>
      _api.report(targetType: 'campaign', targetId: id, reason: reason);
}
