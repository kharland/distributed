import 'package:distributed/distributed.dart';

const pingPongDelay = const Duration(seconds: 1);

final ping = new Peer('ping', HostMachine.localHost);
final pong = new Peer('pong', HostMachine.localHost);
