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
import '../../../shared/buttons/app_text_button.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/inputs/app_text_field.dart';
import '../../../shared/inputs/password_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _submitting = false;
  String? _formError;
  String? _emailError;
  String? _passwordError;
  bool _showSessionExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authControllerProvider);
      if (auth.sessionExpired) {
        setState(() => _showSessionExpired = true);
        ref.read(authControllerProvider.notifier).acknowledgeSessionExpired();
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final emailError = Validators.email(_email.text, l10n);
    final passwordError = Validators.required(_password.text, l10n);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null || _submitting) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _email.text.trim(),
            password: _password.text,
          );
      // On success the auth state flips and GoRouter redirects; nothing to do.
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = presentError(e, l10n);
          final fields = fieldErrorsOf(e);
          _emailError = fields['email'] ?? _emailError;
          _passwordError = fields['password'] ?? _passwordError;
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      title: l10n.authWelcomeBack,
      subtitle: l10n.authLoginSubtitle,
      showBack: false,
      footer: AuthSwitchPrompt(
        prompt: l10n.authNoAccountPrompt,
        actionLabel: l10n.authRegister,
        onTap: () => context.push(AppRoutes.register),
      ),
      children: [
        if (_showSessionExpired)
          AuthErrorBanner(l10n.errorSessionExpired, tone: AuthBannerTone.info),
        AuthErrorBanner(_formError),
        AppTextField(
          label: l10n.fieldEmail,
          controller: _email,
          hintText: l10n.fieldEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          prefixIcon: Icons.mail_outline,
          errorText: _emailError,
          enabled: !_submitting,
        ),
        const SizedBox(height: 16),
        PasswordField(
          label: l10n.fieldPassword,
          controller: _password,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          errorText: _passwordError,
          onSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppTextButton(
            label: l10n.authForgotPassword,
            onPressed: _submitting ? null : () => context.push(AppRoutes.forgotPassword),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: l10n.authLogIn,
          isLoading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
