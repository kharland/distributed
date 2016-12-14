import 'dart:async';

import 'package:distributed.port_mapping_daemon/src/api/api.dart';

class ExecutionCompleter {
  final _doneCompleter = new Completer<ExecutionResult>();

  void fail(String reason) {
    var result = new ExecutionResult.error(reason);
    _doneCompleter.complete(result);
  }

  void succeed(String message) {
    var result = new ExecutionResult(message);
    _doneCompleter.complete(result);
  }

  Future<ExecutionResult> get done => _doneCompleter.future;
}
