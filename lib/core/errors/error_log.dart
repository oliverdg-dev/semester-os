import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'failure.dart';

/// One diagnostics entry. Holds the failure code, the exception type and stack
/// frames only. Never the exception message: foreign messages can contain
/// backup content, task titles or SQL (ARCHITECTURE §10).
class ErrorLogEntry {
  const ErrorLogEntry({
    required this.at,
    required this.code,
    required this.type,
    required this.frames,
  });

  final DateTime at;
  final String code;
  final String type;
  final List<String> frames;

  String format() =>
      '${at.toUtc().toIso8601String()} $code $type${frames.isEmpty ? '' : '\n  ${frames.join('\n  ')}'}';
}

/// Ring buffer of recent errors for Settings > About.
class ErrorLog {
  ErrorLog({this.capacity = 200, Clock? clock})
    : _clock = clock ?? const Clock();

  final int capacity;
  final Clock _clock;
  final List<ErrorLogEntry> _entries = [];

  List<ErrorLogEntry> get entries => List.unmodifiable(_entries);
  ErrorLogEntry? get last => _entries.isEmpty ? null : _entries.last;

  /// Records [error] without keeping its message text.
  ErrorLogEntry record(Object error, [StackTrace? stack]) {
    final entry = ErrorLogEntry(
      at: _clock.now(),
      code: error is Failure ? error.code : const UnexpectedFailure().code,
      type: error.runtimeType.toString(),
      frames: _frames(stack),
    );
    _entries.add(entry);
    if (_entries.length > capacity) _entries.removeAt(0);
    return entry;
  }

  void clear() => _entries.clear();

  /// Only lines that look like stack frames survive; anything else (which could
  /// carry message text) is dropped.
  static final _framePattern = RegExp(
    r'^#\d+\s+\S+\s+\((package|dart):[^)]*\)$',
  );

  static List<String> _frames(StackTrace? stack) {
    if (stack == null) return const [];
    return stack
        .toString()
        .split('\n')
        .map((l) => l.trim())
        .where(_framePattern.hasMatch)
        .take(8)
        .toList(growable: false);
  }
}

/// App-wide error log. Overridden in main() so global handlers and providers
/// share one instance.
final errorLogProvider = Provider<ErrorLog>((ref) => ErrorLog());
