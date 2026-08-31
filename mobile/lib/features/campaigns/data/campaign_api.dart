import 'package:dio/dio.dart';

import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';

/// Raw HTTP for campaigns. Discovery + detail endpoints are public;
/// interaction endpoints (follow / save / comment) require auth and the
/// interceptor attaches the token.
class CampaignApi {
  CampaignApi(this._client);

  final ApiClient _client;

  // --- Discovery ---

  Future<Map<String, dynamic>> listCampaigns({
    String? category,
    String? region,
    String? query,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    final q = query?.trim();
    return _client.get<Map<String, dynamic>>(
      ApiRoutes.campaigns,
      cancelToken: cancelToken,
      query: {
        'page': page,
        'limit': limit,
        if (category != null && category.isNotEmpty) 'category': category,
        if (region != null && region.isNotEmpty) 'region': region,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
  }

  Future<Map<String, dynamic>> stats() =>
      _client.get<Map<String, dynamic>>(ApiRoutes.campaignsStats);

  // --- Detail ---

  /// `GET /api/v1/campaigns/:id` — 404 for a non-public campaign the caller
  /// cannot see.
  Future<Map<String, dynamic>> getCampaign(String id) =>
      _client.get<Map<String, dynamic>>(ApiRoutes.campaign(id));

  /// `GET /api/v1/campaigns/:id/updates` — newest-first, no pagination.
  Future<List<dynamic>> getUpdates(String id) =>
      _client.get<List<dynamic>>(ApiRoutes.campaignUpdates(id));

  /// `GET /api/v1/campaigns/:id/comments` — newest-first, no pagination.
  Future<List<dynamic>> getComments(String id) =>
      _client.get<List<dynamic>>(ApiRoutes.campaignComments(id));

  /// `POST /api/v1/campaigns/:id/comments` — `{ text }` (1–1000). Auth.
  Future<Map<String, dynamic>> postComment(String id, String text) => _client.post<Map<String, dynamic>>(
        ApiRoutes.campaignComments(id),
        body: {'text': text},
      );

  /// `GET /api/v1/campaigns/:id/donations?limit=N` — recent confirmed
  /// donations + `supporterCount`.
  Future<Map<String, dynamic>> getSupporters(String id, {int limit = 30}) =>
      _client.get<Map<String, dynamic>>(
        ApiRoutes.campaignDonations(id),
        query: {'limit': limit},
      );

  // --- Interactions (auth) ---

  Future<Map<String, dynamic>> getInteractions(String id) =>
      _client.get<Map<String, dynamic>>(ApiRoutes.campaignInteractions(id));

  Future<Map<String, dynamic>> follow(String id) =>
      _client.post<Map<String, dynamic>>(ApiRoutes.campaignFollow(id));

  Future<Map<String, dynamic>> unfollow(String id) =>
      _client.delete<Map<String, dynamic>>(ApiRoutes.campaignFollow(id));

  Future<Map<String, dynamic>> save(String id) =>
      _client.post<Map<String, dynamic>>(ApiRoutes.campaignSave(id));

  Future<Map<String, dynamic>> unsave(String id) =>
      _client.delete<Map<String, dynamic>>(ApiRoutes.campaignSave(id));

  // --- Trust & safety (auth) ---

  /// `POST /api/v1/reports` — `{ targetType, targetId, reason }`.
  Future<Map<String, dynamic>> report({
    required String targetType,
    required String targetId,
    required String reason,
  }) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.reports,
        body: {'targetType': targetType, 'targetId': targetId, 'reason': reason},
      );
}
