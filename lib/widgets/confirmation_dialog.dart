import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'dialog_card.dart';
import 'note_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NoteButton(
                onPressed: () => Navigator.pop(context, false),
                isOutlined: true,
                child: Text(l10n.no),
              ),
              const SizedBox(width: 8),
              NoteButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.yes),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
