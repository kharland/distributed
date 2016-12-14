import 'dart:async';

import 'package:distributed/src/port_mapping_daemon/daemon.dart';
import 'package:distributed/src/port_mapping_daemon/api/api.dart';
import 'package:distributed/src/port_mapping_daemon/fsm/fsm.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/handshake.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/src/handshake_impl.dart';

class PingHandshake extends HandshakeImpl {
  @override
  void start(DaemonSocket socket) {
    super.start(socket);
    socket.sendPing();
    succeed('pinged remote');
  }
}

/// A [Handshake] implementation that registers a new node to a Daemon.
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
///   | ---------------------- [HandshakeResult] > |
///
/// The final [RegistrationResult] sent from Remote to Local is confirmation
/// that the result was received.  If the confirmation's node name or port do
/// not match the information sent to Remote or if the above protocol is
/// violated, the handshake fails and a [HandshakeResult] error is sent to
/// Remote.
class RegisterNodeHandshake extends HandshakeImpl {
  final PortMappingDaemon _daemon;

  StreamSubscription<StateChange<String>> _subscription;
  String _nodeName;
  int _port;

  RegisterNodeHandshake(this._daemon);

  @override
  void start(DaemonSocket socket) {
    super.start(socket);
    super.done.then((_) {
      _subscription.cancel();
    });

    var machine = new RegisterNodeStateMachine();
    _subscription = machine.stateChanges.listen((StateChange<String> change) {
      switch (change.newState) {
        case RegisterNodeStateMachine.register:
          _registerNode(
              new RegistrationRequest.fromString(change.input), socket);
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

  Future _registerNode(RegistrationRequest request, DaemonSocket socket) async {
    _nodeName = request.nodeName;
    if (await _daemon.registerNode(_nodeName)) {
      socket.sendRegistrationInfo(_nodeName, _daemon.getPort(_nodeName));
    } else {
      fail('Unable to register $_nodeName');
    }
  }

  void _confirmRegistration(RegistrationResult result) {
    if (result.name == _nodeName && result.port == _port) {
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
