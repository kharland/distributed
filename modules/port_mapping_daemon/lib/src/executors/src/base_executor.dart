import 'dart:async';

import 'package:distributed.port_mapping_daemon/src/api/api.dart';
import 'package:distributed.port_mapping_daemon/src/executors/executor.dart';
import 'package:distributed.port_mapping_daemon/src/executors/src/execution_completer.dart';

abstract class BaseExecutor extends Executor {
  final ExecutionCompleter _completer = new ExecutionCompleter();

  DaemonSocket _socket;

  void fail(String reason) {
    _socket.sendHandshakeFailed();
    _completer.fail(reason);
  }

  void succeed(String reason) {
    _socket.sendHandshakeSucceeded();
    _completer.succeed(reason);
  }

  @override
  void execute(DaemonSocket socket) {
    _socket = socket;
  }

  @override
  Future<ExecutionResult> get done => _completer.done;
}
