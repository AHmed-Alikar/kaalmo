import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';

/// Raw HTTP for support tickets. Existing backend contracts only.
class SupportApi {
  SupportApi(this._client);

  final ApiClient _client;

  /// `GET /api/v1/support-tickets/mine` — newest-activity first, no pagination.
  Future<List<dynamic>> myTickets() =>
      _client.get<List<dynamic>>(ApiRoutes.supportTicketsMine);

  /// `GET /api/v1/support-tickets/mine/:id`.
  Future<Map<String, dynamic>> getTicket(String id) =>
      _client.get<Map<String, dynamic>>(ApiRoutes.supportTicket(id));

  /// `POST /api/v1/support-tickets` — `{ subject (3–200), message (5–2000) }`.
  /// The signed-in user's ticket is tied to their account automatically.
  Future<Map<String, dynamic>> createTicket({required String subject, required String message}) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.supportTickets,
        body: {'subject': subject, 'message': message},
      );

  /// `POST /api/v1/support-tickets/mine/:id/replies` — `{ message (1–2000) }`.
  Future<Map<String, dynamic>> reply(String id, String message) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.supportTicketReplies(id),
        body: {'message': message},
      );
}
