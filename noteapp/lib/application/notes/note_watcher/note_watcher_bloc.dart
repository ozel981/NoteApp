import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:notes_firebase_ddd_course/domain/notes/i_note_repository.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note_failure.dart';

part 'note_watcher_event.dart';
part 'note_watcher_state.dart';
part 'note_watcher_bloc.freezed.dart';

@injectable
class NoteWatcherBloc extends Bloc<NoteWatcherEvent, NoteWatcherState> {
  final INoteRepository _noteRepository;

  StreamSubscription<Either<NoteFailure, KtList<Note>>>?
      _noteStreamSubscription;

  NoteWatcherBloc(this._noteRepository)
      : super(const NoteWatcherState.initial()) {
    on<WatchAllStarted>(_watchAllStarted);
    on<WatchUncompletedStarted>(_watchUncompletedStarted);
    on<NotesReceived>(_notesReceived);
  }

  Future _watchAllStarted(
      WatchAllStarted event, Emitter<NoteWatcherState> emit) async {
    await _noteStreamSubscription?.cancel();
    emit(const NoteWatcherState.loadInProgress());
    _noteStreamSubscription = _noteRepository
        .watchAll()
        .listen((notes) => add(NoteWatcherEvent.notesReceived(notes)));
  }

  Future _watchUncompletedStarted(
      WatchUncompletedStarted event, Emitter<NoteWatcherState> emit) async {
    await _noteStreamSubscription?.cancel();
    _noteStreamSubscription = _noteRepository
        .watchUncompleted()
        .listen((notes) => add(NoteWatcherEvent.notesReceived(notes)));
  }

  Future _notesReceived(
      NotesReceived event, Emitter<NoteWatcherState> emit) async {
    event.failureOrNotes.fold(
      (f) => emit(NoteWatcherState.loadFailure(f)),
      (notes) => emit(NoteWatcherState.loadSuccess(notes)),
    );
  }

  @override
  Future close() async {
    await _noteStreamSubscription?.cancel();
    return super.close();
  }
}
