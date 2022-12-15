import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:notes_firebase_ddd_course/application/notes/note_actor/note_actor_bloc.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note.dart';
import 'package:notes_firebase_ddd_course/domain/notes/todo_item.dart';
import 'package:notes_firebase_ddd_course/presentation/routes/router.dart';
import 'package:provider/src/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:kt_dart/kt.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(note.body.getOrCrash()).fontSize(18),
      if (note.todos.length > 0) ...[
        const SizedBox(height: 4),
        Wrap(spacing: 8, children: [
          ...note.todos.getOrCrash().map((todo) => TodoDisplay(todo: todo)).iter
        ])
      ]
    ])).backgroundColor(note.color.getOrCrash()).gestures(
      onTap: () {
        AutoRouter.of(context).push(NoteFormPageRoute(editedNote: note));
      },
      onLongPress: () {
        final noteActorBloc = context.watch<NoteActorBloc>();
        _showDeletionDialog(context, noteActorBloc);
      },
    );
  }

  void _showDeletionDialog(BuildContext context, NoteActorBloc noteActorBloc) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Selected node: '),
            content: Text(note.body.getOrCrash(),
                maxLines: 3, overflow: TextOverflow.ellipsis),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL')),
              TextButton(
                  onPressed: () {
                    noteActorBloc.add(NoteActorEvent.deleted(note));
                    Navigator.pop(context);
                  },
                  child: const Text('DELETE')),
            ],
          );
        });
  }
}

class TodoDisplay extends StatelessWidget {
  final TodoItem todo;

  const TodoDisplay({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (todo.done)
          const Icon(Icons.check_box)
              .iconColor(Theme.of(context).colorScheme.secondary),
        if (!todo.done)
          const Icon(Icons.check_box)
              .iconColor(Theme.of(context).disabledColor),
        Text(todo.name.getOrCrash())
      ],
    );
  }
}
