import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_state.dart';

/// Renders an [AsyncValue] with the app's state rules (DESIGN_SYSTEM §11):
/// nothing for loads under ~150 ms, then a progress indicator; ErrorState on
/// failure; [data] otherwise.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (error, _) => ErrorState(error: error, onRetry: onRetry),
      loading: () => const _DelayedProgress(),
    );
  }
}

class _DelayedProgress extends StatefulWidget {
  const _DelayedProgress();

  @override
  State<_DelayedProgress> createState() => _DelayedProgressState();
}

class _DelayedProgressState extends State<_DelayedProgress> {
  static const _delay = Duration(milliseconds: 150);
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _visible
      ? const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading'),
        )
      : const SizedBox.shrink();
}
