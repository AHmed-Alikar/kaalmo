import '../localization/l10n.dart';

/// Compact, localized "time ago" for comments / updates / donations.
/// Falls back to an absolute `d MMM yyyy` for anything older than ~30 days.
String formatRelative(DateTime? time, AppL10n l10n, {DateTime? now}) {
  if (time == null) return '';
  final ref = now ?? DateTime.now();
  final diff = ref.difference(time);

  if (diff.inSeconds < 60) return l10n.timeJustNow;
  if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
  if (diff.inDays < 30) return l10n.timeDaysAgo(diff.inDays);

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${time.day} ${months[time.month - 1]} ${time.year}';
}
