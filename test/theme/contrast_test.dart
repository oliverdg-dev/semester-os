import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
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
    });
  }
}
