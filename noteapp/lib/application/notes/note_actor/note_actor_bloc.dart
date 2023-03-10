import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_firebase_ddd_course/domain/notes/i_note_repository.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note_failure.dart';

part 'note_actor_event.dart';
part 'note_actor_state.dart';
part 'note_actor_bloc.freezed.dart';

@injectable
class NoteActorBloc extends Bloc<NoteActorEvent, NoteActorState> {
  final INoteRepository _noteRepository;

  NoteActorBloc(this._noteRepository) : super(const NoteActorState.initial()) {
    on<Deleted>(_deleted);
  }

  Future _deleted(Deleted event, Emitter<NoteActorState> emit) async {
    emit(const NoteActorState.actionInProgress());
    final possibleFailure = await _noteRepository.delete(event.note);
    possibleFailure.fold(
      (f) => emit(NoteActorState.deleteFailure(f)),
      (_) => emit(const NoteActorState.deleteSuccess()),
    );
  }
}
