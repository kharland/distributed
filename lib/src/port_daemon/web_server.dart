import 'package:distributed/src/port_daemon/port_daemon.dart';

/// An interface for the WebServer used by a [PortDaemon].
abstract class WebServer {
  /// The url for connecting to this [WebServer].
  String get url;

  /// Kills this [WebServer].
  void stop();
}
