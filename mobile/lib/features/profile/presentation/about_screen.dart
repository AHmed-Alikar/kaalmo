import 'package:flutter/material.dart';

import '../../../core/localization/l10n.dart';

/// `/profile/settings/about` — a short "About Kaalmo" with pointers to the full
/// legal pages on the web (no in-app browser dependency).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(l10n.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(l10n.aboutTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Text(l10n.aboutBody, style: const TextStyle(fontSize: 13.5, height: 1.5)),
            const SizedBox(height: 24),
            Text(l10n.aboutLegalHeading,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _LegalRow(label: l10n.aboutTerms, url: 'kaalmo.example/terms'),
            _LegalRow(label: l10n.aboutPrivacy, url: 'kaalmo.example/privacy'),
            _LegalRow(label: l10n.aboutContact, url: 'kaalmo.example/contact'),
          ],
        ),
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 2),
          SelectableText(url, style: TextStyle(fontSize: 12.5, color: scheme.primary)),
        ],
      ),
    );
  }
}
