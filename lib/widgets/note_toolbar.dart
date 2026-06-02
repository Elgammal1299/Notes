import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../core/constants.dart';

class NoteToolbar extends StatelessWidget {
  const NoteToolbar({
    required this.controller,
    super.key,
  });

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: primary,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: primary,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: QuillSimpleToolbar(
        controller: controller,
        config: const QuillSimpleToolbarConfig(
          multiRowsDisplay: false,
          showSmallButton: false,
          showInlineCode: false,
          showLink: false,
          showQuote: false,
          showCodeBlock: false,
          showIndent: false,
          showSearchButton: false,
          showSubscript: false,
          showSuperscript: false,
          showFontFamily: false,
          showFontSize: false,
          showAlignmentButtons: false,
          showDirection: false,
          showListCheck: false,
        ),
      ),
    );
  }
}
