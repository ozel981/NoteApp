import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:notes_firebase_ddd_course/application/notes/note_form/note_form_bloc.dart';
import 'package:notes_firebase_ddd_course/domain/notes/value_objects.dart';
import 'package:styled_widget/styled_widget.dart';

class BodyField extends HookWidget {
  const BodyField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textEditingController = useTextEditingController();

    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (prevState, currentState) =>
          prevState.isEditing != currentState.isEditing,
      listener: (context, state) {
        textEditingController.text = state.note.body.getOrCrash();
      },
      child: TextFormField(
        controller: textEditingController,
        decoration: const InputDecoration(labelText: 'Note', counterText: ''),
        maxLength: NoteBody.maxLength,
        maxLines: null,
        minLines: 5,
        onChanged: (value) =>
            context.watch<NoteFormBloc>().add(NoteFormEvent.bodyChanged(value)),
        validator: (_) =>
            context.watch<NoteFormBloc>().state.note.body.value.fold(
                (f) => f.maybeMap(
                      empty: (f) => 'Cannot be empty',
                      exceedingLength: (f) => 'Exceeding length, max: ${f.max}',
                      orElse: () => null,
                    ),
                (r) => null),
      ),
    ).padding(all: 10);
  }
}
