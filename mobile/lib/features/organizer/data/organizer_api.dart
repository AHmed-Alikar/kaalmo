import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';

/// Raw HTTP for organizer campaign management. All contracts are the existing
/// backend's — no organizer-specific endpoints were added.
class OrganizerApi {
  OrganizerApi(this._client);

  final ApiClient _client;

  /// `GET /api/v1/campaigns/mine` — owned + accepted co-organized campaigns,
  /// newest-first, each tagged with `access`. No pagination.
  Future<List<dynamic>> myCampaigns() =>
      _client.get<List<dynamic>>(ApiRoutes.campaignsMine);

  /// `PATCH /api/v1/campaigns/:id` — partial update (`updateCampaignSchema`).
  Future<Map<String, dynamic>> updateCampaign(String id, Map<String, dynamic> body) =>
      _client.patch<Map<String, dynamic>>(ApiRoutes.campaign(id), body: body);

  /// `POST /api/v1/campaigns/:id/submit` — `draft → submitted`.
  Future<Map<String, dynamic>> submitCampaign(String id) =>
      _client.post<Map<String, dynamic>>(ApiRoutes.campaignSubmit(id));

  /// `POST /api/v1/campaigns/:id/cancel` — `draft|submitted → cancelled`.
  Future<Map<String, dynamic>> cancelCampaign(String id) =>
      _client.post<Map<String, dynamic>>(ApiRoutes.campaignCancel(id));

  /// `DELETE /api/v1/campaigns/:id` — draft only.
  Future<Map<String, dynamic>> deleteCampaign(String id) =>
      _client.delete<Map<String, dynamic>>(ApiRoutes.campaign(id));

  /// `POST /api/v1/campaigns/:id/updates` — `{ text (min 10), imageUrl? }`.
  Future<Map<String, dynamic>> postUpdate(String id, {required String text, String? imageUrl}) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.campaignUpdates(id),
        body: {
          'text': text,
          if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        },
      );

  /// `GET /api/v1/campaigns/:id/members` — organizer-only team list.
  Future<List<dynamic>> campaignMembers(String id) =>
      _client.get<List<dynamic>>(ApiRoutes.campaignMembers(id));

  /// `GET /api/v1/campaign-invites/mine` — pending co-organizer invitations.
  Future<List<dynamic>> myInvites() =>
      _client.get<List<dynamic>>(ApiRoutes.campaignInvitesMine);

  /// `POST /api/v1/campaign-invites/:memberId/accept`.
  Future<Map<String, dynamic>> acceptInvite(String memberId) =>
      _client.post<Map<String, dynamic>>(ApiRoutes.campaignInviteAccept(memberId));
}
