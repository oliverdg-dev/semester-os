import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_log.dart';

/// Records every provider failure in the [ErrorLog] exactly once, so screens can
/// show ErrorState without logging from build methods.
final class ErrorLogObserver extends ProviderObserver {
  const ErrorLogObserver(this.log);

  final ErrorLog log;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    log.record(error, stackTrace);
  }
}
