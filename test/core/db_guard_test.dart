import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:semester_os/core/database/app_database.dart';
import 'package:semester_os/core/database/db_guard.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('semesteros_guard'));
  tearDown(() => dir.deleteSync(recursive: true));

  DbGuardResult check(String path) => DbGuard.check(
    path,
    supportedSchemaVersion: AppDatabase.currentSchemaVersion,
  );

  test('a missing file can be created', () {
    final result = check(p.join(dir.path, 'none.db'));
    expect(result.status, DbGuardStatus.missing);
    expect(result.canOpen, isTrue);
  });

  test('a healthy database at the current version opens', () {
    final path = p.join(dir.path, 'ok.db');
    sqlite3.open(path)
      ..userVersion = AppDatabase.currentSchemaVersion
      ..execute('CREATE TABLE t (x INTEGER)')
      ..close();
    final result = check(path);
    expect(result.status, DbGuardStatus.ok);
    expect(result.foundVersion, AppDatabase.currentSchemaVersion);
  });

  test('a file that is not a database is refused as corrupt', () {
    final path = p.join(dir.path, 'junk.db');
    File(path).writeAsStringSync(
      'this is not a sqlite database at all, just text' * 100,
    );
    final result = check(path);
    expect(result.status, DbGuardStatus.corrupt);
    expect(result.canOpen, isFalse);
  });

  test('a database from a newer app version is refused', () {
    final path = p.join(dir.path, 'new.db');
    sqlite3.open(path)
      ..userVersion = AppDatabase.currentSchemaVersion + 1
      ..close();
    final result = check(path);
    expect(result.status, DbGuardStatus.tooNew);
    expect(result.foundVersion, AppDatabase.currentSchemaVersion + 1);
  });

  test('corruption result codes are recognised', () {
    expect(
      DbGuard.isCorruption(
        SqliteException(extendedResultCode: 11, message: 'corrupt'),
      ),
      isTrue,
    );
    expect(
      DbGuard.isCorruption(
        SqliteException(extendedResultCode: 26, message: 'notadb'),
      ),
      isTrue,
    );
    expect(
      DbGuard.isCorruption(
        SqliteException(extendedResultCode: 19, message: 'constraint'),
      ),
      isFalse,
    );
  });

  test('the Drift database opens and answers a query', () async {
    final db = AppDatabase.file(File(p.join(dir.path, 'drift.db')));
    final row = await db.customSelect('SELECT 1 AS one').getSingle();
    expect(row.read<int>('one'), 1);
    await db.close();
  });
}
