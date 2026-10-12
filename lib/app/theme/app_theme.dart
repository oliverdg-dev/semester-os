import 'package:flutter/material.dart';

import 'tokens.dart';

/// Semantic status colors that Material's ColorScheme has no slot for.
/// Always paired with an icon and a text label (DESIGN_SYSTEM §8).
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.info,
    required this.attention,
    required this.capacity,
    required this.success,
    required this.infoContainer,
    required this.attentionContainer,
    required this.capacityContainer,
    required this.successContainer,
    required this.textSecondary,
    required this.subjects,
  });

  factory SemanticColors.fromPalette(AppPalette p) => SemanticColors(
    info: p.info,
    attention: p.attention,
    capacity: p.capacity,
    success: p.success,
    infoContainer: p.infoContainer,
    attentionContainer: p.attentionContainer,
    capacityContainer: p.capacityContainer,
    successContainer: p.successContainer,
    textSecondary: p.textSecondary,
    subjects: p.subjects,
  );

  final Color info;
  final Color attention;
  final Color capacity;
  final Color success;
  final Color infoContainer;
  final Color attentionContainer;
  final Color capacityContainer;
  final Color successContainer;
  final Color textSecondary;
  final List<Color> subjects;

  @override
  SemanticColors copyWith() => this;

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) =>
      t < 0.5 || other is! SemanticColors ? this : other;
}

/// Bundled UI typeface. Null until the IBM Plex Sans files are added under
/// assets/fonts/ (Phase 1 checklist); the platform default is used meanwhile.
const String? kAppFontFamily = null;

TextTheme _textTheme(Color primary, Color secondary) {
  TextStyle style(double size, double height, FontWeight weight, Color color) =>
      TextStyle(
        fontFamily: kAppFontFamily,
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        color: color,
      );
  const regular = FontWeight.w400;
  const medium = FontWeight.w500;
  const semiBold = FontWeight.w600;
  return TextTheme(
    displaySmall: style(32, 40, semiBold, primary),
    headlineSmall: style(24, 32, semiBold, primary),
    titleLarge: style(20, 28, semiBold, primary),
    titleMedium: style(16, 24, medium, primary),
    bodyLarge: style(16, 24, regular, primary),
    bodyMedium: style(16, 24, regular, primary),
    bodySmall: style(14, 20, regular, secondary),
    labelLarge: style(14, 20, medium, primary),
    labelMedium: style(12, 16, medium, secondary),
    labelSmall: style(12, 16, regular, secondary),
  );
}

ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.light ? AppPalette.light : AppPalette.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: p.accent,
        brightness: brightness,
      ).copyWith(
        primary: p.accent,
        onPrimary: p.onAccent,
        primaryContainer: p.accentContainer,
        surface: p.surface,
        onSurface: p.textPrimary,
        onSurfaceVariant: p.textSecondary,
        surfaceContainerLowest: p.surface,
        surfaceContainerLow: p.surface,
        surfaceContainer: p.surfaceVariant,
        surfaceContainerHigh: p.surfaceVariant,
        surfaceContainerHighest: p.surfaceVariant,
        outline: p.outline,
        outlineVariant: p.divider,
        error: p.capacity,
      );
  final text = _textTheme(p.textPrimary, p.textSecondary);
  const blockShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.block),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    fontFamily: kAppFontFamily,
    textTheme: text,
    dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.accentContainer,
      elevation: 0,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.accentContainer,
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radii.block),
        side: BorderSide(color: p.divider),
      ),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: const ListTileThemeData(
      shape: blockShape,
      minVerticalPadding: Space.md,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: blockShape,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: blockShape,
        side: BorderSide(color: p.outline),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radii.block),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radii.block),
        borderSide: BorderSide(color: p.outline),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radii.sheet),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radii.sheet),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    extensions: [SemanticColors.fromPalette(p)],
  );
}

extension SemanticColorsX on BuildContext {
  SemanticColors get semantic => Theme.of(this).extension<SemanticColors>()!;
}
