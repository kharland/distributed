import 'dart:async';

import 'package:distributed.port_mapping_daemon/src/api/api.dart';

abstract class Executor {
  void execute(DaemonSocket socket);

  Future<ExecutionResult> get done;
}