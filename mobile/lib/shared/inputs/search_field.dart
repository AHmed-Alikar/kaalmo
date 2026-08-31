import 'package:flutter/material.dart';

/// Styled search input with a clear ("×") affordance. Debouncing is the
/// caller's responsibility (done in the Explore controller) — this widget
/// just reports raw changes.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onChanged,
    this.onCleared,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  final String hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCleared;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _controller.clear();
                      widget.onCleared?.call();
                    },
                  ),
            isDense: true,
          ),
        );
      },
    );
  }
}
