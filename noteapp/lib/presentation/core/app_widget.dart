import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_firebase_ddd_course/application/auth/auth_bloc.dart';
import 'package:notes_firebase_ddd_course/injection.dart';
import 'package:notes_firebase_ddd_course/presentation/routes/router.dart';

final appRouter = AppRouter();

class AppWidget extends StatelessWidget {
  const AppWidget({
    Key? key,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                getIt<AuthBloc>()..add(const AuthEvent.authCheckRequested())),
      ],
      child: MaterialApp(
        title: 'Notes',
        home: MaterialApp.router(
          routerDelegate: AutoRouterDelegate(appRouter),
          routeInformationParser: appRouter.defaultRouteParser(),
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
            primaryColor: Colors.green[800],
            disabledColor: Colors.red[800],
            inputDecorationTheme: InputDecorationTheme(
                border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            )),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.blue[900]),
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: Colors.blueAccent)),
      ),
    );
  }
}
