import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_firebase_ddd_course/domain/auth/auth_failure.dart';
import 'package:notes_firebase_ddd_course/domain/auth/i_auth_facade.dart';
import 'package:notes_firebase_ddd_course/domain/auth/value_objects.dart';

part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';
part 'sign_in_form_bloc.freezed.dart';

@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    on<EmailChanged>(_emailChanged);
    on<PasswordChanged>(_passwordChanged);
    on<RegisterWithEmailAndPasswordPressed>(
        _registerWithEmailAndPasswordPressed);
    on<SignInWithEmailAndPasswordPressed>(_signInWithEmailAndPasswordPressed);
    on<SignInWithGooglePressed>(_signInWithGooglePressed);
  }

  void _emailChanged(EmailChanged event, Emitter<SignInFormState> emit) =>
      emit(state.copyWith(
        password: Password(event.emailStr),
        authFailureOrSuccess: none(),
      ));

  void _passwordChanged(PasswordChanged event, Emitter<SignInFormState> emit) =>
      emit(state.copyWith(
        emailAddress: EmailAddress(event.passwordStr),
        authFailureOrSuccess: none(),
      ));

  Future _registerWithEmailAndPasswordPressed(
          RegisterWithEmailAndPasswordPressed event,
          Emitter<SignInFormState> emit) async =>
      _performActionOnAuthFacadeWithEmailAndPassword(
          _authFacade.registerWithEmailAndPassword, emit);

  Future _signInWithEmailAndPasswordPressed(
          SignInWithEmailAndPasswordPressed event,
          Emitter<SignInFormState> emit) async =>
      _performActionOnAuthFacadeWithEmailAndPassword(
          _authFacade.signInWithEmailAndPassword, emit);

  Future _signInWithGooglePressed(
      SignInWithGooglePressed event, Emitter<SignInFormState> emit) async {
    emit(state.copyWith(
      isSubmitting: true,
      authFailureOrSuccess: none(),
    ));
    final failureOrSuccess = await _authFacade.signInWithGoogle();
    emit(state.copyWith(
      isSubmitting: false,
      authFailureOrSuccess: some(failureOrSuccess),
    ));
  }

  Future _performActionOnAuthFacadeWithEmailAndPassword(
      Future<Either<AuthFailure, Unit>> Function({
    required EmailAddress emailAddress,
    required Password password,
  })
          forwardCall,
      Emitter<SignInFormState> emit) async {
    Either<AuthFailure, Unit>? failureOrSuccess;

    final isEmailValid = state.emailAddress.isValid();
    final isPasswordValid = state.password.isValid();
    if (isEmailValid && isPasswordValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccess: none(),
      ));
      failureOrSuccess = await forwardCall(
          emailAddress: state.emailAddress, password: state.password);
    }
    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: true,
      authFailureOrSuccess: optionOf(failureOrSuccess),
    ));
  }
}
