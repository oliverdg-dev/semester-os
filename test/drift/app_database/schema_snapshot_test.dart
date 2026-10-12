import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/core/database/app_database.dart';

import 'generated/schema.dart';

/// The committed snapshot drift_schemas/app_database/drift_schema_v1.json must
/// match what the code creates. If this fails after a table change, bump the
/// schema version and run `dart run drift_dev make-migrations`
/// (ARCHITECTURE §15).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('schema v1 matches the committed snapshot', () async {
    // A fresh database runs the app's own onCreate; its schema is compared
    // with the committed snapshot of the same version.
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, AppDatabase.currentSchemaVersion);
  });
}
