import 'package:meta/meta.dart';

typedef Consumer<T> = void Function(T data);

/// A registry for [Consumer]s of [T] whose events are manually emitted.
class EventBus<T> {
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

  /// Emits each of [events] to each registered [Consumer].
  @protected
  void emitAll(Iterable<T> events) {
    _consumers.forEach((consume) {
      events.forEach(consume);
    });
  }
}
