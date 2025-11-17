import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'dialog_card.dart';
import 'note_button.dart';
import 'note_form_field.dart';

class NewTagDialog extends StatefulWidget {
  const NewTagDialog({
    super.key,
    this.tag,
  });
  final String? tag;

  @override
  State<NewTagDialog> createState() => _NewTagDialogState();
}

class _NewTagDialogState extends State<NewTagDialog> {
  late final TextEditingController tagController;

  late final GlobalKey<FormFieldState> tagKey;

  @override
  void initState() {
    super.initState();

    tagController = TextEditingController(text: widget.tag);

    tagKey = GlobalKey();
  }

  @override
  void dispose() {
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.addTag,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 24),
          NoteFormField(
            key: tagKey,
            controller: tagController,
            hintText: l10n.addTagHint,
            validator: (value) {
              if (value!.trim().isEmpty) {
                return l10n.noTagsAdded;
              } else if (value.trim().length > 16) {
                return l10n.tagsTooLong;
              }
              return null;
            },
            onChanged: (newValue) {
              tagKey.currentState?.validate();
            },
            autofocus: true,
          ),
          const SizedBox(height: 24),
          NoteButton(
            onPressed: () {
              if (tagKey.currentState?.validate() ?? false) {
                Navigator.pop(context, tagController.text.trim());
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }
}
