import 'package:kaalmo_mobile/core/share/share_service.dart';

class FakeShareService implements ShareService {
  final List<Map<String, String>> calls = [];

  @override
  Future<void> shareCampaign({
    required String title,
    required String excerpt,
    required String url,
  }) async {
    calls.add({'title': title, 'excerpt': excerpt, 'url': url});
  }
}
