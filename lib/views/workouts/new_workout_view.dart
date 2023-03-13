// import 'package:flutter/material.dart';
// import 'package:trini/services/auth/auth_service.dart';
// import 'package:trini/services/crud/workouts_service.dart';

// class NewWorkoutView extends StatefulWidget {
//   const NewWorkoutView({super.key});

//   @override
//   State<NewWorkoutView> createState() => _NewWorkoutViewState();
// }

// class _NewWorkoutViewState extends State<NewWorkoutView> {
//   DatabaseWorkout? _workout;
//   late final WorkoutService _workoutsService;
//   late final TextEditingController _textController;

//   @override
//   void initState() {
//     _workoutsService = WorkoutService();
//     _textController = TextEditingController();
//     super.initState();
//   }

//   // update the current workout upon text changes
//   void _textControllerListner() async {
//     final workout = _workout;

//     if (workout == null) {
//       return;
//     }
//     final text = _textController.text;
//     await _workoutsService.updateWorkout(
//       workout: workout,
//       text: text,
//     );
//   }

//   void _setupTextControllerListner() {
//     _textController.removeListener(_textControllerListner);
//     _textController.addListener(_textControllerListner);
//   }

//   Future<DatabaseWorkout> createNewWorkout() async {
//     final existingWorkout = _workout;
//     if (existingWorkout != null) {
//       return existingWorkout;
//     }

//     final currentUser = AuthService.firebase().currentUser;
//     final email = currentUser!.email;
//     final owner = await _workoutsService.getUser(email: email);
//     return await _workoutsService.createWorkout(owner: owner);
//   }

//   void _deleteWorkoutIfTextIsEmpty() {
//     final workout = _workout;
//     if (_textController.text.isEmpty && workout != null) {
//       _workoutsService.deleteWorkout(id: workout.id);
//     }
//   }

//   void _saveWorkoutIfTextIsNotEmpty() async {
//     final workout = _workout;
//     final text = _textController.text;
//     if (workout != null && text.isNotEmpty) {
//       await _workoutsService.updateWorkout(
//         workout: workout,
//         text: text,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _deleteWorkoutIfTextIsEmpty();
//     _saveWorkoutIfTextIsNotEmpty();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("New Workout"),
//       ),
//       body: FutureBuilder(
//         future: createNewWorkout(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               _workout = snapshot.data as DatabaseWorkout;
//               _setupTextControllerListner();
//               return TextField(
//                 controller: _textController,
//                 keyboardType: TextInputType.multiline,
//                 maxLines: null,
//                 decoration:
//                     const InputDecoration(hintText: "Start adding sets here"),
//               );
//             default:
//               return const CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }
