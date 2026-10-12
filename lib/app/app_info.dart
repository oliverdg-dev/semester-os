import '../core/database/app_database.dart';

/// Build facts shown in Settings > About. Keep [version] in sync with pubspec.yaml
/// (test/app/app_info_test.dart checks it).
abstract final class AppInfo {
  static const String version = '0.1.0';
  static const int schemaVersion = AppDatabase.currentSchemaVersion;
}
