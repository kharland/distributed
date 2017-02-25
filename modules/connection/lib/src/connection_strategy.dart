import 'dart:async';

import 'package:distributed.connection/connection.dart';

abstract class ConnectionStrategy {
  Stream<Connection> connect(String localPeerName, String remotePeerName);
}
