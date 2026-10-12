import 'package:flutter/foundation.dart';
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

  /// Interpolates every color so status colors move with the rest of the
  /// theme during a light/dark change instead of snapping halfway.
  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return SemanticColors(
      info: mix(info, other.info),
      attention: mix(attention, other.attention),
      capacity: mix(capacity, other.capacity),
      success: mix(success, other.success),
      infoContainer: mix(infoContainer, other.infoContainer),
      attentionContainer: mix(attentionContainer, other.attentionContainer),
      capacityContainer: mix(capacityContainer, other.capacityContainer),
      successContainer: mix(successContainer, other.successContainer),
      textSecondary: mix(textSecondary, other.textSecondary),
      subjects: [
        for (var i = 0; i < subjects.length; i++)
          mix(subjects[i], other.subjects[i]),
      ],
    );
  }
}

/// Text roles the Material text theme has no slot for (DESIGN_SYSTEM §3).
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.numeric,
    required this.numericLarge,
    required this.timer,
    required this.dateLine,
  });

  /// Times, durations and counts in running text (tabular figures).
  final TextStyle numeric;

  /// Headline-sized numbers such as "1 h 40 m of 3 h" (tabular figures).
  final TextStyle numericLarge;

  /// The session timer (tabular figures so digits do not jitter).
  final TextStyle timer;

  /// The date line under a page title ("Monday 12 October").
  final TextStyle dateLine;

  @override
  AppTextStyles copyWith() => this;

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      numeric: TextStyle.lerp(numeric, other.numeric, t)!,
      numericLarge: TextStyle.lerp(numericLarge, other.numericLarge, t)!,
      timer: TextStyle.lerp(timer, other.timer, t)!,
      dateLine: TextStyle.lerp(dateLine, other.dateLine, t)!,
    );
  }
}

/// Bundled content typeface (IBM Plex Sans 1.1.0, SIL OFL) declared in
/// pubspec.yaml from assets/fonts/. Never fetched at runtime.
const String kAppFontFamily = 'IBM Plex Sans';

/// The iOS system text face (SF Pro), used for iOS controls: navigation
/// titles, tab labels and settings rows (BD6, DESIGN_SYSTEM §3).
const String kIosSystemFontFamily = 'CupertinoSystemText';

/// Whether [platform] follows the iOS conventions (BD6).
bool isCupertinoPlatform(TargetPlatform platform) =>
    platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

const _tabular = [FontFeature.tabularFigures()];

TextStyle _style(
  double size,
  double height,
  FontWeight weight,
  Color color, {
  String family = kAppFontFamily,
  List<FontFeature>? features,
}) => TextStyle(
  fontFamily: family,
  fontSize: size,
  height: height / size,
  fontWeight: weight,
  color: color,
  fontFeatures: features,
);

const _regular = FontWeight.w400;
const _medium = FontWeight.w500;
const _semiBold = FontWeight.w600;

TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
  displaySmall: _style(32, 40, _semiBold, primary),
  headlineSmall: _style(24, 32, _semiBold, primary),
  titleLarge: _style(20, 28, _semiBold, primary),
  titleMedium: _style(16, 24, _semiBold, primary),
  titleSmall: _style(14, 20, _semiBold, primary),
  bodyLarge: _style(16, 24, _regular, primary),
  bodyMedium: _style(16, 24, _regular, primary),
  bodySmall: _style(14, 20, _regular, secondary),
  labelLarge: _style(14, 20, _medium, primary),
  labelMedium: _style(12, 16, _medium, secondary),
  labelSmall: _style(12, 16, _regular, secondary),
);

/// Every Material color role, mapped from the palette rather than derived from
/// a seed, so components added later (FAB, segmented buttons, snackbars,
/// switches, dialogs) use colors that test/theme/contrast_test.dart checks.
ColorScheme schemeFor(Brightness brightness) {
  final p = brightness == Brightness.light ? AppPalette.light : AppPalette.dark;
  final inverse = brightness == Brightness.light
      ? AppPalette.dark
      : AppPalette.light;
  return ColorScheme(
    brightness: brightness,
    primary: p.accent,
    onPrimary: p.onAccent,
    primaryContainer: p.accentContainer,
    onPrimaryContainer: p.textPrimary,
    primaryFixed: p.accentContainer,
    primaryFixedDim: p.accentContainer,
    onPrimaryFixed: p.textPrimary,
    onPrimaryFixedVariant: p.textPrimary,
    secondary: p.accent,
    onSecondary: p.onAccent,
    secondaryContainer: p.accentContainer,
    onSecondaryContainer: p.textPrimary,
    secondaryFixed: p.accentContainer,
    secondaryFixedDim: p.accentContainer,
    onSecondaryFixed: p.textPrimary,
    onSecondaryFixedVariant: p.textPrimary,
    tertiary: p.info,
    onTertiary: p.surface,
    tertiaryContainer: p.infoContainer,
    onTertiaryContainer: p.textPrimary,
    tertiaryFixed: p.infoContainer,
    tertiaryFixedDim: p.infoContainer,
    onTertiaryFixed: p.textPrimary,
    onTertiaryFixedVariant: p.textPrimary,
    error: p.danger,
    onError: p.surface,
    errorContainer: p.dangerContainer,
    onErrorContainer: p.textPrimary,
    surface: p.surface,
    onSurface: p.textPrimary,
    onSurfaceVariant: p.textSecondary,
    surfaceDim: p.surfaceVariant,
    surfaceBright: p.surface,
    // Sheets, dialogs and menus share one raised surface; filled inputs and
    // the highest containers use surfaceVariant.
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surface,
    surfaceContainerHighest: p.surfaceVariant,
    outline: p.outline,
    outlineVariant: p.divider,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    // Snackbars: the opposite theme's surface and text, with its accent for
    // the action (Undo).
    inverseSurface: inverse.surface,
    onInverseSurface: inverse.textPrimary,
    inversePrimary: inverse.accent,
    surfaceTint: const Color(0x00000000),
  );
}

/// The app theme for [brightness] on [platform] (BD6: iOS follows the HIG,
/// Android Material 3). Content text uses IBM Plex Sans on both; iOS controls
/// use the system face.
ThemeData buildTheme(Brightness brightness, {TargetPlatform? platform}) {
  final target = platform ?? defaultTargetPlatform;
  final cupertino = isCupertinoPlatform(target);
  final p = brightness == Brightness.light ? AppPalette.light : AppPalette.dark;
  final scheme = schemeFor(brightness);
  final text = _textTheme(p.textPrimary, p.textSecondary);
  const blockShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.block),
  );

  // iOS navigation titles: SF 17 semibold, centered (HIG). Android: the
  // Material small top app bar title.
  final barTitle = cupertino
      ? _style(17, 22, _semiBold, p.textPrimary, family: kIosSystemFontFamily)
      : text.titleLarge;

  return ThemeData(
    useMaterial3: true,
    platform: target,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    fontFamily: kAppFontFamily,
    textTheme: text,
    dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: barTitle,
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
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.accentContainer,
      elevation: 0,
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radii.block),
      ),
    ),
    // The drawer is permanent (expanded Android), so it has square edges
    // against the divider instead of a modal drawer's rounded end.
    drawerTheme: DrawerThemeData(
      backgroundColor: p.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
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
    extensions: [
      SemanticColors.fromPalette(p),
      AppTextStyles(
        numeric: text.bodyLarge!.copyWith(fontFeatures: _tabular),
        numericLarge: text.headlineSmall!.copyWith(fontFeatures: _tabular),
        timer: _style(56, 64, _medium, p.textPrimary, features: _tabular),
        dateLine: _style(14, 20, _medium, p.textSecondary, features: _tabular),
      ),
    ],
  );
}

extension SemanticColorsX on BuildContext {
  SemanticColors get semantic => Theme.of(this).extension<SemanticColors>()!;
  AppTextStyles get appText => Theme.of(this).extension<AppTextStyles>()!;
}
