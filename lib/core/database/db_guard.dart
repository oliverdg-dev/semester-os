import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

enum DbGuardStatus { missing, ok, corrupt, tooNew }

class DbGuardResult {
  const DbGuardResult(this.status, {this.foundVersion});
  final DbGuardStatus status;

  /// `PRAGMA user_version` of the file, when it could be read.
  final int? foundVersion;

  bool get canOpen =>
      status == DbGuardStatus.ok || status == DbGuardStatus.missing;
}

/// Checks the database file with raw sqlite3 before Drift opens it
/// (ARCHITECTURE §10): integrity via `PRAGMA quick_check`, then
/// `PRAGMA user_version` against the schema version this build supports.
abstract final class DbGuard {
  static DbGuardResult check(
    String path, {
    required int supportedSchemaVersion,
  }) {
    if (!File(path).existsSync()) {
      return const DbGuardResult(DbGuardStatus.missing);
    }
    Database? db;
    try {
      db = sqlite3.open(path);
      final rows = db.select('PRAGMA quick_check');
      final healthy = rows.length == 1 && rows.first.values.first == 'ok';
      if (!healthy) return const DbGuardResult(DbGuardStatus.corrupt);
      final version = db.userVersion;
      if (version > supportedSchemaVersion) {
        return DbGuardResult(DbGuardStatus.tooNew, foundVersion: version);
      }
      return DbGuardResult(DbGuardStatus.ok, foundVersion: version);
    } on SqliteException {
      return const DbGuardResult(DbGuardStatus.corrupt);
    } finally {
      db?.close();
    }
  }

  /// SQLITE_CORRUPT (11) and SQLITE_NOTADB (26): errors that send the user to
  /// the recovery screen when they surface after open.
  static bool isCorruption(Object error) =>
      error is SqliteException &&
      (error.resultCode == 11 || error.resultCode == 26);
}
