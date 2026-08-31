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
import '../../../shared/inputs/app_text_field.dart';
import '../../../shared/inputs/password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _submitting = false;
  bool _acceptedTerms = false;
  String? _formError;
  final _fieldErrors = <String, String?>{};

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final errors = <String, String?>{
      'fullName': Validators.fullName(_fullName.text, l10n),
      'email': Validators.email(_email.text, l10n),
      'phone': Validators.phone(_phone.text, l10n),
      'password': Validators.password(_password.text, l10n),
      'confirm': Validators.confirmPassword(_confirm.text, _password.text, l10n),
    };
    final termsError = _acceptedTerms ? null : l10n.validationTermsRequired;
    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
      _formError = termsError;
    });
    if (errors.values.any((e) => e != null) || termsError != null || _submitting) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).register(
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            password: _password.text,
            language: Localizations.localeOf(context).languageCode,
          );
      // Auth state flips; the router sends the user to /verify-email
      // (email is unverified straight after registration).
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = presentError(e, l10n);
          fieldErrorsOf(e).forEach((k, v) => _fieldErrors[k] = v);
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
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      footer: AuthSwitchPrompt(
        prompt: l10n.authHaveAccountPrompt,
        actionLabel: l10n.authLogIn,
        onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
      ),
      children: [
        AuthErrorBanner(_formError),
        AppTextField(
          label: l10n.fieldFullName,
          controller: _fullName,
          hintText: l10n.fieldFullNameHint,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          prefixIcon: Icons.person_outline,
          errorText: _fieldErrors['fullName'],
          enabled: !_submitting,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: l10n.fieldEmail,
          controller: _email,
          hintText: l10n.fieldEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          prefixIcon: Icons.mail_outline,
          errorText: _fieldErrors['email'],
          enabled: !_submitting,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: l10n.fieldPhone,
          controller: _phone,
          hintText: l10n.fieldPhoneHint,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          prefixIcon: Icons.phone_outlined,
          errorText: _fieldErrors['phone'],
          enabled: !_submitting,
        ),
        const SizedBox(height: 16),
        PasswordField(
          label: l10n.fieldPassword,
          controller: _password,
          hintText: l10n.fieldPasswordHint,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          errorText: _fieldErrors['password'],
        ),
        const SizedBox(height: 16),
        PasswordField(
          label: l10n.fieldConfirmPassword,
          controller: _confirm,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: _fieldErrors['confirm'],
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _acceptedTerms,
          onChanged: _submitting ? null : (v) => setState(() => _acceptedTerms = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.authAcceptTerms, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: l10n.authRegister,
          isLoading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
