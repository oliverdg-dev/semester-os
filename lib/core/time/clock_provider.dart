import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The only source of "now" in the app. Tests override it with a fixed clock.
final clockProvider = Provider<Clock>((ref) => const Clock());
