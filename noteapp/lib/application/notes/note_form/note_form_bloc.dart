import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:notes_firebase_ddd_course/domain/notes/i_note_repository.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note_failure.dart';
import 'package:notes_firebase_ddd_course/domain/notes/value_objects.dart';
import 'package:notes_firebase_ddd_course/presentation/notes/note_form/misc/todo_item_presentation_classes.dart';

part 'note_form_event.dart';
part 'note_form_state.dart';
part 'note_form_bloc.freezed.dart';

@injectable
class NoteFormBloc extends Bloc<NoteFormEvent, NoteFormState> {
  final INoteRepository _noteRepository;

  NoteFormBloc(this._noteRepository) : super(NoteFormState.initial()) {
    on<Initialized>(_initialized);
    on<BodyChanged>(_bodyChanged);
    on<ColorChanged>(_colorChanged);
    on<TodoChanged>(_todoChanged);
    on<Saved>(_saved);
  }

  void _initialized(Initialized event, Emitter<NoteFormState> emit) {
    event.initialNoteOption.fold(
      () => emit(state),
      (initialNote) => emit(state.copyWith(note: initialNote, isEditing: true)),
    );
  }

  void _bodyChanged(BodyChanged event, Emitter<NoteFormState> emit) {
    emit(state.copyWith(
      note: state.note.copyWith(body: NoteBody(event.bodyStr)),
      saveFailureOrSuccessOption: none(),
    ));
  }

  void _colorChanged(ColorChanged event, Emitter<NoteFormState> emit) {
    emit(state.copyWith(
      note: state.note.copyWith(color: NoteColor(event.color)),
      saveFailureOrSuccessOption: none(),
    ));
  }

  void _todoChanged(TodoChanged event, Emitter<NoteFormState> emit) {
    emit(state.copyWith(
      note: state.note.copyWith(
          todos: List3(event.todos.map((primitive) => primitive.toDomain()))),
      saveFailureOrSuccessOption: none(),
    ));
  }

  Future _saved(Saved event, Emitter<NoteFormState> emit) async {
    Option<Either<NoteFailure, Unit>> failureOrSuccess = none();

    emit(state.copyWith(
      isSaving: true,
      saveFailureOrSuccessOption: none(),
    ));

    if (state.note.failureOption.isNone()) {
      failureOrSuccess = some(state.isEditing
          ? await _noteRepository.update(state.note)
          : await _noteRepository.create(state.note));
    }

    emit(state.copyWith(
      isSaving: false,
      showErrorMessages: true,
      saveFailureOrSuccessOption: failureOrSuccess,
    ));
  }
}
