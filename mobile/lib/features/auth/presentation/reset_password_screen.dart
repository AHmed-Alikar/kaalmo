import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/auth/auth_error_banner.dart';
import '../../../shared/auth/auth_scaffold.dart';
import '../../../shared/auth/otp_input.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/inputs/app_text_field.dart';
import '../../../shared/inputs/password_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail ?? '');
  final _code = TextEditingController();
  final _password = TextEditingController();

  bool _submitting = false;
  bool _done = false;
  String? _formError;
  String? _emailError;
  String? _codeError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final emailError = Validators.email(_email.text, l10n);
    final codeError = Validators.code6(_code.text, l10n);
    final passwordError = Validators.password(_password.text, l10n);
    setState(() {
      _emailError = emailError;
      _codeError = codeError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || codeError != null || passwordError != null || _submitting) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
            email: _email.text.trim(),
            code: _code.text.trim(),
            password: _password.text,
          );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is ApiException && e.code == 'INVALID_CODE') {
            _codeError = l10n.resetPasswordInvalidCode;
          } else {
            _formError = presentError(e, l10n);
            fieldErrorsOf(e).forEach((k, v) {
              if (k == 'password') _passwordError = v;
              if (k == 'email') _emailError = v;
            });
          }
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_done) {
      return AuthScaffold(
        title: l10n.resetPasswordSuccessTitle,
        subtitle: l10n.resetPasswordSuccessBody,
        showBack: false,
        children: [
          const SizedBox(height: 8),
          PrimaryButton(
            label: l10n.resetPasswordBackToLogin,
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: l10n.resetPasswordTitle,
      subtitle: l10n.resetPasswordSubtitle,
      children: [
        AuthErrorBanner(_formError),
        AppTextField(
          label: l10n.fieldEmail,
          controller: _email,
          hintText: l10n.fieldEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.mail_outline,
          errorText: _emailError,
          enabled: !_submitting,
        ),
        const SizedBox(height: 16),
        Text(l10n.fieldResetCode, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        OtpInput(controller: _code, errorText: _codeError, enabled: !_submitting),
        const SizedBox(height: 16),
        PasswordField(
          label: l10n.fieldNewPassword,
          controller: _password,
          hintText: l10n.fieldPasswordHint,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: _passwordError,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.resetPasswordAction,
          isLoading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
