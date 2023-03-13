// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'package:trini/services/crud/crud_exceptions.dart';

// class WorkoutService {
//   Database? _db;

//   // stream controller
//   List<DatabaseWorkout> _workouts = [];

//   static final WorkoutService _shared = WorkoutService._sharedWorkouts();
//   WorkoutService._sharedWorkouts() {
//     _workoutsStreamController =
//         StreamController<List<DatabaseWorkout>>.broadcast(
//       onListen: () {
//         _workoutsStreamController.sink.add(_workouts);
//       },
//     );
//   }
//   factory WorkoutService() => _shared;

//   late final StreamController<List<DatabaseWorkout>> _workoutsStreamController;

//   Stream<List<DatabaseWorkout>> get allWorkouts =>
//       _workoutsStreamController.stream;

//   Future<DatabaseUser> getOrCreateUser({required String email}) async {
//     try {
//       final user = await getUser(email: email);
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cashWorkouts() async {
//     final allWorkouts = await getAllWorkouts();
//     _workouts = allWorkouts.toList();
//     _workoutsStreamController.add(_workouts);
//   }

//   // update your workouts
//   Future<DatabaseWorkout> updateWorkout({
//     required DatabaseWorkout workout,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     // make sure workout exists
//     await getWorkout(id: workout.id);

//     // update DB
//     final updatesCount = await db.update(workoutTable, {
//       textColumn: text,
//       isSyncedWithCloudColumn: 0,
//     });

//     if (updatesCount == 0) {
//       throw CouldNotUpdateWorkout;
//     } else {
//       final updateWorkout = await getWorkout(id: workout.id);
//       _workouts.removeWhere((workout) => workout.id == updateWorkout.id);
//       _workouts.add(updateWorkout);
//       _workoutsStreamController.add(_workouts);
//       return updateWorkout;
//     }
//   }

//   // Get all workouts
//   Future<Iterable<DatabaseWorkout>> getAllWorkouts() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final workouts = await db.query(
//       workoutTable,
//     );

//     return workouts.map((workoutRow) => DatabaseWorkout.fromRow(workoutRow));
//   }

//   // Get one workout
//   Future<DatabaseWorkout> getWorkout({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final workouts = await db.query(
//       workoutTable,
//       limit: 1,
//       where: "id = ?",
//       whereArgs: [id],
//     );

//     if (workouts.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       final workout = DatabaseWorkout.fromRow(workouts.first);
//       _workouts.removeWhere((workout) => workout.id == id);
//       _workouts.add(workout);
//       _workoutsStreamController.add(_workouts);
//       return workout;
//     }
//   }

//   // Delete all workouts
//   Future<int> deleteAllWorkouts() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = db.delete(workoutTable);
//     _workouts = [];
//     _workoutsStreamController.add(_workouts);
//     return numberOfDeletions;
//   }

//   Future<void> deleteWorkout({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteWorkout();
//     } else {
//       _workouts.removeWhere((workout) => workout.id == id);
//       _workoutsStreamController.add(_workouts);
//     }
//   }

//   Future<DatabaseWorkout> createWorkout({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     // make sure owner exists in the databse with the correct id
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }

//     const text = '';

//     // create the note
//     final workoutId = await db.insert(workoutTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final workout = DatabaseWorkout(
//       id: workoutId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     _workouts.add(workout);
//     _workoutsStreamController.add(_workouts);

//     return workout;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {}
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       // create the user table
//       await db.execute(createUserTable);

//       // create workout table
//       await db.execute(createWorkoutTable);
//       await _cashWorkouts();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirecotory();
//     }
//   }
// }

// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => "Person, ID = $id, email = $email";

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseWorkout {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseWorkout(
//       {required this.id,
//       required this.userId,
//       required this.text,
//       required this.isSyncedWithCloud});

//   DatabaseWorkout.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       "Exercise, ID = $id, email = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text";

//   @override
//   bool operator ==(covariant DatabaseWorkout other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'workouts.db';

// const idColumn = "id";
// const workoutTable = "workout";
// const userTable = "user";
// const emailColumn = "email";
// const userIdColumn = "user_id";
// const textColumn = 'text';
// const isSyncedWithCloudColumn = "is_synced_with_cloud";
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//         "id"	INTEGER NOT NULL,
//         "email"	TEXT NOT NULL UNIQUE,
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );
//       ''';

// const createWorkoutTable = '''CREATE TABLE IF NOT EXISTS "workout" (
//           "id"	INTEGER NOT NULL,
//           "user_id"	INTEGER NOT NULL,
//           "text"	TEXT,
//           "is_synced_with_cloud"	INTEGER DEFAULT 0,
//           PRIMARY KEY("id" AUTOINCREMENT),
//           FOREIGN KEY("user_id") REFERENCES "user"("id")
//         );
//         ''';
