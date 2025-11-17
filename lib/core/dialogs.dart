import 'package:flutter/material.dart';

import '../widgets/confirmation_dialog.dart';
import '../widgets/message_dialog.dart';
import '../widgets/new_tag_dialog.dart';

Future<String?> showNewTagDialog({
  required BuildContext context,
  String? tag,
}) {
  return showDialog<String?>(
    context: context,
    builder: (context) => NewTagDialog(tag: tag),
  );
}

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (_) => ConfirmationDialog(title: title),
  );
}

Future<bool?> showMessageDialog({
  required BuildContext context,
  required String message,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (_) => MessageDialog(message: message),
  );
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDateTime,
}) async {
  // First show date picker
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDateTime ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context),
        child: child!,
      );
    },
  );

  if (pickedDate == null) return null;

  // Then show time picker
  if (!context.mounted) return null;

  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialDateTime != null
        ? TimeOfDay.fromDateTime(initialDateTime)
        : TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context),
        child: child!,
      );
    },
  );

  if (pickedTime == null) return null;

  // Combine date and time
  return DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );
}
