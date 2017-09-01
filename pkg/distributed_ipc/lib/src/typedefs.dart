typedef Consumer<T> = void Function(T data);

/// A registry for [Consumer]s of [T] whose events are manually emitted.
abstract class EventBus<T> {
  void onEvent(Consumer<T> consumer);
}

class EventBusController<T> implements EventBus<T> {
  List<Consumer<T>> _consumers;

  @override
  void onEvent(Consumer<T> consumer) {
    _consumers.add(consumer);
  }

  /// Emits [event] to each registered [Consumer].
  void addEvent(T event) {
    _consumers.forEach((consume) => consume(event));
  }

  /// Emits each of [events] to each registered [Consumer].
  void addAllEvents(Iterable<T> events) {
    _consumers.forEach((consume) {
      events.forEach(consume);
    });
  }
}

/*
typedef Consumer<T> = void Function(T data);

/// A registry for [Consumer]s of [T] whose events are manually emitted.
abstract class EventBus<T> {
  List<Consumer<T>> _consumers;

  set consumers(List<Consumer<T>> consumers) {
    _consumers = consumers;
  }

  /// Emits [event] to all registered [Consumer]s.
  void addEvent(T event) {
    _consumers.forEach((consume) => consume(event));
  }
}

/// A registry for [Consumer]s of [T].
abstract class EventService<T> {
  final _consumers = <Consumer<T>>[];

  /// Subscribes [consumer] to this [EventBus].
  void onEvent(Consumer<T> consumer) {
    _consumers.add(consumer);
  }
}*/
