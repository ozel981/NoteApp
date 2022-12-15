import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kt_dart/src/collection/kt_iterable.dart';
import 'package:kt_dart/src/collection/kt_list.dart';
import 'package:notes_firebase_ddd_course/application/notes/note_form/note_form_bloc.dart';
import 'package:notes_firebase_ddd_course/domain/notes/value_objects.dart';
import 'package:notes_firebase_ddd_course/presentation/notes/note_form/misc/todo_item_presentation_classes.dart';
import 'package:notes_firebase_ddd_course/presentation/notes/note_form/misc/build_context_x.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (prevState, currentState) =>
          prevState.note.todos.isFull != currentState.note.todos.isFull,
      listener: (context, state) {
        if (state.note.todos.isFull) {
          // TODO: show message
        }
      },
      child: Consumer<FormTodos>(builder: (context, formTodos, child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: formTodos.value.size,
          itemBuilder: (context, index) {
            return TodoTile(
              index: index,
              key: ValueKey(context.formTodos[index].id),
            );
          },
        );
      }),
    );
  }
}

class TodoTile extends HookWidget {
  final int index;

  const TodoTile({required this.index, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo =
        context.formTodos.getOrElse(index, (_) => TodoItemPrimitive.empty());
    final textEditingController = useTextEditingController(text: todo.name);

    return Slidable(
      endActionPane: ActionPane(motion: const ScrollMotion(), children: [
        SlidableAction(
          onPressed: (_) {
            context.formTodos = context.formTodos.minusElement(todo);
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ]),
      child: ListTile(
              leading: Checkbox(
                value: todo.done,
                onChanged: (value) {
                  context.formTodos = context.formTodos.map((listTodo) =>
                      listTodo == todo
                          ? todo.copyWith(done: value!)
                          : listTodo);
                  context
                      .watch<NoteFormBloc>()
                      .add(NoteFormEvent.todoChanged(context.formTodos));
                },
              ),
              title: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Todo',
                  border: InputBorder.none,
                ),
                maxLength: TodoName.maxLength,
                onChanged: (value) {
                  context.formTodos = context.formTodos.map((listTodo) =>
                      listTodo == todo ? todo.copyWith(name: value) : listTodo);
                  context
                      .watch<NoteFormBloc>()
                      .add(NoteFormEvent.todoChanged(context.formTodos));
                },
                validator: (_) {
                  return context
                      .watch<NoteFormBloc>()
                      .state
                      .note
                      .todos
                      .value
                      .fold(
                          (f) => null,
                          (todoList) => todoList[index].name.value.fold(
                              (f) => f.maybeMap(
                                  empty: (_) => 'Cannot be empty',
                                  exceedingLength: (_) => 'Too long',
                                  multiline: (_) =>
                                      'Has to be in a single line',
                                  orElse: () => null),
                              (_) => null));
                },
              ))
          .border(color: Colors.grey)
          .borderRadius(all: 8)
          .padding(horizontal: 8, vertical: 2),
    );
  }
}
