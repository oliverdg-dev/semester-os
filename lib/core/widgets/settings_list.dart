import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import 'page_scaffold.dart';

/// One row of a settings-shaped list. Exactly one of [subtitle] and [value]
/// is usually set: [subtitle] explains, [value] shows the current setting.
class SettingsTile {
  const SettingsTile({
    required this.title,
    this.subtitle,
    this.value,
    this.icon,
    this.iosIcon,
    this.onTap,
    this.isAction = false,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final IconData? icon;
  final IconData? iosIcon;
  final VoidCallback? onTap;

  /// An action row (e.g. "Copy diagnostics"): tinted, no chevron.
  final bool isAction;
}

/// A group of settings rows (BD6): an inset grouped list on iOS, Material
/// list tiles on Android.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.header, required this.tiles});

  final String? header;
  final List<SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isCupertinoPlatform(theme.platform)) return _ios(context, theme);
    final gutter = pageGutter(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, Space.lg, gutter, Space.sm),
            child: Semantics(
              header: true,
              child: Text(
                header!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        for (final t in tiles)
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: gutter),
            leading: t.icon == null ? null : Icon(t.icon),
            title: Text(
              t.title,
              style: t.isAction
                  ? TextStyle(color: theme.colorScheme.primary)
                  : null,
            ),
            subtitle: t.subtitle == null ? null : Text(t.subtitle!),
            trailing: t.value == null
                ? null
                : Text(t.value!, style: context.appText.numeric),
            onTap: t.onTap,
          ),
      ],
    );
  }

  Widget _ios(BuildContext context, ThemeData theme) {
    final scheme = theme.colorScheme;
    return CupertinoListSection.insetGrouped(
      header: header == null ? null : Text(header!.toUpperCase()),
      backgroundColor: theme.scaffoldBackgroundColor,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      separatorColor: scheme.outlineVariant,
      children: [
        for (final t in tiles)
          CupertinoListTile.notched(
            leading: t.iosIcon == null
                ? null
                : Icon(t.iosIcon, color: scheme.primary),
            title: Text(
              t.title,
              style: TextStyle(
                color: t.isAction ? scheme.primary : scheme.onSurface,
              ),
            ),
            subtitle: t.subtitle == null
                ? null
                : Text(
                    t.subtitle!,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
            additionalInfo: t.value == null
                ? null
                : Text(
                    t.value!,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
            trailing: t.onTap != null && !t.isAction
                ? const CupertinoListTileChevron()
                : null,
            onTap: t.onTap,
          ),
      ],
    );
  }
}
