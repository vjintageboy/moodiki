import 'dart:async';
import 'package:flutter/foundation.dart';

/// Wraps a stream factory with silent retry on error.
/// On error, the last emitted value is held; the stream retries after [retryDelay].
/// This prevents RealtimeSubscribeException (timedOut) from surfacing to the UI.
Stream<T> resilientStream<T>(
  Stream<T> Function() factory, {
  Duration retryDelay = const Duration(seconds: 5),
}) async* {
  while (true) {
    try {
      yield* factory();
      return;
    } catch (e) {
      debugPrint('Realtime stream error (retrying in ${retryDelay.inSeconds}s): $e');
      await Future.delayed(retryDelay);
    }
  }
}
