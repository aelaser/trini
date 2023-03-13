import 'package:flutter/material.dart';
import 'package:trini/constants/routes.dart';
import 'package:trini/firebase_options.dart';
import 'package:trini/services/auth/auth_service.dart';
import 'package:trini/views/login_view.dart';
import 'package:trini/views/register_view.dart';
import 'package:trini/views/verify_email_view.dart';
import 'package:trini/views/workouts/new_workout_view.dart';
import 'dart:developer' as devtools show log;

import 'package:trini/views/workouts/workout_view.dart';

import 'views/workouts/create_update_workout_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter App Trini',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Use HomePage in main function instead of going directly to another widget
      // HomePage need to intiliaze firebase
      home: const HomePage(),

      // Define loging and register routes kfdfg
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        dashboardRoute: (context) => const DashboardView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateWorkouteRoute: (context) =>
            const CreateUpdateWorkoutView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        // loading screen while waiting
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            // print(user);
            if (user != null) {
              if (user.isEmailVerified) {
                return const DashboardView();
              } else {
                // print("User email is not verified");
                return const VerifyEmailView();
                // break;
              }
            } else {
              return const LoginView();
            }
          default:
            // Instead of returning a text
            // return Text('Loading...');
            // We coud return this
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
