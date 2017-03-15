import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/socket/socket_channels_controller.dart';
import 'package:test/test.dart';

void main() {
  group('$Connection', () {
    ConnectionController controller;

    setUp(() {
      controller = new ConnectionController();
    });

    tearDown(() {
      controller.local.close();
    });

    test('should close if the remote closes.', () {
      controller.foreign.close();
      expect(controller.local.done, completes);
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
