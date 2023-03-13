import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trini/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudWorkout {
  // this a primary ket generated by firebase
  final String documentId;
  final String ownerUserId;
  final String text;
  const CloudWorkout({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudWorkout.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
