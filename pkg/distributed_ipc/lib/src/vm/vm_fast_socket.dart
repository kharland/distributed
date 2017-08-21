import 'dart:async';
import 'package:distributed.ipc/platform/vm.dart';

/// A [RawUdpSocket] that favors speed over reliability.
///
/// A [VmFastSocket] does not wait for acknowledgement that a packet is received
/// and packets that are dropped are lost forever.
class VmFastSocket extends StreamView<String> implements UdpSocket {
  VmFastSocket(Stream<String> stream) : super(stream);

  @override
  void add(String event) {
    throw new UnimplementedError('add');
  }

  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
    throw new UnimplementedError('addError');
  }

  @override
  void close() {
    throw new UnimplementedError('close');
  }
}
