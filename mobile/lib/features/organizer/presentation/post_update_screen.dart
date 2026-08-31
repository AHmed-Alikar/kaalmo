import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/buttons/primary_button.dart';
import '../application/post_update_controller.dart';

/// `/organizer/campaign/:id/update` — post a campaign update (`text`, min 10).
/// Media attachment needs an image picker + the multipart upload endpoint and
/// is deferred to a media phase.
class PostUpdateScreen extends ConsumerStatefulWidget {
  const PostUpdateScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends ConsumerState<PostUpdateScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = widget.campaignId;
    final controller = ref.read(postUpdateControllerProvider(id).notifier);
    final state = ref.watch(postUpdateControllerProvider(id));

    ref.listen(postUpdateControllerProvider(id).select((s) => s.phase), (_, phase) {
      if (phase == PostUpdatePhase.posted) {
        ref.invalidate(campaignUpdatesProvider(id));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.organizerUpdatePosted)));
        if (context.canPop()) context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizerPostUpdateTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Text(l10n.organizerPostUpdateSubtitle,
                      style: TextStyle(
                          fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _text,
                    minLines: 5,
                    maxLines: 12,
                    autofocus: true,
                    onChanged: controller.setText,
                    decoration: InputDecoration(
                      hintText: l10n.organizerUpdateHint,
                      errorText: state.text.isNotEmpty && state.tooShort
                          ? l10n.organizerUpdateTooShort(kUpdateMinLength)
                          : null,
                    ),
                  ),
                  if (state.phase == PostUpdatePhase.error && state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(presentError(state.error!, l10n),
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
                  ],
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  label: l10n.organizerPublishUpdate,
                  isLoading: state.isPosting,
                  onPressed: state.canSubmit ? () => controller.submit() : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
