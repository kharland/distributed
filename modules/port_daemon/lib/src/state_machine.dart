import 'dart:async';

import 'package:meta/meta.dart';

class State {
  static const trap = const State('trap');

  final String name;

  @literal
  const State(this.name);

  @override
  String toString() => '$State{$name}';
}

class StateChange<T> {
  final State oldState;
  final State newState;
  final T input;

  @literal
  const StateChange(this.oldState, this.newState, this.input);
}

typedef bool InputFilter<T>(T input);

class StateMachine<T> {
  final _stateChanges = <State, Map<InputFilter<T>, State>>{};
  final _stateChangeController =
      new StreamController<StateChange<T>>.broadcast(sync: true);

  State _currentState;

  set state(State state) {
    _currentState = state;
  }

  void addStateChange(State oldState, State newState, InputFilter<T> filter) {
    assert(oldState != State.trap);
    _stateChanges[oldState] = {filter: newState};
  }

  void consume(T input) {
    var oldState = _currentState;
    var stateChanges = _stateChanges[currentState] ?? {};
    var stateChangeKey = stateChanges.keys.firstWhere(
        (InputFilter<T> filter) => filter(input),
        orElse: () => null);

    _currentState = State.trap;
    if (stateChangeKey != null) {
      _currentState = stateChanges[stateChangeKey];
    }

    if (oldState != _currentState) {
      _stateChangeController
          .add(new StateChange<T>(oldState, _currentState, input));
    }
  }

  State get currentState => _currentState;

  Stream<StateChange<T>> get stateChanges => _stateChangeController.stream;
}
