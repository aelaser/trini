import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trini/constants/routes.dart';
import 'package:trini/enums/menu_action.dart';
import 'package:trini/services/auth/auth_service.dart';
import 'package:trini/services/crud/workouts_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final WorkoutService _workoutsService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _workoutsService = WorkoutService();
    _workoutsService.open();
    super.initState();
  }

  @override
  void dispose() {
    _workoutsService.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Workouts"), actions: [
        PopupMenuButton<MenuAction>(
          onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  await AuthService.firebase().logOut();
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
      body: FutureBuilder(
        future: _workoutsService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _workoutsService.allWorkouts,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text("Waiting for all workouts...");
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
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
