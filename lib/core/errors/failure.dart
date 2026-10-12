/// Coded failures shown to the user. Every subclass must have a row in
/// docs/ERRORS.md; test/core/errors_catalogue_test.dart enforces it.
sealed class Failure implements Exception {
  const Failure();

  /// Stable code `SEM-<AREA>-<NNN>`; never reused.
  String get code;

  /// Plain-language message for the user (no technical detail).
  String get userMessage;

  @override
  String toString() => '$runtimeType($code)';
}

/// Unexpected exception caught by a global handler.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
  @override
  String get code => 'SEM-APP-001';
  @override
  String get userMessage => 'Something went wrong on this screen.';
}

/// `PRAGMA quick_check` failed or the file is not a SQLite database.
final class DatabaseCorruptFailure extends Failure {
  const DatabaseCorruptFailure();
  @override
  String get code => 'SEM-DB-001';
  @override
  String get userMessage => "SemesterOS couldn't open your data safely.";
}

/// The database was written by a newer app version.
final class DatabaseTooNewFailure extends Failure {
  const DatabaseTooNewFailure({required this.found, required this.supported});
  final int found;
  final int supported;
  @override
  String get code => 'SEM-DB-002';
  @override
  String get userMessage =>
      'This data was made by a newer version of SemesterOS.';
}

/// A write failed and was rolled back.
final class DatabaseWriteFailure extends Failure {
  const DatabaseWriteFailure();
  @override
  String get code => 'SEM-DB-003';
  @override
  String get userMessage => "Couldn't save. Nothing was changed.";
}

/// Corruption detected after the database was opened.
final class DatabaseRuntimeCorruptFailure extends Failure {
  const DatabaseRuntimeCorruptFailure();
  @override
  String get code => 'SEM-DB-004';
  @override
  String get userMessage => "SemesterOS couldn't read your data safely.";
}
