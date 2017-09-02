import 'package:distributed.ipc/src/internal/consumer.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';

/// Routes [Datagram]s to multiple [Consumers].
class DatagramRouter {
  final EventSource<Datagram> _datagramSource;
  final Consumer<GreetDatagram> _consumeGreetDatagram;

  /// Maps a remote address and port to the [Consumer] receiving [Datagram]s
  /// from that endpoint.
  final _routeToConsumer = <String, Map<int, Consumer<Datagram>>>{};

  DatagramRouter(this._datagramSource, this._consumeGreetDatagram) {
    _datagramSource.onEvent((Datagram datagram) {
      if (datagram.type == DatagramType.GREET) {
        _consumeGreetDatagram(datagram);
      } else {
        final address = datagram.address;
        final port = datagram.port;

        if (_routeToConsumer.containsKey(address) &&
            _routeToConsumer[address].containsKey(port)) {
          _routeToConsumer[address][port](datagram);
        } else {
          // FIXME: Log this instead
          print("Unhandled datagram recieved from $address:$datagram");
        }
      }
    });
  }

  /// Registers [consumer] to consume [Datagram]s from [address] and [port].
  void addRoute(String address, int port, Consumer<Datagram> consumer) {
    _routeToConsumer[address][port] = consumer;
  }
}
