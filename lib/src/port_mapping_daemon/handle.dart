import 'dart:async';
import 'dart:io';

import 'package:distributed/src/port_mapping_daemon/info.dart';
import 'package:distributed/src/port_mapping_daemon/api/api.dart';
import 'package:distributed/src/port_mapping_daemon/src/utils.dart';
import 'package:path/path.dart';

/// A handle for communicating with a [PortMappingDaemon] (PMD) running as a
/// separate process on the local machine.
class DaemonHandle {
  final DaemonSocket _channel;
  final DaemonInfo _info;

  DaemonHandle._(this._channel, this._info);

  static Future<DaemonHandle> connect(DaemonInfo info) async {
    assert(await isDaemonRunning(info));
    return new DaemonHandle._(
        await DaemonSocket.createFromUrl(info.url), info);
  }

  static Future<bool> isDaemonRunning(DaemonInfo info) async {
    var resultCompleter = new Completer<bool>();
    var channel = await DaemonSocket.createFromUrl(info.url);

    try {
      nextElement(channel.stream, onTimeout: () {
        resultCompleter.complete(false);
      }, onData: (_) {
        resultCompleter.complete(true);
      });
      channel.sendRequestInitiation(RequestType.ping, 'cookie');
      channel.close();
      return resultCompleter.future;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<Process> spawnDaemon(DaemonInfo info) {
    var dart = _findDart();
    if (dart.isEmpty) {
      throw new Exception('Could not find dart.  Set \$DARTVM to the location '
          'of the dart binary and try again.');
    }
    return _spawnDaemon(info, dart);
  }

  /// Registers a new node to the local PMD.
  ///
  /// Returns a future that completes with the node's registration information.
  Future<RegistrationResult> registerNode(String name) async {
    var resultCompleter = new Completer<RegistrationResult>();

    nextElement(_channel.stream, onTimeout: () {
      resultCompleter.complete(const RegistrationResult.failure());
    });

    _channel.sendRequestInitiation(RequestType.register, _info.cookie);
    _channel.sendRegistrationRequest(name);
    return resultCompleter.future;
  }

  static String _findDart() {
    var envPath = Platform.environment['PATH'];
    var paths = envPath.split(':').where((path) =>
        path.toLowerCase().contains('dart') &&
        path.endsWith('${Platform.pathSeparator}bin'));

    for (String path in paths) {
      path = absolute(path.replaceAll('~', Platform.environment['HOME']));
      var directory = new Directory(path);
      if (!directory.existsSync()) {
        continue;
      }

      var files = directory.listSync();
      var dartVmBinary = files.firstWhere(
          (FileSystemEntity entity) => entity.path.endsWith('dart'),
          orElse: () => null);

      if (dartVmBinary?.existsSync() == true) {
        return dartVmBinary.path;
      }
    }

    var dartVmPath = Platform.environment['DARTVM'];
    if (dartVmPath?.isNotEmpty == true) {
      return dartVmPath;
    }

    return '';
  }

  static Future<Process> _spawnDaemon(DaemonInfo info, String dart) async {
    assert(!await isDaemonRunning(info));

    var daemonProcess = await Process.start(
        dart,
        [
          '-c',
          'daemon.dart',
          '--hostname=${info.hostname}',
          '--port=${info.port}',
          '--cookie=${info.cookie}'
        ],
        mode: ProcessStartMode.DETACHED_WITH_STDIO);
    await daemonProcess.stdout.first;

    if (!await isDaemonRunning(info)) {
      throw new StateError("Unable to start daemon");
    }

    return daemonProcess;
  }
}
