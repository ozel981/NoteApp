import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_firebase_ddd_course/application/auth/auth_bloc.dart';
import 'package:notes_firebase_ddd_course/presentation/routes/router.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:notes_firebase_ddd_course/application/auth/sign_in_form/sign_in_form_bloc.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        state.authFailureOrSuccess.fold(
            () {},
            (either) => either.fold(
                  (failure) {
                    //TODO: show error
                  },
                  (_) {
                    AutoRouter.of(context).push(const NotesOverviewPageRoute());
                    context
                        .watch<AuthBloc>()
                        .add(const AuthEvent.authCheckRequested());
                  },
                ));
      },
      builder: (context, state) {
        return Form(
          autovalidateMode: state.showErrorMessages
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: ListView(
            children: [
              const Text('Note').fontSize(138).textAlignment(TextAlign.center),
              const SizedBox(height: 8),
              TextFormField(
                      decoration:
                          const InputDecoration(prefix: Icon(Icons.email)),
                      onChanged: (value) => context
                          .watch<SignInFormBloc>()
                          .add(SignInFormEvent.emailChanged(value)),
                      validator: (_) => context
                          .watch<SignInFormBloc>()
                          .state
                          .emailAddress
                          .value
                          .fold(
                              (f) => f.maybeMap(
                                  invalidEmail: (_) => 'invalid email',
                                  orElse: () => null),
                              (r) => null),
                      autocorrect: false)
                  .semanticsLabel('Email'),
              TextFormField(
                      decoration:
                          const InputDecoration(prefix: Icon(Icons.email)),
                      autocorrect: false,
                      onChanged: (value) => context
                          .watch<SignInFormBloc>()
                          .add(SignInFormEvent.passwordChanged(value)),
                      validator: (_) => context
                          .watch<SignInFormBloc>()
                          .state
                          .password
                          .value
                          .fold(
                              (f) => f.maybeMap(
                                  invalidEmail: (_) => 'short password',
                                  orElse: () => null),
                              (r) => null),
                      obscureText: true)
                  .semanticsLabel('Password'),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () {
                            context.watch<SignInFormBloc>().add(
                                const SignInFormEvent
                                    .signInWithEmailAndPasswordPressed());
                          },
                          child: const Text('SIGN IN'))),
                  Expanded(
                      child: TextButton(
                          onPressed: () {
                            context.watch<SignInFormBloc>().add(
                                const SignInFormEvent
                                    .registerWithEmailAndPasswordPressed());
                          },
                          child: const Text('REGISTER'))),
                ],
              ),
              TextButton(
                      onPressed: () {
                        context.watch<SignInFormBloc>().add(
                            const SignInFormEvent.signInWithGooglePressed());
                      },
                      child: const Text('SIGN IN WITH GOOGLE')
                          .bold()
                          .textColor(Colors.white))
                  .backgroundColor(Colors.lightBlue),
              if (state.isSubmitting) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator()
              ]
            ],
          ).paddingDirectional(all: 8),
        );
      },
    );
  }
}
