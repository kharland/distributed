import 'package:distributed.http/environment/vm_testing.dart';
import 'package:distributed.http/src/testing/network_emulator.dart';
import 'package:distributed.http/vm.dart';
import 'package:stream_channel/stream_channel.dart';

class ConnectedSockets {
  final Socket sender;
  final Socket receiver;

  ConnectedSockets(this.sender, this.receiver);
}

class SocketConnector {
  AddressReleaser _receiverAddress;
  AddressReleaser _senderAddress;

  set receiverAddress(AddressReleaser value) {
    _receiverAddress = value;
  }

  set senderAddress(AddressReleaser value) {
    _senderAddress = value;
  }

  ConnectedSockets connect() {
    var _receiverController = new StreamChannelController<String>();
    var _senderController = new StreamChannelController<String>();
    var receiverSocket = new TestSocket(_receiverAddress,
        _receiverController.local.sink, _receiverController.local.stream);
    var senderSocket = new TestSocket(_senderAddress,
        _senderController.local.sink, _senderController.local.stream);

    _senderController.foreign.stream
        .forEach(_receiverController.foreign.sink.add);
    _receiverController.foreign.stream
        .forEach(_senderController.foreign.sink.add);
    return new ConnectedSockets(senderSocket, receiverSocket);
  }
}
