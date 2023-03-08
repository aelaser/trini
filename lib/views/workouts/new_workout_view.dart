import 'package:flutter/material.dart';

class NewWorkoutView extends StatefulWidget {
  const NewWorkoutView({super.key});

  @override
  State<NewWorkoutView> createState() => _NewWorkoutViewState();
}

class _NewWorkoutViewState extends State<NewWorkoutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Workout"),
      ),
      body: const Text("Write your new workout here..."),
    );
  }
}
