import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants.dart';
import '../core/dialogs.dart';
import '../core/utils.dart';
import '../cubits/new_note_cubit.dart';
import '../cubits/new_note_state.dart';
import '../l10n/app_localizations.dart';
import '../models/note.dart';
import 'note_icon_button.dart';
import 'note_tag.dart';

class NoteMetadata extends StatelessWidget {
  const NoteMetadata({
    required this.note,
    super.key,
  });
  final Note? note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final newNoteCubit = context.read<NewNoteCubit>();

    return Column(
      children: [
        if (note != null) ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  l10n.lastModified,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: gray500,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  toLongDate(note!.dateModified),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  l10n.created,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: gray500,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  toLongDate(note!.dateCreated),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ],
        // Reminder Section
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Text(
                    l10n.reminder,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  NoteIconButton(
                    icon: FontAwesomeIcons.bell,
                    onPressed: () async {
                      final DateTime? selectedDateTime =
                          await showDateTimePicker(
                        context: context,
                        initialDateTime:
                            context.read<NewNoteCubit>().state.reminderDateTime,
                      );

                      if (selectedDateTime != null) {
                        newNoteCubit.setReminderDateTime(selectedDateTime);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: BlocBuilder<NewNoteCubit, NewNoteState>(
                builder: (context, state) {
                  final reminderDateTime = state.reminderDateTime;
                  return reminderDateTime == null
                      ? Text(
                          l10n.noReminderSet,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: gray900,
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                toLongDate(
                                    reminderDateTime.microsecondsSinceEpoch),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: gray900,
                                ),
                              ),
                            ),
                            NoteIconButton(
                              icon: FontAwesomeIcons.xmark,
                              onPressed: () {
                                newNoteCubit.removeReminder();
                              },
                            ),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Text(
                    l10n.tags,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  NoteIconButton(
                    icon: FontAwesomeIcons.circlePlus,
                    onPressed: () async {
                      final String? tag =
                          await showNewTagDialog(context: context);

                      if (tag != null) {
                        newNoteCubit.addTag(tag);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: BlocBuilder<NewNoteCubit, NewNoteState>(
                builder: (context, state) {
                  final tags = state.tags;
                  return tags.isEmpty
                      ? Text(
                          l10n.noTagsAdded,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: gray900,
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              tags.length,
                              (index) => NoteTag(
                                label: tags[index],
                                onClosed: () {
                                  newNoteCubit.removeTag(index);
                                },
                                onTap: () async {
                                  final String? tag = await showNewTagDialog(
                                    context: context,
                                    tag: tags[index],
                                  );

                                  if (tag != null && tag != tags[index]) {
                                    newNoteCubit.updateTag(tag, index);
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
