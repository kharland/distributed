import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/ports.dart';

const pingDuration = const Duration(seconds: 1);

final ping = $peer('ping', $hostMachine('localhost', Ports.defaultDaemonPort));
final pong = $peer('pong', $hostMachine('localhost', Ports.defaultDaemonPort));
