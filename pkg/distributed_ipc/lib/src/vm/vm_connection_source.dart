import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/internal/consumer.dart';
import 'package:meta/meta.dart';

class VmConnectionSource implements ConnectionSource {
  @override
  void onEvent(Consumer<Connection> consumer) {
    // TODO: implement onEvent
  }

  @override
  void open(ConnectionConfig config) {
    // TODO: implement open
  }

  @override
  @protected
  void emit(Connection event) {
    // TODO: implement emit
  }

  @override
  @protected
  void emitAll(Iterable<Connection> events) {
    throw new UnimplementedError();
  }
}
