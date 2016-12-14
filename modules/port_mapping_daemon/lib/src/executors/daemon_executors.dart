import 'dart:async';

import 'package:distributed.port_mapping_daemon/src/api/api.dart';
import 'package:distributed.port_mapping_daemon/src/database/lib/database.dart';
import 'package:distributed.port_mapping_daemon/src/executors/src/base_executor.dart';
import 'package:distributed.port_mapping_daemon/src/fsm.dart';

class PingExecutor extends BaseExecutor {
  @override
  void execute(DaemonSocket socket) {
    super.execute(socket);
    socket.sendPing();
    succeed('pinged remote');
  }
}

/// Registers a node named [name] to the given Daemon.
///
/// Protocol:
///
/// Daemon                                       Client
///   | < [RegistrationRequest] ------------------ |
///   |                                            |
///   | ------------------- [RegistrationResult] > |
///   |                                            |
///   | < [RegistrationResult] ------------------- |
///   |                                            |
///   | ---------------------- [ExecutionResult] > |
///
/// The final [RegistrationResult] sent from Remote to Local is confirmation
/// that the result was received.  If the confirmation's node name or port do
/// not match the information sent to Remote or if the above protocol is
/// violated, the handshake fails and a [ExecutionResult] error is sent to
/// Remote.
class RegisterNodeExecutor extends BaseExecutor {
  final Database<String, int> _nodeDatabase;
  final Function _getPort;
  StreamSubscription<StateChange<String>> _subscription;
  RegistrationResult result;

  RegisterNodeExecutor(this._nodeDatabase, Future<int> getPort())
      : _getPort = getPort;

  @override
  void execute(DaemonSocket socket) {
    var machine = new RegisterNodeStateMachine();

    super.execute(socket);
    super.done.then((_) {
      _subscription.cancel();
    });

    _subscription = machine.stateChanges.listen((change) async {
      switch (change.newState) {
        case RegisterNodeStateMachine.register:
          // Register the new node.
          var request = new RegistrationRequest.fromString(change.input);
          if (_nodeDatabase.containsKey(request.nodeName)) {
            var port = _nodeDatabase.get(request.nodeName);
            fail('${request.nodeName} is already registered to port $port');
          } else {
            result = new RegistrationResult(request.nodeName, await _getPort());
            socket.send(result.toString());
          }
          break;
        case RegisterNodeStateMachine.confirm:
          _confirmRegistration(new RegistrationResult.fromString(change.input));
          break;
        case State.trap:
          fail('Invalid data ${change.input}');
          break;
        default:
          throw new UnimplementedError();
      }
    });

    socket.stream.listen(machine.consume);
  }

  void _confirmRegistration(RegistrationResult confirmation) {
    if (result.name == confirmation.name && result.port == confirmation.port) {
      succeed('Registered ${result.name} on port ${result.port}');
    } else {
      fail('Confirmation failed');
    }
  }
}

class RegisterNodeStateMachine {
  static const State start = const State('start');
  static const State register = const State('register');
  static const State confirm = const State('confirm');

  final StateMachine<String> _machine = new StateMachine<String>();

  RegisterNodeStateMachine() {
    _machine
      ..addStateChange(start, register,
          (String input) => Entity.canParseAs(RegistrationRequest, input))
      ..addStateChange(register, confirm,
          (String input) => Entity.canParseAs(RegistrationResult, input));
  }

  void consume(String input) {
    _machine.consume(input);
  }

  Stream<StateChange<String>> get stateChanges => _machine.stateChanges;
}
