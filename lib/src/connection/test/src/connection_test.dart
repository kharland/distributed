import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/socket_channels_controller.dart';
import 'package:test/test.dart';

void main() {
  group('$Connection', () {
    ConnectionController controller;

    setUp(() async {
      controller = new ConnectionController();
    });

    tearDown(() async {
      controller.close();
    });

    test('should close if the remote closes.', () async {
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
    return new ConnectionController._(
      new Connection(controller.local),
      new Connection(controller.foreign),
    );
  }

  ConnectionController._(this.local, this.foreign);

  void close() {
    local.close();
    foreign.close();
  }
}
