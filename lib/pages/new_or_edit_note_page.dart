import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/dialogs.dart';
import '../cubits/new_note_cubit.dart';
import '../cubits/new_note_state.dart';
import '../cubits/notes_cubit.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../widgets/note_back_button.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../widgets/note_metadata.dart';
import '../widgets/note_toolbar.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/ad_helper.dart';

class NewOrEditNotePage extends StatefulWidget {
  const NewOrEditNotePage({
    required this.isNewNote,
    super.key,
  });

  final bool isNewNote;

  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {
  late final NewNoteCubit newNoteCubit;
  late final TextEditingController titleController;
  late final QuillController quillController;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    newNoteCubit = context.read<NewNoteCubit>();

    titleController = TextEditingController(text: newNoteCubit.state.title);

    quillController = QuillController(
      document: newNoteCubit.state.content,
      selection: const TextSelection.collapsed(offset: 0),
    )..addListener(() {
        newNoteCubit.setContent(quillController.document);
      });

    focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.isNewNote) {
        focusNode.requestFocus();
        newNoteCubit.setReadOnly(false);
      } else {
        newNoteCubit.setReadOnly(true);
        quillController.document = newNoteCubit.state.content;
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveNoteWithReminder() async {
    final note = newNoteCubit.buildNote();
    final notesCubit = context.read<NotesCubit>();
    final reminderDateTime = note.reminderDateTime;

    // Save the note first
    if (newNoteCubit.state.isNewNote) {
      await notesCubit.addNote(note);
    } else {
      await notesCubit.updateNote(note);
    }

    // Handle reminder scheduling after saving
    if (reminderDateTime != null) {
      final reminderTime =
          DateTime.fromMicrosecondsSinceEpoch(reminderDateTime);
      final now = DateTime.now();

      if (reminderTime.isAfter(now)) {
        try {
          final savedNote = notesCubit.state.notes.firstWhere(
            (n) => n.dateCreated == note.dateCreated,
          );
          await NotificationService().scheduleNoteReminder(
            note: savedNote,
            scheduledTime: reminderTime,
          );
        } catch (_) {
          // Notification scheduling failed silently
        }
      }
    } else {
      if (!newNoteCubit.state.isNewNote) {
        try {
          final savedNote = notesCubit.state.notes.firstWhere(
            (n) => n.dateCreated == note.dateCreated,
          );
          await NotificationService().cancelNoteReminder(savedNote);
        } catch (_) {
          // No reminder to cancel
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (!newNoteCubit.canSaveNote()) {
          Navigator.pop(context);
          return;
        }

        final bool? shouldSave = await showConfirmationDialog(
          context: context,
          title: l10n.saveNote,
        );

        if (shouldSave == null) return;
        if (!context.mounted) return;

        if (shouldSave) {
          await _saveNoteWithReminder();
        }

        if (!context.mounted) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const NoteBackButton(),
          title: Text(widget.isNewNote ? l10n.newNote : l10n.editNote),
          actions: [
            BlocBuilder<NewNoteCubit, NewNoteState>(
              builder: (context, state) {
                return NoteIconButtonOutlined(
                  icon: state.readOnly
                      ? FontAwesomeIcons.pen
                      : FontAwesomeIcons.bookOpen,
                  onPressed: () {
                    newNoteCubit.setReadOnly(!state.readOnly);
                    if (state.readOnly) {
                      focusNode.requestFocus();
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  },
                );
              },
            ),
            BlocBuilder<NewNoteCubit, NewNoteState>(
              builder: (context, state) {
                final canSaveNote = newNoteCubit.canSaveNote();
                return NoteIconButtonOutlined(
                  icon: FontAwesomeIcons.check,
                  onPressed: canSaveNote
                      ? () async {
                          await _saveNoteWithReminder();
                          AdHelper.showInterstitialAd();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        }
                      : null,
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              BlocBuilder<NewNoteCubit, NewNoteState>(
                builder: (context, state) => TextField(
                  controller: titleController,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.titleHere,
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                    border: InputBorder.none,
                  ),
                  canRequestFocus: !state.readOnly,
                  onChanged: (newValue) {
                    newNoteCubit.setTitle(newValue);
                  },
                ),
              ),
              BlocBuilder<NewNoteCubit, NewNoteState>(
                builder: (context, state) => NoteMetadata(
                  note: state.note,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: 2),
              ),
              Expanded(
                child: BlocBuilder<NewNoteCubit, NewNoteState>(
                  builder: (context, state) => Column(
                    children: [
                      Expanded(
                        child: QuillProvider(
                          configurations: QuillConfigurations(
                            controller: quillController,
                          ),
                          child: QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              placeholder: l10n.noteHere,
                              readOnly: state.readOnly,
                              customStyles: DefaultStyles(
                                paragraph: DefaultTextBlockStyle(
                                  TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    height: 1.15,
                                  ),
                                  const VerticalSpacing(16, 0),
                                  const VerticalSpacing(0, 0),
                                  null,
                                ),
                              ),
                            ),
                            focusNode: focusNode,
                          ),
                        ),
                      ),
                      if (!state.readOnly)
                        NoteToolbar(controller: quillController),
                    ],
                  ),
                ),
              ),
              BannerAdWidget(customAdUnitId: AdHelper.bannerAdUnitId2),
            ],
          ),
        ),
      ),
    );
  }
}
