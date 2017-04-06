import 'package:distributed.http/src/testing/local_address.dart';

class ReservedAddress {
  final String host;
  final int port;
  final NetworkAddress address;

  ReservedAddress(this.host, this.port, this.address);

  @override
  String toString() => '$host:$port';
}
