import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Color tokens from docs/DESIGN_SYSTEM.md §2. Contrast ratios are checked by
/// test/theme/contrast_test.dart; change a value here only together with the doc.
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.divider,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.info,
    required this.attention,
    required this.capacity,
    required this.success,
    required this.danger,
    required this.infoContainer,
    required this.attentionContainer,
    required this.capacityContainer,
    required this.successContainer,
    required this.dangerContainer,
    required this.subjects,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color divider;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color info;
  final Color attention;

  /// More work than time. A steady indigo ink, deliberately not red: the app
  /// is honest about capacity without sounding an alarm (PRODUCT.md).
  final Color capacity;
  final Color success;

  /// Real failures only (errors, destructive confirmations). Never used for
  /// workload warnings.
  final Color danger;
  final Color infoContainer;
  final Color attentionContainer;
  final Color capacityContainer;
  final Color successContainer;
  final Color dangerContainer;

  /// The 10-color subject palette, indexed by `subjects.colorIndex`:
  /// Blue, Plum, Green, Rose, Orange, Olive, Ochre, Sky, Slate, Brown.
  /// Kept visibly apart from the accent and capacity colors (contrast test).
  final List<Color> subjects;

  static const light = AppPalette(
    background: Color(0xFFF6F7F8),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEF0F2),
    divider: Color(0xFFE3E6EA),
    outline: Color(0xFF8A929C),
    textPrimary: Color(0xFF15181C),
    textSecondary: Color(0xFF4A525C),
    accent: Color(0xFF0F766E),
    onAccent: Color(0xFFFFFFFF),
    accentContainer: Color(0xFFD5F0EC),
    info: Color(0xFF3B5B7A),
    attention: Color(0xFF8A5A00),
    capacity: Color(0xFF52398F),
    success: Color(0xFF1E7A3C),
    danger: Color(0xFFB42318),
    infoContainer: Color(0xFFE6EEF6),
    attentionContainer: Color(0xFFFFF1D6),
    capacityContainer: Color(0xFFECE8F6),
    successContainer: Color(0xFFDFF3E5),
    dangerContainer: Color(0xFFFDE7E5),
    subjects: [
      Color(0xFF255893),
      Color(0xFF8F3D8F),
      Color(0xFF339955),
      Color(0xFF8E294B),
      Color(0xFFA54312),
      Color(0xFF719C1C),
      Color(0xFFAA7B0E),
      Color(0xFF1281A5),
      Color(0xFF535A65),
      Color(0xFF815637),
    ],
  );

  static const dark = AppPalette(
    background: Color(0xFF111315),
    surface: Color(0xFF1A1D21),
    surfaceVariant: Color(0xFF23272C),
    divider: Color(0xFF2C3136),
    outline: Color(0xFF6B7380),
    textPrimary: Color(0xFFE8EAED),
    textSecondary: Color(0xFFA9B0B9),
    accent: Color(0xFF5EC4B6),
    onAccent: Color(0xFF04201D),
    accentContainer: Color(0xFF12403B),
    info: Color(0xFF9DB8D6),
    attention: Color(0xFFF2C063),
    capacity: Color(0xFFB09FDB),
    success: Color(0xFF7BD39A),
    danger: Color(0xFFFF8A80),
    infoContainer: Color(0xFF1D2B3A),
    attentionContainer: Color(0xFF3A2C10),
    capacityContainer: Color(0xFF29234A),
    successContainer: Color(0xFF173222),
    dangerContainer: Color(0xFF3D1D1B),
    subjects: [
      Color(0xFF7CAADE),
      Color(0xFFC270C2),
      Color(0xFF94DBAC),
      Color(0xFFDA819E),
      Color(0xFFEF986C),
      Color(0xFFC0E774),
      Color(0xFFF3C968),
      Color(0xFF6CCEEF),
      Color(0xFF9AA2AC),
      Color(0xFFCEA88D),
    ],
  );
}

/// 4-pt spacing scale (DESIGN_SYSTEM §4).
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Page gutter for compact widths; medium and expanded use [xl].
  static const double gutterCompact = lg;

  /// Maximum width of a reading column.
  static const double maxContentWidth = 720;
}

/// Corner radii (DESIGN_SYSTEM §4).
abstract final class Radii {
  static const chip = Radius.circular(4);
  static const block = Radius.circular(8);
  static const sheet = Radius.circular(16);
}

/// Motion tokens (DESIGN_SYSTEM §6). Callers use [Motion.duration] so reduced
/// motion turns transitions instant.
abstract final class Motion {
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 200);
  static const long = Duration(milliseconds: 250);
  static const curve = Curves.easeOutCubic;

  static Duration duration(Duration base, {required bool reduceMotion}) =>
      reduceMotion ? Duration.zero : base;
}

/// Width classes from docs/RESPONSIVE_DESIGN.md §1.
enum WidthClass {
  compact,
  medium,
  expanded;

  /// Layout class of a window. A window shorter than [compactMaxHeight] (a
  /// phone in landscape) stays compact whatever its width
  /// (RESPONSIVE_DESIGN §4).
  static WidthClass ofSize(Size size) =>
      size.height < compactMaxHeight ? WidthClass.compact : of(size.width);

  static const double compactMaxHeight = 480;

  static WidthClass of(double width) {
    if (width < 600) return WidthClass.compact;
    if (width < 840) return WidthClass.medium;
    return WidthClass.expanded;
  }
}
