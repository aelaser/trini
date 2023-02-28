import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trini/constants/routes.dart';
import 'package:trini/firebase_options.dart';
import 'package:trini/views/login_view.dart';
import 'package:trini/views/register_view.dart';
import 'package:trini/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
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
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // loading screen while waiting
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            // print(user);
            if (user != null) {
              if (user.emailVerified) {
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

enum MenuAction { logout }

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Main UI"), actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            // return future of boolean to be logged out
            // Tapping on sign/log out should display dialog
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('log out'),
                ),
              ];
            },
          )
        ]),
        body: const Text("Hello World!"));
  }
}

// is showdialog cannot return boolean, return false.
// Otherwise return the value of showdialog
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are ypu sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              // if canceled, return false
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // if logoed out, return true
              Navigator.of(context).pop(true);
            },
            child: const Text("Log out"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
