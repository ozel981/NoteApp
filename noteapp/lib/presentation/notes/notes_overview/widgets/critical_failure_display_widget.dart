import 'package:flutter/material.dart';
import 'package:notes_firebase_ddd_course/domain/notes/note_failure.dart';
import 'package:styled_widget/styled_widget.dart';

class CriticalFailureDisplay extends StatelessWidget {
  final NoteFailure failure;

  const CriticalFailureDisplay({Key? key, required this.failure})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('😱').fontSize(100),
        Text(failure.maybeMap(
                insufficientPermission: (_) => 'Insufficient permission',
                orElse: () => 'Unexpected error. \nPlease, contact support.'))
            .textAlignment(TextAlign.center)
            .fontSize(24),
        TextButton(
            onPressed: () {
              // TODO: send email
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.mail),
                SizedBox(
                  width: 4,
                ),
                Text('I NEED HELP')
              ],
            ))
      ],
    );
  }
}
