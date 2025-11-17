import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants.dart';
import '../cubits/notes_cubit.dart';
import '../cubits/notes_state.dart';
import '../enums/order_option.dart';
import 'note_icon_button.dart';

class ViewOptions extends StatelessWidget {
  const ViewOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final notesCubit = context.read<NotesCubit>();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              NoteIconButton(
                icon: state.isDescending
                    ? FontAwesomeIcons.arrowDown
                    : FontAwesomeIcons.arrowUp,
                size: 18,
                onPressed: () {
                  notesCubit.setIsDescending(!state.isDescending);
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<OrderOption>(
                value: state.orderBy,
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: FaIcon(
                    FontAwesomeIcons.arrowDownWideShort,
                    size: 18,
                    color: gray700,
                  ),
                ),
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(16),
                isDense: true,
                items: OrderOption.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            Text(e.name),
                            if (e == state.orderBy) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) =>
                    OrderOption.values.map((e) => Text(e.name)).toList(),
                onChanged: (newValue) {
                  notesCubit.setOrderBy(newValue!);
                },
              ),
              const Spacer(),
              NoteIconButton(
                icon: state.isGrid
                    ? FontAwesomeIcons.tableCellsLarge
                    : FontAwesomeIcons.bars,
                size: 18,
                onPressed: () {
                  notesCubit.setIsGrid(!state.isGrid);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
