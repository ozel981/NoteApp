import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:notes_firebase_ddd_course/application/notes/note_watcher/note_watcher_bloc.dart';
import 'package:provider/src/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class UncompletedSwitch extends StatelessWidget {
  const UncompletedSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final toggleState = useState(false);

    return InkResponse(
      onTap: () {
        toggleState.value = !toggleState.value;
        context.watch<NoteWatcherBloc>().add(toggleState.value
            ? const NoteWatcherEvent.watchUncompletedStarted()
            : const NoteWatcherEvent.watchAllStarted());
      },
      child: AnimatedSwitcher(
        duration: const Duration(microseconds: 100),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: toggleState.value
            ? const Icon(Icons.check_box_outline_blank, key: Key('outline'))
            : const Icon(Icons.indeterminate_check_box,
                key: Key('indeterminate')),
      ),
    ).padding(horizontal: 16);
  }
}
