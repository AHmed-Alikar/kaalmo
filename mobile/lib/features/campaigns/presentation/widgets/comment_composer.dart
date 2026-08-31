import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../application/campaign_comments_controller.dart';

/// Comment input. Enforces the backend's own limits (1–[kCommentMaxLength]),
/// blocks empty and duplicate submissions, and shows a busy state.
class CommentComposer extends StatefulWidget {
  const CommentComposer({
    super.key,
    required this.submitting,
    required this.onSubmit,
    this.enabled = true,
  });

  final bool submitting;
  final bool enabled;

  /// Returns true if the submission was accepted (input is then cleared).
  final Future<bool> Function(String text) onSubmit;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > kCommentMaxLength || widget.submitting) return;
    final ok = await widget.onSubmit(text);
    if (ok && mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, _) => TextField(
                  controller: _controller,
                  enabled: widget.enabled && !widget.submitting,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: kCommentMaxLength,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.commentHint,
                    isDense: true,
                    counterText: value.text.length > kCommentMaxLength - 100
                        ? '${value.text.length}/$kCommentMaxLength'
                        : '',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            widget.submitting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4)),
                  )
                : IconButton.filled(
                    onPressed: widget.enabled ? _send : null,
                    icon: const Icon(Icons.send, size: 18),
                    tooltip: l10n.commentSend,
                  ),
          ],
        ),
      ),
    );
  }
}
