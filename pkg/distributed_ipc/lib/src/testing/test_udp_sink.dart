import 'package:distributed.ipc/src/vm/vm_socket.dart';

class TestSink<T> implements Sink<T> {
  final data = <T>[];

  @override
  void add(T value) {
    data.add(value);
  }

  @override
  void close() {}
}
