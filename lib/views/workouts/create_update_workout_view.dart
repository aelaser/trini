import 'package:flutter/material.dart';
// import 'package:trini/extensions/buildcontext/loc.dart';
import 'package:trini/services/auth/auth_service.dart';
// import 'package:trini/utilities/dialogs/cannot_share_empty_workout_dialog.dart';
import 'package:trini/utilities/generics/get_arguments.dart';
import 'package:trini/services/cloud/cloud_workout.dart';
import 'package:trini/services/cloud/firebase_cloud_storage.dart';

class CreateUpdateWorkoutView extends StatefulWidget {
  const CreateUpdateWorkoutView({Key? key}) : super(key: key);

  @override
  _CreateUpdateWorkoutViewState createState() =>
      _CreateUpdateWorkoutViewState();
}

class _CreateUpdateWorkoutViewState extends State<CreateUpdateWorkoutView> {
  CloudWorkout? _workout;
  late final FirebaseCloudStorage _workoutsService;
  late final TextEditingController _textController;
  late final TextEditingController _setsController;

  @override
  void initState() {
    _workoutsService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _setsController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final workout = _workout;
    if (workout == null) {
      return;
    }
    final text = _textController.text;
    final sets = _setsController.text;
    await _workoutsService.updateWorkout(
      documentId: workout.documentId,
      text: text,
      sets: sets,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _setsController.addListener(_textControllerListener);
    _setsController.removeListener(_textControllerListener);
  }

  Future<CloudWorkout> createOrGetExistingWorkout(BuildContext context) async {
    final widgetWorkout = context.getArgument<CloudWorkout>();

    if (widgetWorkout != null) {
      _workout = widgetWorkout;
      _textController.text = widgetWorkout.text;
      _setsController.text = widgetWorkout.sets;
      return widgetWorkout;
    }

    final existingWorkout = _workout;
    if (existingWorkout != null) {
      return existingWorkout;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newWorkout =
        await _workoutsService.createNewWorkout(ownerUserId: userId);
    _workout = newWorkout;
    return newWorkout;
  }

  void _deleteWorkoutIfTextIsEmpty() {
    final workout = _workout;
    if (_textController.text.isEmpty && workout != null) {
      _workoutsService.deleteWorkout(documentId: workout.documentId);
    }
  }

  void _saveWorkoutIfTextNotEmpty() async {
    final workout = _workout;
    final text = _textController.text;
    final sets = _setsController.text;
    if (workout != null && text.isNotEmpty) {
      await _workoutsService.updateWorkout(
        documentId: workout.documentId,
        text: text,
        sets: sets,
      );
    }
  }

  @override
  void dispose() {
    _deleteWorkoutIfTextIsEmpty();
    _saveWorkoutIfTextNotEmpty();
    _textController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Workout",
        ),
      ),
      body: FutureBuilder(
        future: createOrGetExistingWorkout(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Column(
                children: [
                  TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Start typing you workout",
                    ),
                  ),
                  TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Start typing your sets",
                    ),
                  ),
                ],
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
