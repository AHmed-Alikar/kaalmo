import 'package:share_plus/share_plus.dart';

/// Abstraction over the platform share sheet so screens don't depend on a
/// package directly and tests can assert what would be shared.
abstract interface class ShareService {
  Future<void> shareCampaign({
    required String title,
    required String excerpt,
    required String url,
  });
}

class SharePlusService implements ShareService {
  const SharePlusService();

  @override
  Future<void> shareCampaign({
    required String title,
    required String excerpt,
    required String url,
  }) {
    final body = [
      title,
      if (excerpt.trim().isNotEmpty) excerpt.trim(),
      url,
    ].join('\n\n');
    return SharePlus.instance.share(ShareParams(text: body, subject: title));
  }
}
