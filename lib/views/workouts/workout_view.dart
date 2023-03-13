import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trini/constants/routes.dart';
import 'package:trini/enums/menu_action.dart';
import 'package:trini/services/auth/auth_service.dart';
import 'package:trini/services/cloud/cloud_workout.dart';
import 'package:trini/services/cloud/firebase_cloud_storage.dart';
import 'package:trini/views/workouts/workouts_list_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final FirebaseCloudStorage _workoutsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _workoutsService = FirebaseCloudStorage();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("All Workouts"), actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateWorkouteRoute);
            },
            icon: const Icon(Icons.add),
          ),
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
        body: StreamBuilder(
          stream: _workoutsService.allWorkouts(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allWorkouts = snapshot.data as Iterable<CloudWorkout>;
                  return WorkoutsListView(
                    workouts: allWorkouts,
                    onDeleteWorkout: (workout) async {
                      await _workoutsService.deleteWorkout(
                          documentId: workout.documentId);
                    },
                    onTap: (workout) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateWorkouteRoute,
                        arguments: workout,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
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
