import 'package:distributed.ipc/src/internal/consumer.dart';
import 'package:meta/meta.dart';

/// A source of events.
///
/// [Consumers] can subscribe to events using [onEvent].  The [EventSource] will
/// send events to each [Consumer] when [emit] is called.
class EventSource<T> {
  final _consumers = <Consumer<T>>[];

  /// Registers [consumer] to be exected when this bus emits an event.
  void onEvent(Consumer<T> consumer) {
    _consumers.add(consumer);
  }

  /// Emits [event] to each registered [Consumer].
  @protected
  void emit(T event) {
    _consumers.forEach((consume) => consume(event));
  }
}
