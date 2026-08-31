import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';

/// Campaign story with an expand / collapse when it runs long.
class CampaignStoryView extends StatefulWidget {
  const CampaignStoryView({super.key, required this.story, this.collapsedLines = 6});

  final String story;
  final int collapsedLines;

  @override
  State<CampaignStoryView> createState() => _CampaignStoryViewState();
}

class _CampaignStoryViewState extends State<CampaignStoryView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = widget.story.trim();
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.campaignStory,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (text.isEmpty)
          Text(l10n.campaignStoryUnavailable,
              style: bodyStyle?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final painter = TextPainter(
                text: TextSpan(text: text, style: bodyStyle),
                maxLines: widget.collapsedLines,
                textDirection: Directionality.of(context),
              )..layout(maxWidth: constraints.maxWidth);
              final overflows = painter.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: bodyStyle,
                    maxLines: _expanded ? null : widget.collapsedLines,
                    overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
                  ),
                  if (overflows)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
                      onPressed: () => setState(() => _expanded = !_expanded),
                      child: Text(_expanded ? l10n.showLess : l10n.readMore),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}
