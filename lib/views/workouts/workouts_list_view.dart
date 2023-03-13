import 'package:flutter/material.dart';
import 'package:trini/services/cloud/cloud_workout.dart';
import 'package:trini/utilities/dialogs/delete_dialog.dart';

typedef WorkoutCallback = void Function(CloudWorkout workout);

class WorkoutsListView extends StatelessWidget {
  final Iterable<CloudWorkout> workouts;
  final WorkoutCallback onDeleteWorkout;
  final WorkoutCallback onTap;

  const WorkoutsListView({
    Key? key,
    required this.workouts,
    required this.onDeleteWorkout,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(workout);
          },
          title: Text(
            workout.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          // trailing: IconButton(
          //   onPressed: () async {
          //     final shouldDelete = await showDeleteDialog(context);
          //     if (shouldDelete) {
          //       onDeleteWorkout(workout);
          //     }
          //   },
          //   icon: const Icon(Icons.delete),
          // ),
        );
      },
    );
  }
}
