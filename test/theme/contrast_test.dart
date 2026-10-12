import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/app/theme/app_theme.dart';
import 'package:semester_os/app/theme/tokens.dart';

/// WCAG 2.x contrast ratio between two opaque colors.
double contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, p) in [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
  ]) {
    group('$name palette (DESIGN_SYSTEM §2)', () {
      final backgrounds = {
        'surface': p.surface,
        'background': p.background,
        'surfaceVariant': p.surfaceVariant,
      };
      final texts = {
        'textPrimary': p.textPrimary,
        'textSecondary': p.textSecondary,
        'accent': p.accent,
        'info': p.info,
        'attention': p.attention,
        'capacity': p.capacity,
        'success': p.success,
        'danger': p.danger,
      };

      for (final t in texts.entries) {
        for (final b in backgrounds.entries) {
          test('${t.key} on ${b.key} ≥ 4.5:1', () {
            expect(contrast(t.value, b.value), greaterThanOrEqualTo(4.5));
          });
        }
      }

      test('onAccent on accent ≥ 4.5:1', () {
        expect(contrast(p.onAccent, p.accent), greaterThanOrEqualTo(4.5));
      });

      test('interactive outline on surface ≥ 3:1', () {
        expect(contrast(p.outline, p.surface), greaterThanOrEqualTo(3));
      });

      final containers = {
        'info': (p.info, p.infoContainer),
        'attention': (p.attention, p.attentionContainer),
        'capacity': (p.capacity, p.capacityContainer),
        'success': (p.success, p.successContainer),
        'danger': (p.danger, p.dangerContainer),
      };
      for (final c in containers.entries) {
        test('${c.key} text on its container ≥ 4.5:1', () {
          expect(contrast(c.value.$1, c.value.$2), greaterThanOrEqualTo(4.5));
        });
        test('textPrimary on ${c.key} container ≥ 4.5:1', () {
          expect(
            contrast(p.textPrimary, c.value.$2),
            greaterThanOrEqualTo(4.5),
          );
        });
      }

      test('textPrimary on accentContainer ≥ 4.5:1', () {
        expect(
          contrast(p.textPrimary, p.accentContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('10 subject colors, each ≥ 3:1 on surface', () {
        expect(p.subjects, hasLength(10));
        for (final s in p.subjects) {
          expect(
            contrast(s, p.surface),
            greaterThanOrEqualTo(3),
            reason: s.toString(),
          );
        }
      });

      test('subject swatches are visibly distinct from accent and status '
          'colors', () {
        // Euclidean RGB distance on 0-255 channels; 50 is clearly different
        // side by side; 40 between swatches.
        double distance(Color a, Color b) => math.sqrt(
          math.pow((a.r - b.r) * 255, 2) +
              math.pow((a.g - b.g) * 255, 2) +
              math.pow((a.b - b.b) * 255, 2),
        );
        // A swatch must not read as interactive (accent) or as a workload
        // warning (capacity), which appear next to subject names.
        final reserved = {'accent': p.accent, 'capacity': p.capacity};
        for (final (i, s) in p.subjects.indexed) {
          for (final r in reserved.entries) {
            expect(
              distance(s, r.value),
              greaterThan(50),
              reason: 'subject $i vs ${r.key}',
            );
          }
          for (final (j, other) in p.subjects.indexed.skip(i + 1)) {
            expect(
              distance(s, other),
              greaterThan(40),
              reason: 'subject $i vs subject $j',
            );
          }
        }
      });

      test('capacity is not red: workload warnings never look like errors', () {
        final hsl = HSLColor.fromColor(p.capacity);
        expect(hsl.hue, inInclusiveRange(200, 280));
      });
    });

    group('$name Material color roles', () {
      final s = schemeFor(name == 'light' ? Brightness.light : Brightness.dark);
      final pairs = {
        'onPrimary/primary': (s.onPrimary, s.primary),
        'onPrimaryContainer/primaryContainer': (
          s.onPrimaryContainer,
          s.primaryContainer,
        ),
        'onSecondary/secondary': (s.onSecondary, s.secondary),
        'onSecondaryContainer/secondaryContainer': (
          s.onSecondaryContainer,
          s.secondaryContainer,
        ),
        'onTertiary/tertiary': (s.onTertiary, s.tertiary),
        'onTertiaryContainer/tertiaryContainer': (
          s.onTertiaryContainer,
          s.tertiaryContainer,
        ),
        'onError/error': (s.onError, s.error),
        'onErrorContainer/errorContainer': (
          s.onErrorContainer,
          s.errorContainer,
        ),
        'onSurface/surface': (s.onSurface, s.surface),
        'onSurfaceVariant/surface': (s.onSurfaceVariant, s.surface),
        'onSurface/surfaceContainerHigh': (s.onSurface, s.surfaceContainerHigh),
        'onSurface/surfaceContainerHighest': (
          s.onSurface,
          s.surfaceContainerHighest,
        ),
        'onSurfaceVariant/surfaceContainerHighest': (
          s.onSurfaceVariant,
          s.surfaceContainerHighest,
        ),
        'onInverseSurface/inverseSurface': (
          s.onInverseSurface,
          s.inverseSurface,
        ),
        'inversePrimary/inverseSurface': (s.inversePrimary, s.inverseSurface),
      };
      for (final pair in pairs.entries) {
        test('${pair.key} ≥ 4.5:1', () {
          expect(
            contrast(pair.value.$1, pair.value.$2),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
      test('outline on surface ≥ 3:1', () {
        expect(contrast(s.outline, s.surface), greaterThanOrEqualTo(3));
      });
    });
  }
}
