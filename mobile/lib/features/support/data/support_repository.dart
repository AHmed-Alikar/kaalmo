import 'models/support_ticket.dart';
import 'support_api.dart';

class SupportRepository {
  SupportRepository(this._api);

  final SupportApi _api;

  Future<List<SupportTicket>> myTickets() async {
    final list = await _api.myTickets();
    return list
        .whereType<Map>()
        .map((e) => SupportTicket.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<SupportTicket> getTicket(String id) async =>
      SupportTicket.fromJson(await _api.getTicket(id));

  Future<SupportTicket> createTicket({required String subject, required String message}) async =>
      SupportTicket.fromJson(await _api.createTicket(subject: subject, message: message));

  Future<SupportTicket> reply(String id, String message) async =>
      SupportTicket.fromJson(await _api.reply(id, message));
}
