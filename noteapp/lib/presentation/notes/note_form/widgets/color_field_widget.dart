import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_firebase_ddd_course/application/notes/note_form/note_form_bloc.dart';
import 'package:notes_firebase_ddd_course/domain/notes/value_objects.dart';
import 'package:styled_widget/styled_widget.dart';

class ColorField extends StatelessWidget {
  const ColorField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteFormBloc, NoteFormState>(
      buildWhen: (prevState, currentState) =>
          prevState.note.color != currentState.note.color,
      builder: (context, state) {
        return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final itemColor = NoteColor.predefinedColors[index];
              return Material(
                      color: itemColor,
                      elevation: 4,
                      shape: CircleBorder(
                          side: state.note.color.value.fold(
                              (_) => BorderSide.none,
                              (color) => color == itemColor
                                  ? const BorderSide(width: 1.5)
                                  : BorderSide.none)),
                      child: const SizedBox(height: 50, width: 50))
                  .gestures(onTap: () {
                context
                    .watch<NoteFormBloc>()
                    .add(NoteFormEvent.colorChanged(itemColor));
              });
            },
            separatorBuilder: (context, index) {
              final itemColor = NoteColor.predefinedColors[index];
              return const SizedBox(width: 12);
            },
            itemCount: NoteColor.predefinedColors.length);
      },
    ).height(80);
  }
}
