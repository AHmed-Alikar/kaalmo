import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/auth/auth_error_banner.dart';
import '../../../shared/auth/auth_scaffold.dart';
import '../../../shared/auth/otp_input.dart';
import '../../../shared/buttons/app_text_button.dart';
import '../../../shared/buttons/primary_button.dart';

const _resendCooldown = Duration(seconds: 60);

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();

  bool _submitting = false;
  bool _resending = false;
  String? _formError;
  String? _codeError;
  String? _infoMessage;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _resendCooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    final l10n = context.l10n;
    final codeError = Validators.code6(_code.text, l10n);
    setState(() {
      _codeError = codeError;
      _formError = null;
      _infoMessage = null;
    });
    if (codeError != null || _submitting) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyEmailOtp(_code.text.trim());
      // State flips to verified; router leaves this screen for /home.
    } catch (e) {
      if (mounted) {
        setState(() {
          _codeError = (e is ApiException && e.code == 'INVALID_CODE')
              ? l10n.verifyEmailInvalidCode
              : null;
          _formError = _codeError == null ? presentError(e, l10n) : null;
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0 || _resending) return;
    final l10n = context.l10n;
    setState(() {
      _resending = true;
      _formError = null;
      _infoMessage = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).resendVerificationEmail();
      if (mounted) setState(() => _infoMessage = l10n.verifyEmailResent);
      _startCooldown();
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = (e is ApiException && e.code == 'ALREADY_VERIFIED')
              ? l10n.verifyEmailAlreadyVerified
              : presentError(e, l10n);
        });
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _later() async {
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(authControllerProvider).user?.email ?? '';

    return AuthScaffold(
      title: l10n.verifyEmailTitle,
      subtitle: l10n.verifyEmailSubtitle(email),
      showBack: false,
      footer: AppTextButton(
        label: l10n.verifyEmailLater,
        onPressed: _submitting ? null : _later,
      ),
      children: [
        if (_infoMessage != null)
          AuthErrorBanner(_infoMessage, tone: AuthBannerTone.success),
        AuthErrorBanner(_formError),
        OtpInput(
          controller: _code,
          errorText: _codeError,
          enabled: !_submitting,
          onCompleted: (_) => _verify(),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.verifyEmailAction,
          isLoading: _submitting,
          onPressed: _verify,
        ),
        const SizedBox(height: 8),
        Center(
          child: AppTextButton(
            label: _cooldown > 0
                ? l10n.verifyEmailResendIn(_cooldown)
                : l10n.verifyEmailResend,
            onPressed: (_cooldown > 0 || _resending) ? null : _resend,
          ),
        ),
      ],
    );
  }
}
