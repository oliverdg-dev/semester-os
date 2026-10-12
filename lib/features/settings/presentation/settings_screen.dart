import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_info.dart';
import '../../../app/router.dart';
import '../../../core/errors/error_log.dart';
import '../../../core/widgets/page_scaffold.dart';
import '../../../core/widgets/settings_list.dart';

/// Settings. Phase 1 ships About & diagnostics; planning defaults, study times,
/// theme, reminders and backup arrive with their phases.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: 'About & diagnostics',
                subtitle: 'Version, data format and recent error codes',
                icon: Icons.info_outline,
                iosIcon: CupertinoIcons.info_circle,
                onTap: () => context.pushNamed(Routes.aboutHere(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Settings > About: version, schema version, last error code and a copy
/// button. Contains error codes and types only, never task or subject content.
class AboutDiagnosticsScreen extends ConsumerWidget {
  const AboutDiagnosticsScreen({super.key});

  static String diagnosticsText(ErrorLog log) {
    final buffer = StringBuffer()
      ..writeln('SemesterOS ${AppInfo.version}')
      ..writeln('Data format (schema) ${AppInfo.schemaVersion}')
      ..writeln('Recent errors: ${log.entries.length}');
    for (final entry in log.entries.reversed.take(20)) {
      buffer.writeln(entry.format());
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(errorLogProvider);
    final last = log.last;
    return DetailScaffold(
      title: 'About & diagnostics',
      body: ListView(
        children: [
          SettingsSection(
            header: 'This app',
            tiles: [
              const SettingsTile(title: 'Version', value: AppInfo.version),
              SettingsTile(
                title: 'Data format',
                value: '${AppInfo.schemaVersion}',
              ),
              const SettingsTile(
                title: 'Your data',
                subtitle: 'Everything stays on this device.',
              ),
            ],
          ),
          SettingsSection(
            header: 'Diagnostics',
            tiles: [
              SettingsTile(
                title: 'Last error',
                value: last == null ? 'None' : '${last.code} (${last.type})',
              ),
              SettingsTile(
                title: 'Copy diagnostics',
                isAction: true,
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: diagnosticsText(log)),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Diagnostics copied')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
