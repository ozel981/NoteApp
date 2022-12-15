part of 'note_form_bloc.dart';

@freezed
class NoteFormEvent with _$NoteFormEvent {
  const factory NoteFormEvent.initialized(Option<Note> initialNoteOption) =
      Initialized;
  const factory NoteFormEvent.bodyChanged(String bodyStr) = BodyChanged;
  const factory NoteFormEvent.colorChanged(Color color) = ColorChanged;
  const factory NoteFormEvent.todoChanged(KtList<TodoItemPrimitive> todos) =
      TodoChanged;
  const factory NoteFormEvent.saved() = Saved;
}
