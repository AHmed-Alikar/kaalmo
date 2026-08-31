import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';

/// Wraps the backend device-token endpoints
/// (`POST/DELETE/GET /api/v1/devices`). All require an authenticated user.
class DeviceApi {
  DeviceApi(this._client);

  final ApiClient _client;

  /// Registers or refreshes this device's FCM token.
  /// [platform] is one of `ios` | `android` | `web`.
  Future<void> register({required String token, String? platform}) => _client.post<Map<String, dynamic>>(
        ApiRoutes.devices,
        body: {'token': token, 'platform': ?platform},
      );

  /// Removes a token (logout / "sign out this device").
  Future<void> remove(String token) =>
      _client.delete<Map<String, dynamic>>(ApiRoutes.devices, body: {'token': token});

  Future<List<Map<String, dynamic>>> list() async {
    final json = await _client.get<Map<String, dynamic>>(ApiRoutes.devices);
    final items = json['items'];
    return items is List
        ? items.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : const [];
  }
}
