import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_firebase_ddd_course/application/auth/auth_bloc.dart';
import 'package:notes_firebase_ddd_course/application/notes/note_actor/note_actor_bloc.dart';
import 'package:notes_firebase_ddd_course/application/notes/note_watcher/note_watcher_bloc.dart';
import 'package:notes_firebase_ddd_course/injection.dart';
import 'package:notes_firebase_ddd_course/presentation/notes/notes_overview/widgets/notes_overview_body_widget.dart';
import 'package:notes_firebase_ddd_course/presentation/notes/notes_overview/widgets/uncompleted_switch.dart';
import 'package:notes_firebase_ddd_course/presentation/routes/router.dart';

class NotesOverviewPage extends StatelessWidget {
  const NotesOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteWatcherBloc>(
            create: (context) => getIt<NoteWatcherBloc>()
              ..add(const NoteWatcherEvent.watchAllStarted())),
        BlocProvider<NoteActorBloc>(
            create: (context) => getIt<NoteActorBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(listener: (context, state) {
            state.maybeMap(
                unauthenticated: (_) =>
                    AutoRouter.of(context).push(const SignInPageRoute()),
                orElse: () {});
          }),
          BlocListener<NoteActorBloc, NoteActorState>(
              listener: (context, state) {
            state.maybeMap(
                deleteFailure: (state) {
                  // TODO: show message
                },
                orElse: () {});
          }),
        ],
        child: Scaffold(
            appBar: AppBar(
                title: const Text('Notes'),
                leading: IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => context
                        .watch<AuthBloc>()
                        .add(const AuthEvent.signedOut())),
                actions: [
                  UncompletedSwitch(),
                ]),
            body: const NotesOverviewBody(),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  AutoRouter.of(context)
                      .push(NoteFormPageRoute(editedNote: null));
                },
                child: const Icon(Icons.add))),
      ),
    );
  }
}
