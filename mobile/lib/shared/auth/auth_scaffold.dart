import 'package:flutter/material.dart';

import '../../core/localization/l10n.dart';
import '../../core/theme/app_colors.dart';

/// Shared layout for every auth screen: Kaalmo mark, title, subtitle, a
/// scrollable body, and an optional bottom row (e.g. "Already have an
/// account?  Log in"). Keeps the screens themselves free of chrome.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.footer,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandMark(),
                      const SizedBox(height: 28),
                      Text(title,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ...children,
                      if (footer != null) ...[
                        const Spacer(),
                        const SizedBox(height: 24),
                        Center(child: footer!),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          context.l10n.appName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ],
    );
  }
}

/// Bottom "prompt + action" row shared by login/register.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({super.key, required this.prompt, required this.actionLabel, required this.onTap});

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt, style: Theme.of(context).textTheme.bodyMedium),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}
