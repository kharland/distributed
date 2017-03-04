import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/connection_monitor.dart';
import 'package:distributed.connection/src/socket/socket_channels_controller.dart';
import 'package:test/test.dart';

void main() {
  group('$ConnectionMonitor', () {
    ConnectionController controller;
    ConnectionMonitor monitor;

    setUp(() {
      controller = new ConnectionController();
      monitor = new ConnectionMonitor(controller.local);
    });

    tearDown(() {
      controller.local.close();
      monitor.stop();
    });

    test('onDead should emit when the remote channel closes', () {
      monitor.onDead.then(expectAsync1((_) {
        expect(true, true);
      }));
      controller.foreign.close();
    });

    test('should send messages at regular intervals to the remote', () {
      controller.foreign.system.stream.listen(expectAsync1((message) {
        expect(message.category, 'monitor');
      }, count: 2));
    });
  });
}

class ConnectionController {
  final Connection local;
  final Connection foreign;

  factory ConnectionController() {
    var controller = new SocketChannelsController();
    var localConnection = new Connection(controller.local);
    var foreignConnection = new Connection(controller.foreign);
    return new ConnectionController._(localConnection, foreignConnection);
  }

  ConnectionController._(this.local, this.foreign);
}
