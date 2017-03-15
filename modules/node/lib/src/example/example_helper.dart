import 'package:distributed.node/platform/vm.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/ports.dart';

const pingDuration = const Duration(seconds: 1);

final ping =
    createPeer('ping', createHostMachine('localhost', Ports.defaultDaemonPort));
final pong =
    createPeer('pong', createHostMachine('localhost', Ports.defaultDaemonPort));
