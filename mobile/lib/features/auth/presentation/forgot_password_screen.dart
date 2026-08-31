import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/auth/auth_error_banner.dart';
import '../../../shared/auth/auth_scaffold.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/buttons/secondary_button.dart';
import '../../../shared/inputs/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();

  bool _submitting = false;
  bool _sent = false;
  String? _formError;
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final emailError = Validators.email(_email.text, l10n);
    setState(() {
      _emailError = emailError;
      _formError = null;
    });
    if (emailError != null || _submitting) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(_email.text.trim());
      // Backend responds identically whether or not the email exists.
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _formError = presentError(e, l10n));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goToReset() {
    context.push('${AppRoutes.resetPassword}?email=${Uri.encodeQueryComponent(_email.text.trim())}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_sent) {
      return AuthScaffold(
        title: l10n.forgotPasswordSentTitle,
        subtitle: l10n.forgotPasswordSentBody,
        children: [
          const SizedBox(height: 8),
          PrimaryButton(label: l10n.forgotPasswordEnterCode, onPressed: _goToReset),
          const SizedBox(height: 12),
          SecondaryButton(
            label: l10n.resetPasswordBackToLogin,
            onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.forgotPasswordSubtitle,
      children: [
        AuthErrorBanner(_formError),
        AppTextField(
          label: l10n.fieldEmail,
          controller: _email,
          hintText: l10n.fieldEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          prefixIcon: Icons.mail_outline,
          errorText: _emailError,
          enabled: !_submitting,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.forgotPasswordAction,
          isLoading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
