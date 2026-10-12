import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

/// The single SQLite database. Tables arrive in Phase 2 (schema v1 in
/// docs/ARCHITECTURE.md §5); only repositories may use this class.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device file in a background isolate.
  factory AppDatabase.file(File file) =>
      AppDatabase(NativeDatabase.createInBackground(file));

  /// In-memory database for tests.
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  /// Highest schema version this build understands. DbGuard refuses files
  /// written by a newer build.
  static const int currentSchemaVersion = 1;

  /// File name inside the application support directory.
  static const String fileName = 'semesteros.db';

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Overridden in main() and in tests with an opened database.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);
