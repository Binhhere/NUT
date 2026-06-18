import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';

class ComposeProgressSheet extends StatefulWidget {
  const ComposeProgressSheet({
    super.key,
    required this.streakDay,
    required this.onPost,
  });

  final int streakDay;
  final ValueChanged<String> onPost;

  @override
  State<ComposeProgressSheet> createState() => _ComposeProgressSheetState();
}

class _ComposeProgressSheetState extends State<ComposeProgressSheet> {
  final TextEditingController _controller = TextEditingController();

  bool get _canPost => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTextChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTextChanged() => setState(() {});

  void _submit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    Navigator.of(context).pop();
    widget.onPost(content);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedComposeTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: NutSpacing.small),
            Text(
              l10n.feedComposeHelper(widget.streakDay),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
            ),
            const SizedBox(height: NutSpacing.medium),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              autofocus: true,
              textInputAction: TextInputAction.newline,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.feedComposeBodyHint,
                filled: true,
                fillColor: palette.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NutRadius.card),
                  borderSide: BorderSide(color: palette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NutRadius.card),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NutRadius.card),
                  borderSide: BorderSide(color: palette.accentGold),
                ),
              ),
            ),
            const SizedBox(height: NutSpacing.medium),
            NutPrimaryButton(
              label: l10n.feedComposeSubmit,
              icon: Icons.send_outlined,
              onPressed: _canPost ? _submit : null,
            ),
            const SizedBox(height: NutSpacing.small),
            NutGhostButton(
              label: l10n.feedComposeCancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
