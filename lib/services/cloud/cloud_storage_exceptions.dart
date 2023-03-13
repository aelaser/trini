class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateWorkoutException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllWorkoutsException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateWorkoutException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteWorkoutException extends CloudStorageException {}
