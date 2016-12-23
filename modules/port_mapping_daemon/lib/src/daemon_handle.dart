import 'package:meta/meta.dart';

class DaemonServerHandle {
  static const Default = const DaemonServerHandle('localhost', 4369, '');
  
  final String hostname;
  final String cookie;
  final int port;

  @literal
  const DaemonServerHandle(this.hostname, this.port, this.cookie);

  String get serverUrl => 'http://$hostname:$port';
}


