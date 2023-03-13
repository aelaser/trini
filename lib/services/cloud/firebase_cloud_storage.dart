import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trini/services/cloud/cloud_workout.dart';
import 'package:trini/services/cloud/cloud_storage_constants.dart';
import 'package:trini/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final workouts = FirebaseFirestore.instance.collection('workouts');

  Future<void> deleteWorkout({required String documentId}) async {
    try {
      await workouts.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteWorkoutException();
    }
  }

  Future<void> updateWorkout({
    required String documentId,
    required String text,
    required String sets,
  }) async {
    try {
      await workouts
          .doc(documentId)
          .update({textFieldName: text, setsFieldName: sets});
    } catch (e) {
      throw CouldNotUpdateWorkoutException();
    }
  }

  Stream<Iterable<CloudWorkout>> allWorkouts({required String ownerUserId}) {
    final allWorkouts = workouts
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudWorkout.fromSnapshot(doc)));
    return allWorkouts;
  }

  Future<CloudWorkout> createNewWorkout({required String ownerUserId}) async {
    final document = await workouts.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
      setsFieldName: '',
    });
    final fetchedWorkout = await document.get();
    return CloudWorkout(
      documentId: fetchedWorkout.id,
      ownerUserId: ownerUserId,
      text: '',
      sets: '',
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
