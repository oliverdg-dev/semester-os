import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_info.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/error_log.dart';

/// Settings. Phase 1 ships About & diagnostics; planning defaults, study times,
/// theme, reminders and backup arrive with their phases.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About & diagnostics'),
            subtitle: const Text('Version, data format and recent error codes'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AboutDiagnosticsScreen(),
              ),
            ),
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
    final theme = Theme.of(context);
    final last = log.last;
    return Scaffold(
      appBar: AppBar(title: const Text('About & diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          Text(
            'SemesterOS ${AppInfo.version}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: Space.xs),
          Text(
            'Data format ${AppInfo.schemaVersion} · Everything stays on this device.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Space.xl),
          Text('Last error', style: theme.textTheme.titleMedium),
          const SizedBox(height: Space.xs),
          Text(
            last == null ? 'None' : '${last.code} (${last.type})',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: Space.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy diagnostics'),
              onPressed: () async {
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
          ),
        ],
      ),
    );
  }
}
